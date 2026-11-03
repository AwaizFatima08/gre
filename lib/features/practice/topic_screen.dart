import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gre_prep/app.dart';
import 'package:gre_prep/content/content_repository.dart';
import 'package:gre_prep/settings/settings_repository.dart';
import 'package:gre_prep/ui/async_value_view.dart';
import 'package:gre_prep/ui/rich_lines.dart';
import 'package:gre_prep/ui/theme.dart';

/// One topic: its lesson, a practice set (or essay prompts for writing) and the candidate's record.
class TopicScreen extends ConsumerWidget {
  const TopicScreen({required this.section, required this.topic, super.key});

  final String section;
  final String topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tally = ref.watch(practiceTallyProvider).value?['$section/$topic'];
    return AsyncValueView(
      value: ref.watch(catalogProvider),
      data: (catalog) {
        final info = catalog.sections
            .firstWhere((s) => s.key == section)
            .topics
            .firstWhere((t) => t.key == topic);
        return Scaffold(
          appBar: AppBar(title: Text(info.title)),
          body: ListView(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            children: [
              if (info.hasLesson)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.school_outlined),
                    title: Text(l10n.lesson),
                    subtitle: Text(l10n.lessonHelp),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => unawaited(context.push('/lesson/$topic')),
                  ),
                ),
              if (section == 'writing')
                _EssayPrompts(onPick: (id) => unawaited(context.push('/write/$id')))
              else ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.fitness_center),
                    title: Text(l10n.practiceSet),
                    subtitle: Text(
                      tally == null
                          ? l10n.practicePool(info.practiceCount)
                          : '${l10n.practicePool(info.practiceCount)} · ${l10n.practiceTally(tally[0], tally[1])}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => unawaited(context.push('/practice/$section/$topic')),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _EssayPrompts extends ConsumerWidget {
  const _EssayPrompts({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncBody(
    value: ref.watch(bankProvider('writing')),
    data: (bank) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.sm),
          child: Text(context.l10n.essayPracticeIntro),
        ),
        for (final prompt in bank.questions.where((q) => q.isPractice))
          Card(
            child: ListTile(
              title: Text(prompt.stem, maxLines: 3, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.edit_note),
              onTap: () => onPick(prompt.id),
            ),
          ),
      ],
    ),
  );
}

class LessonScreen extends ConsumerWidget {
  const LessonScreen({required this.topic, super.key});

  final String topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(lessonsProvider),
    data: (lessons) {
      final lesson = lessons.firstWhere((l) => l.topic == topic);
      return Scaffold(
        appBar: AppBar(title: Text(lesson.title)),
        body: ListView(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          children: [
            Text(
              context.l10n.readingTime(lesson.minutes),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            RichLines(lesson.lines),
            const SizedBox(height: AppSpacing.lg),
            if (lesson.section != 'writing')
              FilledButton(
                onPressed: () => context.pushReplacement('/practice/${lesson.section}/$topic'),
                child: Text(context.l10n.practiceNow),
              ),
          ],
        ),
      );
    },
  );
}
