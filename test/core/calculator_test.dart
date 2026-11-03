import 'package:flutter_test/flutter_test.dart';
import 'package:gre_prep/features/exam/calculator.dart';

void main() {
  test('follows the order of operations', () {
    expect(evaluateExpression('2+3×4'), 14);
    expect(evaluateExpression('(2+3)×4'), 20);
    expect(evaluateExpression('10÷4'), 2.5);
    expect(evaluateExpression('√16+1'), 5);
    expect(evaluateExpression('-3×-2'), 6);
  });

  test('rejects invalid input', () {
    expect(evaluateExpression('2+'), isNull);
    expect(evaluateExpression('5÷0'), isNull);
    expect(evaluateExpression('√-4'), isNull);
  });

  test('formats results without trailing zeros', () {
    expect(formatResult(2.5), '2.5');
    expect(formatResult(3), '3');
    expect(formatResult(1 / 3), '0.33333333');
  });
}
