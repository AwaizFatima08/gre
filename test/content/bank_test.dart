import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gre_prep/content/models.dart';

/// Checks the built assets: 20 mocks in the GRE pattern, test-pool questions only, no repeats.
void main() {
  final forms = jsonDecode(File('assets/data/forms.json').readAsStringSync()) as List<Object?>;
  final papers = [for (final form in forms) Paper.fromJson(form! as Json)];
  final catalog = Catalog.fromJson(
    jsonDecode(File('assets/data/catalog.json').readAsStringSync()) as Json,
  );
  final questions = <String, Question>{};
  for (final section in ['verbal', 'quant', 'writing']) {
    final json = jsonDecode(File('assets/data/bank_$section.json').readAsStringSync()) as Json;
    for (final raw in json['questions']! as List<Object?>) {
      final question = Question.fromJson(raw! as Json, section);
      questions[question.id] = question;
    }
  }

  test('there are 20 mocks with 12 + 15 questions per measure and an essay', () {
    expect(papers, hasLength(20));
    for (final paper in papers) {
      expect(questions[paper.essayId]?.type, QuestionType.essay, reason: paper.id);
      for (final key in ['verbal', 'quant']) {
        final measure = paper.measures[key]!;
        final counts = catalog.measure(key).counts;
        expect(measure.first, hasLength(counts[0]), reason: '${paper.id} $key');
        expect(measure.easy, hasLength(counts[1]), reason: '${paper.id} $key');
        expect(measure.hard, hasLength(counts[1]), reason: '${paper.id} $key');
      }
    }
  });

  test('every mock question is from the test pool and used once across all mocks', () {
    final ids = [
      for (final paper in papers)
        for (final measure in paper.measures.values) ...[
          ...measure.first,
          ...measure.easy,
          ...measure.hard,
        ],
    ];
    expect(ids.toSet(), hasLength(ids.length));
    for (final id in ids) {
      expect(questions[id]?.isPractice, isFalse, reason: id);
    }
  });

  test('the harder section 2 is harder than the easier one', () {
    for (final paper in papers) {
      for (final measure in paper.measures.values) {
        double mean(List<String> ids) =>
            ids.map((id) => questions[id]!.level).reduce((a, b) => a + b) / ids.length;
        expect(mean(measure.hard), greaterThan(mean(measure.easy) + 0.8), reason: paper.id);
      }
    }
  });

  test('every key is usable', () {
    for (final question in questions.values) {
      switch (question.type) {
        case QuestionType.ne:
          expect(question.numeric, isNotNull, reason: question.id);
        case QuestionType.essay:
          expect(question.points, isNotEmpty, reason: question.id);
        case _:
          expect(question.answer, isNotEmpty, reason: question.id);
          for (final index in question.answer) {
            expect(index, inInclusiveRange(0, question.options.length - 1), reason: question.id);
          }
      }
    }
  });
}
