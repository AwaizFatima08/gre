import 'package:flutter/material.dart';
import 'package:gre_prep/app.dart';
import 'package:gre_prep/content/models.dart';
import 'package:gre_prep/ui/theme.dart';

int essayWords(String text) => text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;

/// Suggested 0-6 score from the criteria met, capped for short essays (raters reward developed responses).
double suggestEssayScore(int criteriaMet, int words) {
  if (words == 0) return 0;
  final cap = words < 150 ? 2.0 : (words < 300 ? 4.0 : 6.0);
  final base = criteriaMet == 0 ? 1.0 : criteriaMet.toDouble();
  return base > cap ? cap : base;
}

/// The candidate's essay beside the strong-response points and the model essay, with a self-rating
/// against six plain-English criteria. No automatic scoring: the candidate rates honestly.
class EssayAssessment extends StatefulWidget {
  const EssayAssessment({
    required this.prompt,
    required this.essay,
    required this.initialScore,
    required this.onScore,
    super.key,
  });

  final Question prompt;
  final String essay;
  final double? initialScore;
  final ValueChanged<double> onScore;

  @override
  State<EssayAssessment> createState() => _EssayAssessmentState();
}

class _EssayAssessmentState extends State<EssayAssessment> {
  final _met = <int>{};
  late double? _score = widget.initialScore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context).textTheme;
    final words = essayWords(widget.essay);
    final criteria = [
      l10n.criterionPosition,
      l10n.criterionReasons,
      l10n.criterionOrganisation,
      l10n.criterionTask,
      l10n.criterionLanguage,
      l10n.criterionMechanics,
    ];
    final suggested = suggestEssayScore(_met.length, words);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.prompt.stem, style: theme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(widget.prompt.task ?? '', style: theme.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.yourEssay, style: theme.titleMedium),
        Text(l10n.wordCount(words), style: theme.bodySmall),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            widget.essay.trim().isEmpty ? l10n.essayEmpty : widget.essay,
            style: const TextStyle(height: 1.5),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.strongResponse, style: theme.titleMedium),
        for (final point in widget.prompt.points)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: Text(point, style: const TextStyle(height: 1.4))),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        ExpansionTile(
          tilePadding: EdgeInsetsDirectional.zero,
          title: Text(l10n.modelEssay, style: theme.titleMedium),
          subtitle: Text(l10n.modelEssayNote),
          children: [
            SelectableText(widget.prompt.explanation, style: const TextStyle(height: 1.55)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.rateYourself, style: theme.titleMedium),
        Text(l10n.rateYourselfHelp, style: theme.bodySmall),
        for (var i = 0; i < criteria.length; i++)
          CheckboxListTile(
            contentPadding: EdgeInsetsDirectional.zero,
            value: _met.contains(i),
            title: Text(criteria[i]),
            onChanged: (value) => setState(() => value! ? _met.add(i) : _met.remove(i)),
          ),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.suggestedScore(suggested.toStringAsFixed(1))),
        Slider(
          value: _score ?? suggested,
          max: 6,
          divisions: 12,
          label: (_score ?? suggested).toStringAsFixed(1),
          onChanged: (value) => setState(() => _score = value),
        ),
        FilledButton(
          onPressed: () {
            final score = _score ?? suggested;
            setState(() => _score = score);
            widget.onScore(score);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.scoreSaved)));
          },
          child: Text(l10n.saveScore((_score ?? suggested).toStringAsFixed(1))),
        ),
      ],
    );
  }
}
