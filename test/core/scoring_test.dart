import 'package:flutter_test/flutter_test.dart';
import 'package:gre_prep/content/models.dart';
import 'package:gre_prep/core/grading.dart';
import 'package:gre_prep/core/scoring.dart';

import '../support.dart';

void main() {
  group('grading', () {
    test('text completion needs every blank right', () {
      final q = question(
        'tc',
        type: QuestionType.tc,
        blanks: const [3, 3],
        answer: const [1, 4],
        options: const ['a', 'b', 'c', 'd', 'e', 'f'],
      );
      expect(isCorrect(q, '1,4'), isTrue);
      expect(isCorrect(q, '1,3'), isFalse);
      expect(isCorrect(q, '1'), isFalse);
      // Picking in a blank replaces the earlier pick in that blank only.
      expect(Responses.toggle(q, '0,4', 2), '2,4');
    });

    test('sentence equivalence needs both answers and keeps at most two picks', () {
      final q = question(
        'se',
        type: QuestionType.se,
        answer: const [0, 3],
        options: const ['a', 'b', 'c', 'd', 'e', 'f'],
      );
      expect(isCorrect(q, '0,3'), isTrue);
      expect(isCorrect(q, '0'), isFalse);
      expect(Responses.toggle(q, '0,3', 5), '0,3');
      expect(Responses.isAnswered(q, '0'), isFalse);
    });

    test('select all needs exactly the correct set', () {
      final q = question(
        'ma',
        type: QuestionType.ma,
        answer: const [0, 2],
        options: const ['a', 'b', 'c'],
      );
      expect(isCorrect(q, '0,2'), isTrue);
      expect(isCorrect(q, '0,1,2'), isFalse);
      expect(Responses.toggle(q, '0,2', 2), '0');
    });

    test('numeric entry accepts equivalent values and fractions', () {
      final decimal = question('ne', type: QuestionType.ne, numeric: '2.5', options: const []);
      expect(isCorrect(decimal, '2.50'), isTrue);
      expect(isCorrect(decimal, '2.4'), isFalse);
      expect(isCorrect(decimal, 'abc'), isFalse);
      final fraction = question('nf', type: QuestionType.ne, numeric: '3/8', options: const []);
      expect(isCorrect(fraction, '6/16'), isTrue);
      expect(isCorrect(fraction, '3/0'), isFalse);
    });
  });

  group('scaled score estimate', () {
    test('a perfect hard route reaches 170; the easy route is capped', () {
      expect(estimateScaled(correct: 27, total: 27, hardRoute: true), 170);
      expect(estimateScaled(correct: 21, total: 27, hardRoute: false), lessThanOrEqualTo(157));
      expect(estimateScaled(correct: 0, total: 27, hardRoute: false), 130);
    });

    test('more correct answers never lower the estimate', () {
      for (final hard in [true, false]) {
        for (var c = 1; c <= 27; c++) {
          expect(
            estimateScaled(correct: c, total: 27, hardRoute: hard),
            greaterThanOrEqualTo(estimateScaled(correct: c - 1, total: 27, hardRoute: hard)),
          );
        }
      }
    });
  });

  test('scores each measure from section 1 and the routed section 2', () {
    final sitting = sittingOf(routes: const {'verbal': 'hard', 'quant': 'easy'});
    final result = scoreSitting(sitting, const {
      'verbal-s1-1': '0',
      'verbal-s1-2': '0',
      'verbal-hard-1': '0',
      'quant-s1-1': '1',
      'quant-easy-1': '0',
    });
    final verbal = result.measures['verbal']!;
    final quant = result.measures['quant']!;
    expect(verbal.hardRoute, isTrue);
    expect(verbal.overall.correct, 3);
    expect(verbal.skipped, 1);
    expect(quant.hardRoute, isFalse);
    expect(quant.first.correct, 0);
    expect(quant.second.correct, 1);
    expect(firstSectionCorrect(sitting, 'verbal', const {'verbal-s1-1': '0'}), 1);
  });

  test('stages run essay, then each measure in paper order; section 2 waits for its route', () {
    final stages = sittingOf(routes: const {}).stages;
    expect(
      [for (final s in stages) '${s.measure}${s.part}'],
      ['writing1', 'verbal1', 'verbal2', 'quant1', 'quant2'],
    );
    expect(stages[2].itemIds, isEmpty);
    expect(sittingOf(routes: const {'verbal': 'easy'}).stages[2].itemIds, [
      'verbal-easy-1',
      'verbal-easy-2',
    ]);
  });
}
