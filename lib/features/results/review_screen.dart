import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gre_prep/app.dart';
import 'package:gre_prep/content/content_repository.dart';
import 'package:gre_prep/content/models.dart';
import 'package:gre_prep/core/grading.dart';
import 'package:gre_prep/features/exam/exam_notifier.dart';
import 'package:gre_prep/features/exam/exam_widgets.dart';
import 'package:gre_prep/ui/async_value_view.dart';
import 'package:gre_prep/ui/question_view.dart';
import 'package:gre_prep/ui/theme.dart';

enum ReviewFilter { all, wrong, skipped, marked }

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({required this.attemptId, super.key});

  final String attemptId;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

/// One reviewed question with its stage and number in that stage.
typedef _Entry = ({Stage stage, int number, Question question});

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  ReviewFilter _filter = ReviewFilter.all;

  bool _matches(Question question, ExamState exam) {
    final response = exam.attempt.responses[question.id];
    return switch (_filter) {
      ReviewFilter.all => true,
      ReviewFilter.wrong =>
        Responses.isAnswered(question, response) && !isCorrect(question, response),
      ReviewFilter.skipped => !Responses.isAnswered(question, response),
      ReviewFilter.marked => exam.attempt.flagged.contains(question.id),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AsyncValueView(
      value: ref.watch(reviewProvider(widget.attemptId)),
      data: (exam) {
        final shown = <_Entry>[
          for (final stage in exam.sitting.stages)
            if (!stage.isEssay)
              for (final (i, question) in exam.sitting.questionsOf(stage).indexed)
                if (_matches(question, exam)) (stage: stage, number: i + 1, question: question),
        ];
        return Scaffold(
          appBar: AppBar(title: Text(l10n.reviewTitle)),
          body: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
                child: SegmentedButton<ReviewFilter>(
                  segments: [
                    ButtonSegment(value: ReviewFilter.all, label: Text(l10n.filterAll)),
                    ButtonSegment(value: ReviewFilter.wrong, label: Text(l10n.filterWrong)),
                    ButtonSegment(value: ReviewFilter.skipped, label: Text(l10n.filterSkipped)),
                    ButtonSegment(value: ReviewFilter.marked, label: Text(l10n.filterMarked)),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (value) => setState(() => _filter = value.first),
                ),
              ),
              Expanded(
                child: shown.isEmpty
                    ? Center(child: Text(l10n.filterEmpty))
                    : ListView.builder(
                        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                        itemCount: shown.length,
                        itemBuilder: (_, position) => ReviewItem(
                          label:
                              '${stageTitle(context, shown[position].stage)} · ${shown[position].number}',
                          question: shown[position].question,
                          set: exam.sitting.sets[shown[position].question.setId],
                          response: exam.attempt.responses[shown[position].question.id],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A question with the candidate's answer, the key and the explanation.
class ReviewItem extends StatelessWidget {
  const ReviewItem({
    required this.label,
    required this.question,
    required this.set,
    required this.response,
    super.key,
  });

  final String label;
  final Question question;
  final QuestionSet? set;
  final String? response;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final answered = Responses.isAnswered(question, response);
    final right = isCorrect(question, response);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                right
                    ? Icons.check_circle
                    : (answered ? Icons.cancel : Icons.remove_circle_outline),
                color: right ? AppColors.correct : (answered ? AppColors.incorrect : null),
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  answered ? label : '$label · ${l10n.notAnswered}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
          QuestionHeader(question: question, set: set, response: response, passageOpen: false),
          AnswerArea(question: question, response: response, reveal: true),
          ExplanationBox(text: question.explanation),
        ],
      ),
    );
  }
}
