import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gre_prep/app.dart';
import 'package:gre_prep/attempts/attempt_repository.dart';
import 'package:gre_prep/content/content_repository.dart';
import 'package:gre_prep/features/essay/essay_assessment.dart';
import 'package:gre_prep/features/exam/exam_notifier.dart';
import 'package:gre_prep/features/exam/exam_widgets.dart';
import 'package:gre_prep/ui/async_value_view.dart';
import 'package:gre_prep/ui/theme.dart';

/// The essay of a finished mock with the model answer and the self-rating.
class MockEssayScreen extends ConsumerWidget {
  const MockEssayScreen({required this.attemptId, super.key});

  final String attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(reviewProvider(attemptId)),
    data: (exam) => Scaffold(
      appBar: AppBar(title: Text(context.l10n.measureWriting)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        children: [
          EssayAssessment(
            prompt: exam.sitting.essay,
            essay: exam.attempt.essay,
            initialScore: exam.attempt.essaySelfScore,
            onScore: (score) async {
              await ref
                  .read(attemptRepositoryProvider)
                  .update(attemptId, (attempt) => attempt.copyWith(essaySelfScore: score));
              ref.invalidate(reviewProvider(attemptId));
            },
          ),
        ],
      ),
    ),
  );
}

/// Essay practice outside a mock: an optional 30-minute clock, then the same assessment.
class PracticeEssayScreen extends ConsumerStatefulWidget {
  const PracticeEssayScreen({required this.promptId, super.key});

  final String promptId;

  @override
  ConsumerState<PracticeEssayScreen> createState() => _PracticeEssayScreenState();
}

class _PracticeEssayScreenState extends ConsumerState<PracticeEssayScreen> {
  final _controller = TextEditingController();
  Timer? _timer;
  int _seconds = 30 * 60;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds <= 1) {
        _finish();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    _timer?.cancel();
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AsyncValueView(
      value: ref.watch(bankProvider('writing')),
      data: (bank) {
        final prompt = bank.questions.firstWhere((q) => q.id == widget.promptId);
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.measureWriting),
            actions: [if (!_done) TimerLabel(seconds: _seconds)],
          ),
          body: ListView(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            children: _done
                ? [
                    EssayAssessment(
                      prompt: prompt,
                      essay: _controller.text,
                      initialScore: null,
                      onScore: (_) {},
                    ),
                  ]
                : [
                    Card(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(prompt.stem, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: AppSpacing.sm),
                            Text(prompt.task ?? ''),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _controller,
                      minLines: 14,
                      maxLines: null,
                      autocorrect: false,
                      enableSuggestions: false,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: l10n.essayHint,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    Text(
                      l10n.wordCount(essayWords(_controller.text)),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(onPressed: _finish, child: Text(l10n.finishEssay)),
                  ],
          ),
        );
      },
    );
  }
}
