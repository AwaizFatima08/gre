import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gre_prep/ads/ad_service.dart';
import 'package:gre_prep/app.dart';
import 'package:gre_prep/content/content_repository.dart';
import 'package:gre_prep/content/models.dart';
import 'package:gre_prep/core/scoring.dart';
import 'package:gre_prep/features/exam/exam_notifier.dart';
import 'package:gre_prep/ui/async_value_view.dart';
import 'package:gre_prep/ui/theme.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({required this.attemptId, super.key});

  final String attemptId;

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  Future<void> _home() async {
    await ref.read(adServiceProvider).showReportInterstitial();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AsyncValueView(
      value: ref.watch(reviewProvider(widget.attemptId)),
      data: (exam) {
        final result = scoreSitting(exam.sitting, exam.attempt.responses);
        final measures = [
          for (final key in ['verbal', 'quant']) result.measures[key]!,
        ];
        return Scaffold(
          appBar: AppBar(title: Text(exam.sitting.paper.title)),
          body: ListView(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            children: [
              _ScoreCard(measures: measures, essayScore: exam.attempt.essaySelfScore),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => unawaited(context.push('/review/${widget.attemptId}')),
                icon: const Icon(Icons.menu_book_outlined),
                label: Text(l10n.reviewAnswers),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => unawaited(context.push('/essay/${widget.attemptId}')),
                icon: const Icon(Icons.edit_note),
                label: Text(
                  exam.attempt.essaySelfScore == null ? l10n.rateEssay : l10n.essayAndModel,
                ),
              ),
              for (final measure in measures) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _measureTitle(context, measure.key),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _ScoreRow(l10n.sectionN(1), measure.first),
                _ScoreRow(
                  '${l10n.sectionN(2)} · ${measure.hardRoute ? l10n.routeHard : l10n.routeEasy}',
                  measure.second,
                ),
                if (measure.skipped > 0)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: AppSpacing.xs),
                    child: Text(
                      l10n.skippedCount(measure.skipped),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.byType, style: Theme.of(context).textTheme.titleMedium),
              for (final MapEntry(:key, :value) in result.types.entries)
                _ScoreRow(
                  '${_measureTitle(context, key.split('/').first)}: ${typeTitle(QuestionType.parse(key.split('/').last))}',
                  value,
                ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.weakTopics, style: Theme.of(context).textTheme.titleMedium),
              _WeakTopics(result: result),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.scoreDisclaimer, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(onPressed: () => unawaited(_home()), child: Text(l10n.backHome)),
            ],
          ),
        );
      },
    );
  }
}

String _measureTitle(BuildContext context, String key) =>
    key == 'verbal' ? context.l10n.measureVerbal : context.l10n.measureQuant;

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.measures, required this.essayScore});

  final List<MeasureResult> measures;
  final double? essayScore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          children: [
            Text(l10n.estimatedScores, style: theme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                for (final measure in measures)
                  Expanded(
                    child: Column(
                      children: [
                        Text(_measureTitle(context, measure.key), textAlign: TextAlign.center),
                        Text('${measure.scaled}', style: theme.displaySmall),
                        Text(
                          l10n.scoreRange(
                            scoreBand(measure.scaled).$1,
                            scoreBand(measure.scaled).$2,
                          ),
                          style: theme.bodySmall,
                        ),
                        Text(
                          l10n.scoreOutOf(measure.overall.correct, measure.overall.total),
                          style: theme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      Text(l10n.measureWritingShort, textAlign: TextAlign.center),
                      Text(
                        essayScore == null ? '–' : essayScore!.toStringAsFixed(1),
                        style: theme.displaySmall,
                      ),
                      Text(
                        essayScore == null ? l10n.notRated : l10n.selfRated,
                        style: theme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.totalScore(measures.fold(0, (sum, m) => sum + m.scaled)),
              style: theme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow(this.title, this.tally);

  final String title;
  final Tally tally;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(top: AppSpacing.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(title)),
            Text(context.l10n.scoreOutOf(tally.correct, tally.total)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(value: tally.percent / 100),
      ],
    ),
  );
}

class _WeakTopics extends ConsumerWidget {
  const _WeakTopics({required this.result});

  final MockResult result;

  static const _shown = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncBody(
    value: ref.watch(catalogProvider),
    data: (catalog) => Column(
      children: [
        for (final topic in result.topics.take(_shown))
          InkWell(
            onTap: () => unawaited(context.push('/topic/${topic.section}/${topic.topic}')),
            child: _ScoreRow(catalog.topicTitle(topic.section, topic.topic), topic.tally),
          ),
      ],
    ),
  );
}
