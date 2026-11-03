import 'package:gre_prep/content/models.dart';

/// Responses are stored as strings: chosen option indexes joined by commas ("0,4"), or the typed
/// numeric entry ("12.5", or "3/8" for a fraction box). An empty string means no answer.
abstract final class Responses {
  static Set<int> choices(String? response) => {
    if (response != null && response.isNotEmpty)
      for (final part in response.split(',')) int.parse(part),
  };

  static String encodeChoices(Set<int> chosen) => ([...chosen]..sort()).join(',');

  /// Picks or unpicks option [index], following the question's selection rule.
  static String toggle(Question question, String? response, int index) {
    final chosen = choices(response);
    switch (question.type) {
      case QuestionType.tc:
        // One choice per blank: picking replaces the earlier choice in the same blank.
        final blank = question.blankOf(index);
        chosen
          ..removeWhere((other) => question.blankOf(other) == blank)
          ..add(index);
      case QuestionType.se || QuestionType.ma:
        if (!chosen.remove(index)) {
          if (question.type == QuestionType.se && chosen.length >= 2) return encodeChoices(chosen);
          chosen.add(index);
        }
      case QuestionType.mc ||
          QuestionType.sip ||
          QuestionType.qc ||
          QuestionType.ne ||
          QuestionType.essay:
        chosen
          ..clear()
          ..add(index);
    }
    return encodeChoices(chosen);
  }

  /// Whether the response is complete enough to count as answered.
  static bool isAnswered(Question question, String? response) {
    if (response == null || response.isEmpty) return false;
    return switch (question.type) {
      QuestionType.tc => choices(response).length == question.blanks.length,
      QuestionType.se => choices(response).length == 2,
      QuestionType.ne => parseNumber(response) != null,
      _ => true,
    };
  }
}

/// Parses "12", "-3.5", ".5" or "3/8"; null when it is not a number.
double? parseNumber(String raw) {
  final text = raw.replaceAll(',', '').replaceAll(' ', '').replaceAll('−', '-');
  if (text.contains('/')) {
    final parts = text.split('/');
    if (parts.length != 2) return null;
    final top = double.tryParse(parts[0]);
    final bottom = double.tryParse(parts[1]);
    if (top == null || bottom == null || bottom == 0) return null;
    return top / bottom;
  }
  return double.tryParse(text);
}

/// GRE rule: no partial credit. Every blank, both equivalents, every correct option and no extras.
bool isCorrect(Question question, String? response) {
  if (response == null || response.isEmpty) return false;
  if (question.type == QuestionType.ne) {
    final want = parseNumber(question.numeric ?? '');
    final got = parseNumber(response);
    return want != null && got != null && (want - got).abs() < 1e-9;
  }
  final chosen = Responses.choices(response);
  return chosen.length == question.answer.length && chosen.containsAll(question.answer);
}
