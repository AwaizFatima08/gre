import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gre_prep/content/models.dart';
import 'package:gre_prep/ui/theme.dart';

/// Series colours, distinguishable in light and dark themes and for common colour-vision deficiencies.
const _palette = [
  Color(0xFF2E6FD8),
  Color(0xFFE08A1E),
  Color(0xFF2A9D6F),
  Color(0xFFB0457A),
  Color(0xFF7A5BD6),
];

/// A bar, line or pie chart from the question data, with a title, axis values and a legend.
class ChartView extends StatelessWidget {
  const ChartView({required this.spec, super.key});

  final ChartSpec spec;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;
    final pie = spec.kind == 'pie';
    final legend = pie
        ? [
            for (var i = 0; i < spec.labels.length; i++)
              (
                spec.labels[i],
                _palette[i % _palette.length],
                _num(spec.series.first.values[i], spec.unit),
              ),
          ]
        : spec.series.length > 1
        ? [
            for (var i = 0; i < spec.series.length; i++)
              (spec.series[i].name, _palette[i % _palette.length], ''),
          ]
        : <(String, Color, String)>[];
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(spec.title, style: theme.textTheme.titleSmall, textAlign: TextAlign.center),
            if (spec.unit case final unit? when !pie)
              Text('($unit)', style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              label: _describe(),
              child: AspectRatio(
                aspectRatio: pie ? 1.6 : 1.4,
                child: CustomPaint(
                  painter: switch (spec.kind) {
                    'pie' => _PiePainter(spec, ink),
                    'line' => _AxesPainter(spec, ink, line: true),
                    _ => _AxesPainter(spec, ink, line: false),
                  },
                ),
              ),
            ),
            if (legend.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final (label, colour, value) in legend)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 12, height: 12, color: colour),
                        const SizedBox(width: AppSpacing.xs),
                        Text(value.isEmpty ? label : '$label: $value'),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _describe() => [
    spec.title,
    for (final series in spec.series)
      '${series.name}: ${[for (var i = 0; i < spec.labels.length; i++) '${spec.labels[i]} ${_num(series.values[i], spec.unit)}'].join(', ')}',
  ].join('. ');
}

String _num(double value, String? unit) {
  final text = value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
  return unit == '%' ? '$text%' : text;
}

/// A tidy axis maximum and step: 1, 2, 2.5 or 5 times a power of ten.
(double, double) _niceScale(double max) {
  if (max <= 0) return (1, 0.25);
  final rough = max / 5;
  final power = math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
  final step = [1.0, 2.0, 2.5, 5.0, 10.0].map((f) => f * power).firstWhere((s) => s >= rough);
  return ((max / step).ceil() * step, step);
}

TextPainter _label(String text, Color colour, {double size = 11}) => TextPainter(
  text: TextSpan(
    text: text,
    style: TextStyle(color: colour, fontSize: size),
  ),
  textDirection: TextDirection.ltr,
)..layout(maxWidth: 80);

class _AxesPainter extends CustomPainter {
  _AxesPainter(this.spec, this.ink, {required this.line});

  final ChartSpec spec;
  final Color ink;
  final bool line;

  @override
  void paint(Canvas canvas, Size size) {
    final all = [for (final s in spec.series) ...s.values];
    final (top, step) = _niceScale(all.fold(0, math.max));
    const left = 40.0;
    const bottom = 30.0;
    final plot = Rect.fromLTRB(left, 8, size.width - 8, size.height - bottom);
    final grid = Paint()
      ..color = ink.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    final axis = Paint()
      ..color = ink.withValues(alpha: 0.7)
      ..strokeWidth = 1.2;
    for (var v = 0.0; v <= top + step / 2; v += step) {
      final y = plot.bottom - v / top * plot.height;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
      final tp = _label(_num(v, spec.unit), ink);
      tp.paint(canvas, Offset(plot.left - tp.width - 4, y - tp.height / 2));
    }
    canvas
      ..drawLine(plot.bottomLeft, plot.bottomRight, axis)
      ..drawLine(plot.bottomLeft, plot.topLeft, axis);
    final n = spec.labels.length;
    final slot = plot.width / n;
    for (var i = 0; i < n; i++) {
      final tp = _label(spec.labels[i], ink, size: n > 6 ? 9 : 11);
      tp.paint(canvas, Offset(plot.left + slot * (i + 0.5) - tp.width / 2, plot.bottom + 4));
    }
    for (var s = 0; s < spec.series.length; s++) {
      final colour = _palette[s % _palette.length];
      final values = spec.series[s].values;
      if (line) {
        final paint = Paint()
          ..color = colour
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;
        final path = Path();
        for (var i = 0; i < n; i++) {
          final point = Offset(
            plot.left + slot * (i + 0.5),
            plot.bottom - values[i] / top * plot.height,
          );
          i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
          canvas.drawCircle(point, 3.5, Paint()..color = colour);
        }
        canvas.drawPath(path, paint);
      } else {
        final groupWidth = slot * 0.75;
        final barWidth = groupWidth / spec.series.length;
        for (var i = 0; i < n; i++) {
          final x = plot.left + slot * i + (slot - groupWidth) / 2 + barWidth * s;
          final h = values[i] / top * plot.height;
          canvas.drawRect(
            Rect.fromLTWH(x, plot.bottom - h, barWidth * 0.9, h),
            Paint()..color = colour,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_AxesPainter old) => old.spec != spec || old.ink != ink;
}

class _PiePainter extends CustomPainter {
  _PiePainter(this.spec, this.ink);

  final ChartSpec spec;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final values = spec.series.first.values;
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return;
    final radius = math.min(size.width, size.height) / 2 - 4;
    final centre = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: centre, radius: radius);
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * math.pi;
      canvas
        ..drawArc(rect, start, sweep, true, Paint()..color = _palette[i % _palette.length])
        ..drawArc(
          rect,
          start,
          sweep,
          true,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      final mid = start + sweep / 2;
      if (sweep > 0.35) {
        final tp = _label(_num(values[i], spec.unit), Colors.white, size: 12);
        tp.paint(
          canvas,
          centre +
              Offset(math.cos(mid), math.sin(mid)) * radius * 0.62 -
              Offset(tp.width / 2, tp.height / 2),
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) => old.spec != spec;
}
