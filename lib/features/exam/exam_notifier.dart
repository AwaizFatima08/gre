import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gre_prep/attempts/attempt.dart';
import 'package:gre_prep/attempts/attempt_repository.dart';
import 'package:gre_prep/content/content_repository.dart';
import 'package:gre_prep/content/models.dart';
import 'package:gre_prep/core/clock.dart';
import 'package:gre_prep/core/result.dart';
import 'package:gre_prep/core/scoring.dart';
import 'package:gre_prep/settings/settings_repository.dart';

class ExamState {
  const ExamState({required this.sitting, required this.attempt, required this.catalog});

  final Sitting sitting;
  final Attempt attempt;
  final Catalog catalog;

  Stage get stage => sitting.stages[attempt.stage];

  List<Question> get questions => sitting.questionsOf(stage);

  Question get question => questions[attempt.currentIndex];

  bool get isLastStage => attempt.stage == sitting.stages.length - 1;

  ExamState withAttempt(Attempt attempt) =>
      ExamState(sitting: sitting, attempt: attempt, catalog: catalog);
}

/// Loads an attempt with its paper; used by the exam, results and review screens.
Future<ExamState> loadExamState(Ref ref, String attemptId) async {
  final attempt = await ref.read(attemptRepositoryProvider).byId(attemptId);
  if (attempt == null) throw StorageFailure('not-found:$attemptId');
  return _withSitting(ref, attempt);
}

Future<ExamState> _withSitting(Ref ref, Attempt attempt) async {
  final content = ref.read(contentRepositoryProvider);
  final papers = await content.papers();
  final paper = papers.where((p) => p.id == attempt.paperId).firstOrNull;
  if (paper == null) throw ContentFailure('missing-paper:${attempt.paperId}');
  final catalog = await content.catalog();
  final loaded = await content.sitting(paper, catalog, routes: attempt.routes);
  return switch (loaded) {
    Ok(:final value) => ExamState(sitting: value, attempt: attempt, catalog: catalog),
    Err(:final failure) => throw failure,
  };
}

final reviewProvider = FutureProvider.autoDispose.family<ExamState, String>(loadExamState);

/// Runs one mock: the stage clocks, answers, marks, the section 2 routing and the final score.
class ExamNotifier extends AsyncNotifier<ExamState> {
  ExamNotifier(this.attemptId);

  final String attemptId;

  static const _saveEverySeconds = 15;
  Timer? _timer;

  AttemptRepository get _repository => ref.read(attemptRepositoryProvider);

  @override
  Future<ExamState> build() async {
    ref.onDispose(() => _timer?.cancel());
    final loaded = await loadExamState(ref, attemptId);
    if (!loaded.attempt.isFinished && loaded.attempt.stageStarted) resumeTimer();
    return loaded;
  }

  void resumeTimer() {
    final current = state.value;
    if (current == null || current.attempt.isFinished || !current.attempt.stageStarted) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => unawaited(_tick()));
  }

  /// Stops the clock and saves the time left, when the candidate leaves the test.
  Future<void> pauseTimer() async {
    _timer?.cancel();
    final current = state.value;
    if (current == null || current.attempt.isFinished) return;
    await _persist(current.attempt);
  }

  Future<void> _tick() async {
    final current = state.value;
    if (current == null) return;
    final remaining = current.attempt.remainingSeconds - 1;
    if (remaining <= 0) {
      await endStage();
      return;
    }
    final next = current.attempt.copyWith(remainingSeconds: remaining);
    state = AsyncData(current.withAttempt(next));
    if (remaining % _saveEverySeconds == 0) await _persist(next);
  }

  Future<void> _persist(Attempt attempt) async {
    await _repository.update(attemptId, (_) => attempt);
  }

  Future<void> _apply(Attempt Function(Attempt) change) async {
    final current = state.value;
    if (current == null || current.attempt.isFinished) return;
    final next = change(current.attempt);
    await _persist(next);
    state = AsyncData(current.withAttempt(next));
  }

  /// Starts the clock of the current stage after its intro screen.
  Future<void> beginStage() async {
    await _apply((attempt) => attempt.copyWith(stageStarted: true));
    resumeTimer();
  }

  Future<void> respond(String response) => _apply((attempt) {
    final id = state.value!.question.id;
    final responses = {...attempt.responses};
    if (response.isEmpty) {
      responses.remove(id);
    } else {
      responses[id] = response;
    }
    return attempt.copyWith(responses: responses);
  });

  Future<void> writeEssay(String text) => _apply((attempt) => attempt.copyWith(essay: text));

  Future<void> toggleFlag() => _apply((attempt) {
    final id = state.value!.question.id;
    final flagged = {...attempt.flagged};
    if (!flagged.remove(id)) flagged.add(id);
    return attempt.copyWith(flagged: flagged);
  });

  Future<void> goTo(int index) => _apply((attempt) => attempt.copyWith(currentIndex: index));

  /// Closes the current stage (time up or the candidate moves on). Ending section 1 of a
  /// measure fixes which section 2 follows; ending the last stage marks the mock.
  Future<void> endStage() async {
    _timer?.cancel();
    final current = state.value;
    if (current == null || current.attempt.isFinished) return;
    if (current.isLastStage) {
      await _finish(current);
      return;
    }
    var attempt = current.attempt;
    final stage = current.stage;
    if (!stage.isEssay && stage.part == 1) {
      final correct = firstSectionCorrect(current.sitting, stage.measure, attempt.responses);
      final hard = correct >= current.catalog.measure(stage.measure).hardAt;
      attempt = attempt.copyWith(
        routes: {...attempt.routes, stage.measure: hard ? 'hard' : 'easy'},
      );
    }
    final nextStage = attempt.stage + 1;
    final nextState = await _withSitting(ref, attempt);
    attempt = attempt.copyWith(
      stage: nextStage,
      stageStarted: false,
      currentIndex: 0,
      remainingSeconds: nextState.sitting.stages[nextStage].minutes * 60,
    );
    await _persist(attempt);
    state = AsyncData(nextState.withAttempt(attempt));
  }

  /// Marks the paper, saves the result and feeds the topic tallies.
  Future<void> _finish(ExamState current) async {
    final result = scoreSitting(current.sitting, current.attempt.responses);
    final verbal = result.measures['verbal']!;
    final quant = result.measures['quant']!;
    final next = current.attempt.copyWith(
      finishedAt: ref.read(clockProvider).now(),
      score: MockScore(
        verbal: verbal.scaled,
        quant: quant.scaled,
        verbalCorrect: verbal.overall.correct,
        quantCorrect: quant.overall.correct,
        total: verbal.overall.total,
      ),
    );
    await _persist(next);
    await ref.read(practiceTallyProvider.notifier).recordAll(result.topics);
    state = AsyncData(current.withAttempt(next));
  }
}

final examProvider = AsyncNotifierProvider.autoDispose.family<ExamNotifier, ExamState, String>(
  ExamNotifier.new,
);
