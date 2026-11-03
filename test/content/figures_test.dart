import 'dart:convert';
import 'dart:io';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every geometry figure must parse with the SVG library the app draws it with.
void main() {
  final bank =
      jsonDecode(File('assets/data/bank_quant.json').readAsStringSync()) as Map<String, Object?>;
  final figures = {
    for (final raw in (bank['questions']! as List<Object?>).cast<Map<String, Object?>>())
      if (raw['fg'] case final String svg) raw['id']! as String: svg,
  };

  testWidgets('all figures load', (tester) async {
    expect(figures, isNotEmpty);
    await tester.runAsync(() async {
      for (final MapEntry(:key, :value) in figures.entries) {
        try {
          final info = await vg.loadPicture(SvgStringLoader(value), null);
          expect(info.size.width, greaterThan(0), reason: key);
          info.picture.dispose();
        } on Object catch (error) {
          fail('$key: $error');
        }
      }
    });
  });
}
