import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gre_prep/ads/ad_service.dart';
import 'package:gre_prep/app.dart';
import 'package:gre_prep/content/models.dart';
import 'package:gre_prep/core/grading.dart';
import 'package:gre_prep/features/exam/calculator.dart';
import 'package:gre_prep/features/practice/practice_notifier.dart';
import 'package:gre_prep/ui/async_value_view.dart';
import 'package:gre_prep/ui/question_view.dart';
import 'package:gre_prep/ui/theme.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({required this.section, required this.topic, super.key});

  final String section;
  final String topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = PracticeKey(section, topic);
    return AsyncValueView(
      value: ref.watch(practiceProvider(key)),
      data: (practice) => Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.tabPractice),
          actions: [
            if (section == 'quant')
              IconButton(
                tooltip: context.l10n.calculator,
                icon: const Icon(Icons.calculate_outlined),
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const CalculatorSheet(),
                ),
              ),
          ],
        ),
        body: switch (practice) {
          PracticeState(questions: []) => Center(child: Text(context.l10n.practiceEmpty)),
          PracticeState(finished: true) => _Summary(practice: practice, practiceKey: key),
          _ => _QuestionPage(
            practice: practice,
            notifier: ref.read(practiceProvider(key).notifier),
          ),
        },
      ),
    );
  }
}

class _QuestionPage extends StatelessWidget {
  const _QuestionPage({required this.practice, required this.notifier});

  final PracticeState practice;
  final PracticeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final question = practice.question;
    final last = practice.index == practice.questions.length - 1;
    final right = practice.checked && isCorrect(question, practice.response);
    return ListView(
      key: PageStorageKey(question.id),
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: [
        Text(
          '${l10n.questionOf(practice.index + 1, practice.questions.length)} · ${l10n.levelName('${question.level}')}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        QuestionHeader(
          question: question,
          set: practice.sets[question.setId],
          response: practice.response,
        ),
        AnswerArea(
          question: question,
          response: practice.response,
          reveal: practice.checked,
          onChanged: notifier.respond,
        ),
        if (!practice.checked && !checksOnTap(question))
          FilledButton(
            onPressed: Responses.isAnswered(question, practice.response) ? notifier.check : null,
            child: Text(l10n.check),
          ),
        if (practice.checked) ...[
          if (question.type != QuestionType.ne)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
              child: Text(
                right ? l10n.correct : l10n.incorrect,
                style: TextStyle(
                  color: right ? AppColors.correct : AppColors.incorrect,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ExplanationBox(text: question.explanation),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: () => unawaited(notifier.next()),
            child: Text(last ? l10n.finish : l10n.next),
          ),
        ],
      ],
    );
  }
}

class _Summary extends ConsumerWidget {
  const _Summary({required this.practice, required this.practiceKey});

  final PracticeState practice;
  final PracticeKey practiceKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.practiceDone,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.practiceTally(practice.correct, practice.questions.length),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => ref.invalidate(practiceProvider(practiceKey)),
              child: Text(l10n.practiceAgain),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () async {
                await ref.read(adServiceProvider).showReportInterstitial();
                if (context.mounted) context.pop();
              },
              child: Text(l10n.backToTopic),
            ),
          ],
        ),
      ),
    );
  }
}
