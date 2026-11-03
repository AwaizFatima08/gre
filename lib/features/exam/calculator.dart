import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gre_prep/app.dart';
import 'package:gre_prep/ui/theme.dart';

/// Evaluates a calculator expression with the usual order of operations: + − × ÷, brackets,
/// √ (applies to the number or bracket after it) and unary minus. Returns null for invalid input.
double? evaluateExpression(String input) {
  final tokens = RegExp(r'\d*\.?\d+|[+\-×÷()√]').allMatches(input).map((m) => m.group(0)!).toList();
  var pos = 0;
  String? peek() => pos < tokens.length ? tokens[pos] : null;

  late final double? Function() expression;

  double? factor() {
    final token = peek();
    if (token == null) return null;
    if (token == '-') {
      pos++;
      final value = factor();
      return value == null ? null : -value;
    }
    if (token == '√') {
      pos++;
      final value = factor();
      return value == null || value < 0 ? null : math.sqrt(value);
    }
    if (token == '(') {
      pos++;
      final value = expression();
      if (peek() == ')') pos++;
      return value;
    }
    pos++;
    return double.tryParse(token);
  }

  double? term() {
    var value = factor();
    while (value != null && (peek() == '×' || peek() == '÷')) {
      final op = tokens[pos++];
      final right = factor();
      if (right == null || (op == '÷' && right == 0)) return null;
      value = op == '×' ? value * right : value / right;
    }
    return value;
  }

  expression = () {
    var value = term();
    while (value != null && (peek() == '+' || peek() == '-')) {
      final op = tokens[pos++];
      final right = term();
      if (right == null) return null;
      value = op == '+' ? value + right : value - right;
    }
    return value;
  };

  final result = expression();
  return pos == tokens.length ? result : null;
}

/// Display text of a result: up to 8 decimal places, no trailing zeros.
String formatResult(double value) {
  if (value.isNaN || value.isInfinite) return 'Error';
  final fixed = value.toStringAsFixed(8);
  return fixed.contains('.') ? fixed.replaceFirst(RegExp(r'\.?0+$'), '') : fixed;
}

/// The on-screen calculator of the Quantitative sections. [onTransfer] copies the display into a numeric entry box.
class CalculatorSheet extends StatefulWidget {
  const CalculatorSheet({this.onTransfer, super.key});

  final ValueChanged<String>? onTransfer;

  @override
  State<CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<CalculatorSheet> {
  String _input = '';
  String _display = '0';
  double _memory = 0;

  void _press(String key) => setState(() {
    switch (key) {
      case 'C':
        _input = '';
        _display = '0';
      case 'CE':
        if (_input.isNotEmpty) _input = _input.substring(0, _input.length - 1);
        _display = _input.isEmpty ? '0' : _input;
      case '=':
        final value = evaluateExpression(_input.replaceAll('−', '-'));
        _display = value == null ? 'Error' : formatResult(value);
        _input = value == null ? '' : _display;
      case '±':
        _input = _input.startsWith('−(') && _input.endsWith(')')
            ? _input.substring(2, _input.length - 1)
            : '−($_input)';
        _display = _input;
      case 'MC':
        _memory = 0;
      case 'MR':
        _input += formatResult(_memory);
        _display = _input;
      case 'M+':
        final value = evaluateExpression(_input.replaceAll('−', '-'));
        if (value != null) _memory += value;
      default:
        _input += key;
        _display = _input;
    }
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const rows = [
      ['MC', 'MR', 'M+', 'C', 'CE'],
      ['7', '8', '9', '÷', '√'],
      ['4', '5', '6', '×', '('],
      ['1', '2', '3', '−', ')'],
      ['0', '.', '±', '+', '='],
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _display,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 26, fontFeatures: [FontFeature.tabularFigures()]),
              ),
            ),
            if (_memory != 0)
              Text('M = ${formatResult(_memory)}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            for (final row in rows)
              Row(
                children: [
                  for (final key in row)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.all(3),
                        child: FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsetsDirectional.symmetric(vertical: 14),
                          ),
                          onPressed: () => _press(key == '−' ? '−' : key),
                          child: Text(key, style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                    ),
                ],
              ),
            if (widget.onTransfer != null) ...[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: _display == 'Error' ? null : () => widget.onTransfer!(_display),
                child: Text(context.l10n.transferDisplay),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
