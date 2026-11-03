import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gre_prep/app.dart';
import 'package:gre_prep/content/models.dart';
import 'package:gre_prep/core/grading.dart';
import 'package:gre_prep/ui/chart_view.dart';
import 'package:gre_prep/ui/theme.dart';

final _blank = RegExp('_{3,}');

/// Text with ⟦bracketed⟧ portions in bold, as GRE argument questions highlight them.
class MarkedText extends StatelessWidget {
  const MarkedText(this.text, {this.style, super.key});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (!text.contains('⟦')) return SelectableText(text, style: style);
    final spans = <TextSpan>[];
    final pattern = RegExp('⟦(.*?)⟧', dotAll: true);
    var last = 0;
    for (final match in pattern.allMatches(text)) {
      spans
        ..add(TextSpan(text: text.substring(last, match.start)))
        ..add(
          TextSpan(
            text: match.group(1),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      last = match.end;
    }
    spans.add(TextSpan(text: text.substring(last)));
    return SelectableText.rich(TextSpan(style: style, children: spans));
  }
}

/// Shared passage or data display, collapsible so the question stays in view.
class SetPanel extends StatefulWidget {
  const SetPanel({required this.set, this.startOpen = true, super.key});

  final QuestionSet set;
  final bool startOpen;

  @override
  State<SetPanel> createState() => _SetPanelState();
}

class _SetPanelState extends State<SetPanel> {
  late bool _open = widget.startOpen;

  @override
  Widget build(BuildContext context) {
    final set = widget.set;
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              set.isData ? context.l10n.dataTitle : context.l10n.passageTitle,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            if (_open) ...[
              const SizedBox(height: AppSpacing.sm),
              MarkedText(set.text, style: const TextStyle(height: 1.5, fontSize: 15.5)),
              if (set.table case final rows?) QuestionTable(rows: rows),
              if (set.chart case final chart?) ChartView(spec: chart),
              if (set.chart2 case final chart?) ChartView(spec: chart),
            ],
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => setState(() => _open = !_open),
                child: Text(
                  _open
                      ? (set.isData ? context.l10n.hideData : context.l10n.hidePassage)
                      : (set.isData ? context.l10n.showData : context.l10n.readPassage),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionTable extends StatelessWidget {
  const QuestionTable({required this.rows, super.key});

  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.sm),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 40,
        dataRowMinHeight: 32,
        dataRowMaxHeight: 48,
        columnSpacing: 20,
        border: TableBorder.all(color: Theme.of(context).colorScheme.outlineVariant),
        columns: [
          for (final cell in rows.first)
            DataColumn(
              label: Text(cell, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
        rows: [
          for (final row in rows.skip(1))
            DataRow(cells: [for (final cell in row) DataCell(Text(cell))]),
        ],
      ),
    ),
  );
}

/// A geometry figure drawn from SVG, inked to suit light and dark themes.
class FigureView extends StatelessWidget {
  const FigureView({required this.svg, super.key});

  final String svg;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.sm),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 260),
        // Figures are drawn black on white, as on the test; keep that card in dark mode too.
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
            child: SvgPicture.string(svg),
          ),
        ),
      ),
    ),
  );
}

/// The passage or data (if any), figure, stem and, for quantitative comparison, the two quantities.
class QuestionHeader extends StatelessWidget {
  const QuestionHeader({
    required this.question,
    this.set,
    this.response,
    this.passageOpen = true,
    super.key,
  });

  final Question question;
  final QuestionSet? set;

  /// For text completion, the chosen words are shown in the blanks.
  final String? response;

  /// Whether a shared passage starts expanded; collapsed in review, where it repeats.
  final bool passageOpen;

  String _stem() {
    if (question.type != QuestionType.tc) return question.stem;
    final chosen = Responses.choices(response);
    var blank = 0;
    return question.stem.replaceAllMapped(_blank, (match) {
      final pick = chosen.where((i) => question.blankOf(i) == blank).firstOrNull;
      blank++;
      return pick == null ? match.group(0)! : '[ ${question.options[pick]} ]';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (set case final panel?)
          SetPanel(key: ValueKey(question.setId), set: panel, startOpen: passageOpen),
        if (question.table case final rows?) QuestionTable(rows: rows),
        if (question.chart case final chart?) ChartView(spec: chart),
        if (question.chart2 case final chart?) ChartView(spec: chart),
        const SizedBox(height: AppSpacing.sm),
        if (question.stem.isNotEmpty)
          MarkedText(_stem(), style: theme.titleMedium?.copyWith(height: 1.45)),
        if (question.figure case final svg?) FigureView(svg: svg),
        if (question.type == QuestionType.qc) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _QuantityBox(context.l10n.quantityA, question.quantityA ?? '')),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _QuantityBox(context.l10n.quantityB, question.quantityB ?? '')),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(_instruction(context), style: theme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  String _instruction(BuildContext context) {
    final l10n = context.l10n;
    return switch (question.type) {
      QuestionType.tc => question.blanks.length == 1 ? l10n.pickOne : l10n.pickPerBlank,
      QuestionType.se => l10n.pickTwo,
      QuestionType.ma => l10n.pickAll,
      QuestionType.sip => l10n.pickSentence,
      QuestionType.ne => question.isFractionEntry ? l10n.enterFraction : l10n.enterNumber,
      QuestionType.essay => '',
      _ => l10n.pickOne,
    };
  }
}

class _QuantityBox extends StatelessWidget {
  const _QuantityBox(this.title, this.text);

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outline),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
      ],
    ),
  );
}

/// How an option should look once answers are revealed.
enum OptionMark { none, selected, correct, missed, wrong }

/// The answer controls for any question type. Read-only when [onChanged] is null;
/// with [reveal], marks the key and the candidate's mistakes.
class AnswerArea extends StatelessWidget {
  const AnswerArea({
    required this.question,
    required this.response,
    this.onChanged,
    this.reveal = false,
    super.key,
  });

  final Question question;
  final String? response;
  final ValueChanged<String>? onChanged;
  final bool reveal;

  OptionMark _mark(int index, Set<int> chosen) {
    final picked = chosen.contains(index);
    if (!reveal) return picked ? OptionMark.selected : OptionMark.none;
    final key = question.answer.contains(index);
    if (key) return picked ? OptionMark.correct : OptionMark.missed;
    return picked ? OptionMark.wrong : OptionMark.none;
  }

  @override
  Widget build(BuildContext context) {
    if (question.type == QuestionType.ne) {
      return NumericEntry(
        key: ValueKey('ne-${question.id}'),
        question: question,
        response: response,
        onChanged: reveal ? null : onChanged,
        reveal: reveal,
      );
    }
    final chosen = Responses.choices(response);
    final square = question.type == QuestionType.ma || question.type == QuestionType.se;
    Widget tile(int i, {String? letter}) => OptionTile(
      letter: letter ?? String.fromCharCode(65 + i),
      text: question.options[i],
      mark: _mark(i, chosen),
      square: square,
      onTap: onChanged == null || reveal
          ? null
          : () => onChanged!(Responses.toggle(question, response, i)),
    );
    if (question.type == QuestionType.tc && question.blanks.length > 1) {
      const numerals = ['i', 'ii', 'iii'];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var b = 0; b < question.blanks.length; b++) ...[
            Padding(
              padding: const EdgeInsetsDirectional.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
              child: Text(
                context.l10n.blankLabel(numerals[b]),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            for (
              var i = question.blankStart(b);
              i < question.blankStart(b) + question.blanks[b];
              i++
            )
              tile(i, letter: String.fromCharCode(65 + i)),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (var i = 0; i < question.options.length; i++) tile(i)],
    );
  }
}

/// One answer row: a lettered circle (one answer) or square (several answers), like the GRE screen.
class OptionTile extends StatelessWidget {
  const OptionTile({
    required this.letter,
    required this.text,
    required this.mark,
    this.square = false,
    this.onTap,
    super.key,
  });

  final String letter;
  final String text;
  final OptionMark mark;
  final bool square;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colour = switch (mark) {
      OptionMark.none => scheme.outline,
      OptionMark.selected => scheme.primary,
      OptionMark.correct || OptionMark.missed => AppColors.correct,
      OptionMark.wrong => AppColors.incorrect,
    };
    final filled =
        mark == OptionMark.selected || mark == OptionMark.correct || mark == OptionMark.wrong;
    final shape = square
        ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
        : const CircleBorder();
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Semantics(
          selected: filled,
          button: onTap != null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border.all(color: colour, width: mark == OptionMark.none ? 1 : 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    shape: shape.copyWith(side: BorderSide(color: colour, width: 1.5)),
                    color: filled ? colour : null,
                  ),
                  child: Text(
                    letter,
                    style: TextStyle(
                      color: filled ? Colors.white : scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(text, style: const TextStyle(fontSize: 15.5, height: 1.35))),
                if (mark == OptionMark.missed)
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.correct,
                    semanticLabel: context.l10n.correctAnswer,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The answer box (or numerator and denominator boxes) of a numeric entry question.
class NumericEntry extends StatefulWidget {
  const NumericEntry({
    required this.question,
    required this.response,
    required this.onChanged,
    required this.reveal,
    super.key,
  });

  final Question question;
  final String? response;
  final ValueChanged<String>? onChanged;
  final bool reveal;

  @override
  State<NumericEntry> createState() => _NumericEntryState();
}

class _NumericEntryState extends State<NumericEntry> {
  late final TextEditingController _top;
  late final TextEditingController _bottom;

  @override
  void initState() {
    super.initState();
    final parts = (widget.response ?? '').split('/');
    _top = TextEditingController(text: parts.first);
    _bottom = TextEditingController(text: parts.length > 1 ? parts[1] : '');
  }

  @override
  void didUpdateWidget(NumericEntry old) {
    super.didUpdateWidget(old);
    // The calculator can transfer its display into the box.
    final parts = (widget.response ?? '').split('/');
    if (!widget.question.isFractionEntry && parts.first != _top.text) _top.text = parts.first;
  }

  @override
  void dispose() {
    _top.dispose();
    _bottom.dispose();
    super.dispose();
  }

  void _changed() {
    final top = _top.text.trim();
    final bottom = _bottom.text.trim();
    widget.onChanged?.call(
      widget.question.isFractionEntry ? (top.isEmpty && bottom.isEmpty ? '' : '$top/$bottom') : top,
    );
  }

  Widget _box(TextEditingController controller, String label) => SizedBox(
    width: 140,
    child: TextField(
      controller: controller,
      enabled: widget.onChanged != null,
      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))],
      textAlign: TextAlign.center,
      decoration: InputDecoration(border: const OutlineInputBorder(), labelText: label),
      onChanged: (_) => _changed(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final correct = isCorrect(widget.question, widget.response);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.question.isFractionEntry)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _box(_top, l10n.numerator),
              const SizedBox(width: 140, child: Divider(thickness: 2)),
              _box(_bottom, l10n.denominator),
            ],
          )
        else
          _box(_top, l10n.yourAnswer),
        if (widget.reveal) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${correct ? l10n.correct : l10n.incorrect} · ${l10n.correctAnswerIs(widget.question.numeric ?? '')}',
            style: TextStyle(
              color: correct ? AppColors.correct : AppColors.incorrect,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

/// The explanation box shown after an answer is revealed.
class ExplanationBox extends StatelessWidget {
  const ExplanationBox({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.explanation, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(text, style: TextStyle(color: scheme.onSecondaryContainer, height: 1.45)),
        ],
      ),
    );
  }
}
