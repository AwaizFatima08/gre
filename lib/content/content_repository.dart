import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gre_prep/content/models.dart';
import 'package:gre_prep/core/result.dart';

/// Reads a bundled text asset. Swapped in tests.
typedef AssetReader = Future<String> Function(String path);

class SectionBank {
  const SectionBank({required this.questions, required this.sets});

  final List<Question> questions;
  final Map<String, QuestionSet> sets;
}

SectionBank _parseBank((String, String) input) {
  final (raw, section) = input;
  final json = jsonDecode(raw) as Json;
  return SectionBank(
    questions: [
      for (final item in json['questions']! as List<Object?>)
        Question.fromJson(item! as Json, section),
    ],
    sets: {
      for (final entry in (json['sets']! as Json).entries)
        entry.key: QuestionSet.fromJson(entry.value! as Json),
    },
  );
}

/// Bundled content. Banks load on demand and stay cached for the session.
class ContentRepository {
  ContentRepository(this._read);

  final AssetReader _read;
  final _banks = <String, Future<SectionBank>>{};

  Future<Object> _json(String name) async => jsonDecode(await _read('assets/data/$name')) as Object;

  Future<Catalog> catalog() async => Catalog.fromJson(await _json('catalog.json') as Json);

  Future<List<Paper>> papers() async => [
    for (final item in await _json('forms.json') as List<Object?>) Paper.fromJson(item! as Json),
  ];

  Future<List<GuideArticle>> guide() async => [
    for (final item in (await _json('guide.json') as Json)['articles']! as List<Object?>)
      GuideArticle.fromJson(item! as Json),
  ];

  Future<List<Lesson>> lessons() async => [
    for (final item in await _json('lessons.json') as List<Object?>) Lesson.fromJson(item! as Json),
  ];

  Future<List<VocabWord>> vocab() async => [
    for (final item in await _json('vocab.json') as List<Object?>)
      VocabWord.fromJson(item! as Json),
  ];

  Future<SectionBank> bank(String section) => _banks[section] ??= () async {
    final raw = await _read('assets/data/bank_$section.json');
    return compute(_parseBank, (raw, section));
  }();

  /// Everything needed to run or review [paper]; section 2 of a measure appears once [routes] names it.
  Future<Result<Sitting, ContentFailure>> sitting(
    Paper paper,
    Catalog catalog, {
    required Map<String, String> routes,
  }) async {
    try {
      final questions = <String, Question>{};
      final sets = <String, QuestionSet>{};
      for (final section in ['writing', ...paper.order]) {
        final bank = await this.bank(section);
        for (final question in bank.questions) {
          if (!question.isPractice) questions[question.id] = question;
        }
        sets.addAll(bank.sets);
      }
      final stages = buildStages(paper, catalog, routes);
      for (final stage in stages) {
        for (final id in stage.itemIds) {
          if (!questions.containsKey(id)) return Err(ContentFailure('missing-question:$id'));
        }
      }
      return Ok(Sitting(paper: paper, stages: stages, questions: questions, sets: sets));
    } on FormatException catch (error) {
      return Err(ContentFailure('bad-bank', cause: error));
    } on Exception catch (error) {
      return Err(ContentFailure('missing-bank', cause: error));
    }
  }
}

enum StageKind { essay, section }

/// One timed part of a mock: the essay, or one section of a measure.
class Stage {
  const Stage({
    required this.kind,
    required this.measure,
    required this.part,
    required this.minutes,
    required this.itemIds,
    this.route,
  });

  final StageKind kind;

  /// `writing`, `verbal` or `quant`.
  final String measure;

  /// 1 or 2 within the measure.
  final int part;
  final int minutes;

  /// Empty for a section 2 whose route is not decided yet.
  final List<String> itemIds;

  /// `easy` or `hard` for section 2.
  final String? route;

  bool get isEssay => kind == StageKind.essay;
}

/// The essay, then for each measure in the paper's order, section 1 and the routed section 2.
List<Stage> buildStages(Paper paper, Catalog catalog, Map<String, String> routes) => [
  Stage(
    kind: StageKind.essay,
    measure: 'writing',
    part: 1,
    minutes: catalog.writingMinutes,
    itemIds: [paper.essayId],
  ),
  for (final key in paper.order) ...[
    Stage(
      kind: StageKind.section,
      measure: key,
      part: 1,
      minutes: catalog.measure(key).minutes[0],
      itemIds: paper.measures[key]!.first,
    ),
    Stage(
      kind: StageKind.section,
      measure: key,
      part: 2,
      minutes: catalog.measure(key).minutes[1],
      route: routes[key],
      itemIds: switch (routes[key]) {
        'hard' => paper.measures[key]!.hard,
        'easy' => paper.measures[key]!.easy,
        _ => const [],
      },
    ),
  ],
];

/// Everything needed to run or review one paper.
class Sitting {
  const Sitting({
    required this.paper,
    required this.stages,
    required this.questions,
    required this.sets,
  });

  final Paper paper;
  final List<Stage> stages;
  final Map<String, Question> questions;
  final Map<String, QuestionSet> sets;

  Question get essay => questions[paper.essayId]!;

  List<Question> questionsOf(Stage stage) => [for (final id in stage.itemIds) questions[id]!];
}

final assetReaderProvider = Provider<AssetReader>((ref) => rootBundle.loadString);

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(ref.watch(assetReaderProvider)),
);

final catalogProvider = FutureProvider<Catalog>(
  (ref) => ref.watch(contentRepositoryProvider).catalog(),
);

final papersProvider = FutureProvider<List<Paper>>(
  (ref) => ref.watch(contentRepositoryProvider).papers(),
);

final guideProvider = FutureProvider<List<GuideArticle>>(
  (ref) => ref.watch(contentRepositoryProvider).guide(),
);

final lessonsProvider = FutureProvider<List<Lesson>>(
  (ref) => ref.watch(contentRepositoryProvider).lessons(),
);

final vocabProvider = FutureProvider<List<VocabWord>>(
  (ref) => ref.watch(contentRepositoryProvider).vocab(),
);

final bankProvider = FutureProvider.family<SectionBank, String>(
  (ref, section) => ref.watch(contentRepositoryProvider).bank(section),
);
