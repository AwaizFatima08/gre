import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gre_prep/app.dart';
import 'package:gre_prep/content/models.dart';
import 'package:gre_prep/core/grading.dart';
import 'package:gre_prep/features/exam/calculator.dart';
import 'package:gre_prep/features/exam/exam_notifier.dart';
import 'package:gre_prep/features/exam/exam_widgets.dart';
import 'package:gre_prep/ui/async_value_view.dart';
import 'package:gre_prep/ui/question_view.dart';
import 'package:gre_prep/ui/theme.dart';

class ExamScreen extends ConsumerStatefulWidget {
  const ExamScreen({required this.attemptId, super.key});

  final String attemptId;

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> with WidgetsBindingObserver {
  ExamNotifier get _notifier => ref.read(examProvider(widget.attemptId).notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.paused) unawaited(_notifier.pauseTimer());
    if (lifecycle == AppLifecycleState.resumed) _notifier.resumeTimer();
  }

  Future<void> _confirmLeave() async {
    final l10n = context.l10n;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.leaveTitle),
        content: Text(l10n.leaveBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.stay)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.leave)),
        ],
      ),
    );
    if (leave != true) return;
    await _notifier.pauseTimer();
    if (mounted) context.pop();
  }

  Future<void> _confirmEnd(ExamState exam) async {
    final l10n = context.l10n;
    final unanswered = exam.stage.isEssay
        ? 0
        : exam.questions
              .where((q) => !Responses.isAnswered(q, exam.attempt.responses[q.id]))
              .length;
    final end = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exam.isLastStage ? l10n.finishTitle : l10n.endSectionTitle),
        content: Text(
          [
            if (unanswered > 0) l10n.unansweredWarning(unanswered),
            l10n.endSectionBody,
          ].join('\n\n'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.keepWorking)),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(exam.isLastStage ? l10n.finishTest : l10n.endSection),
          ),
        ],
      ),
    );
    if (end == true) await _notifier.endStage();
  }

  Future<void> _openReview(ExamState exam) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => QuestionPalette(
      exam: exam,
      onPick: (index) {
        Navigator.pop(context);
        unawaited(_notifier.goTo(index));
      },
      onEnd: () {
        Navigator.pop(context);
        unawaited(_confirmEnd(exam));
      },
    ),
  );

  Future<void> _openCalculator(ExamState exam) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheet) => CalculatorSheet(
      onTransfer: exam.question.type == QuestionType.ne && !exam.question.isFractionEntry
          ? (value) {
              Navigator.pop(sheet);
              unawaited(_notifier.respond(value));
            }
          : null,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final provider = examProvider(widget.attemptId);
    ref.listen(provider, (previous, next) {
      if (next.value?.attempt.isFinished ?? false) {
        context.pushReplacement('/results/${widget.attemptId}');
      }
    });
    return AsyncValueView(
      value: ref.watch(provider),
      data: (exam) {
        final l10n = context.l10n;
        final stage = exam.stage;
        final started = exam.attempt.stageStarted;
        final quant = stage.measure == 'quant';
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) unawaited(_confirmLeave());
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(stageShortTitle(context, stage)),
              actions: [
                if (started && quant)
                  IconButton(
                    tooltip: l10n.calculator,
                    icon: const Icon(Icons.calculate_outlined),
                    onPressed: () => unawaited(_openCalculator(exam)),
                  ),
                if (started) TimerLabel(seconds: exam.attempt.remainingSeconds),
              ],
            ),
            body: !started
                ? _StageIntro(exam: exam, onBegin: () => unawaited(_notifier.beginStage()))
                : stage.isEssay
                ? _EssayBody(
                    exam: exam,
                    notifier: _notifier,
                    onEnd: () => unawaited(_confirmEnd(exam)),
                  )
                : _QuestionBody(exam: exam, notifier: _notifier),
            bottomNavigationBar: started && !stage.isEssay
                ? ExamBar(
                    exam: exam,
                    onPrevious: () => unawaited(_notifier.goTo(exam.attempt.currentIndex - 1)),
                    onNext: () => unawaited(_notifier.goTo(exam.attempt.currentIndex + 1)),
                    onReview: () => unawaited(_openReview(exam)),
                    onEnd: () => unawaited(_confirmEnd(exam)),
                  )
                : null,
          ),
        );
      },
    );
  }
}

/// The screen before each stage: what comes, how long it takes, and the Begin button.
class _StageIntro extends StatelessWidget {
  const _StageIntro({required this.exam, required this.onBegin});

  final ExamState exam;
  final VoidCallback onBegin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stage = exam.stage;
    final theme = Theme.of(context).textTheme;
    final rules = switch (stage.measure) {
      'writing' => l10n.introWriting,
      'verbal' => l10n.introVerbal,
      _ => l10n.introQuant,
    };
    return ListView(
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      children: [
        Text(
          l10n.stageOf(exam.attempt.stage + 1, exam.sitting.stages.length),
          style: theme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(stageTitle(context, stage), style: theme.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          stage.isEssay
              ? l10n.essayMinutes(stage.minutes)
              : l10n.stageSize(stage.itemIds.length, stage.minutes),
          style: theme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(rules, style: const TextStyle(height: 1.5)),
        if (!stage.isEssay && stage.part == 1) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.introAdaptive, style: const TextStyle(height: 1.5)),
        ],
        const SizedBox(height: AppSpacing.lg),
        FilledButton(onPressed: onBegin, child: Text(l10n.beginSection)),
      ],
    );
  }
}

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({required this.exam, required this.notifier});

  final ExamState exam;
  final ExamNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final question = exam.question;
    final response = exam.attempt.responses[question.id];
    final flagged = exam.attempt.flagged.contains(question.id);
    final l10n = context.l10n;
    return ListView(
      key: PageStorageKey(question.id),
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.questionOf(exam.attempt.currentIndex + 1, exam.questions.length),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            FilterChip(
              avatar: Icon(
                flagged ? Icons.bookmark : Icons.bookmark_border,
                color: AppColors.flagged,
              ),
              label: Text(l10n.mark),
              selected: flagged,
              showCheckmark: false,
              onSelected: (_) => unawaited(notifier.toggleFlag()),
            ),
          ],
        ),
        QuestionHeader(
          question: question,
          set: exam.sitting.sets[question.setId],
          response: response,
        ),
        AnswerArea(
          question: question,
          response: response,
          onChanged: (value) => unawaited(notifier.respond(value)),
        ),
        if (response != null && response.isNotEmpty && question.type != QuestionType.ne)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => unawaited(notifier.respond('')),
              child: Text(l10n.clearAnswer),
            ),
          ),
      ],
    );
  }
}

/// The Analytical Writing task: prompt, instructions and a plain editor with a word count.
class _EssayBody extends StatefulWidget {
  const _EssayBody({required this.exam, required this.notifier, required this.onEnd});

  final ExamState exam;
  final ExamNotifier notifier;
  final VoidCallback onEnd;

  @override
  State<_EssayBody> createState() => _EssayBodyState();
}

class _EssayBodyState extends State<_EssayBody> {
  late final _controller = TextEditingController(text: widget.exam.attempt.essay);
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    unawaited(widget.notifier.writeEssay(_controller.text));
    _controller.dispose();
    super.dispose();
  }

  void _changed(String text) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(seconds: 2),
      () => unawaited(widget.notifier.writeEssay(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final prompt = widget.exam.sitting.essay;
    final words = wordCount(_controller.text);
    return ListView(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prompt.stem,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(prompt.task ?? '', style: const TextStyle(height: 1.45)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _controller,
          minLines: 14,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(border: const OutlineInputBorder(), hintText: l10n.essayHint),
          onChanged: _changed,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.wordCount(words), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          onPressed: () async {
            await widget.notifier.writeEssay(_controller.text);
            widget.onEnd();
          },
          child: Text(l10n.endSection),
        ),
      ],
    );
  }
}

int wordCount(String text) => text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
