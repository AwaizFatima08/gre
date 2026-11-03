import 'package:gre_prep/content/content_repository.dart';
import 'package:gre_prep/content/models.dart';
import 'package:gre_prep/core/grading.dart';

/// Correct answers out of a total.
class Tally {
  const Tally(this.correct, this.total);

  final int correct;
  final int total;

  /// Whole percent; 0 for an empty tally.
  int get percent => total == 0 ? 0 : (correct * 100 / total).round();

  Tally operator +(Tally other) => Tally(correct + other.correct, total + other.total);
}

class TopicScore {
  const TopicScore({required this.section, required this.topic, required this.tally});

  final String section;
  final String topic;
  final Tally tally;
}

/// Estimated 130-170 score of one measure from both sections. ETS equates scores statistically; this
/// estimate follows its published shape: the harder section 2 opens the top of the scale, the easier one caps it.
int estimateScaled({required int correct, required int total, required bool hardRoute}) {
  if (total == 0) return 130;
  final share = correct / total;
  final scaled = hardRoute ? 146 + 24 * share : 130 + 26 * share * 27 / 21;
  return scaled.round().clamp(130, hardRoute ? 170 : 157);
}

/// The likely band around an estimate (± 3 points), as practice tests cannot equate exactly.
(int, int) scoreBand(int scaled) => ((scaled - 3).clamp(130, 170), (scaled + 3).clamp(130, 170));

class MeasureResult {
  const MeasureResult({
    required this.key,
    required this.first,
    required this.second,
    required this.hardRoute,
    required this.skipped,
  });

  final String key;
  final Tally first;
  final Tally second;
  final bool hardRoute;
  final int skipped;

  Tally get overall => first + second;

  int get scaled => estimateScaled(
    correct: overall.correct,
    total: overall.total,
    hardRoute: hardRoute,
  );
}

/// The outcome of a finished mock.
class MockResult {
  const MockResult({required this.measures, required this.topics, required this.types});

  final Map<String, MeasureResult> measures;

  /// Weakest first.
  final List<TopicScore> topics;

  /// By question type within each measure, e.g. `verbal/tc`.
  final Map<String, Tally> types;
}

MockResult scoreSitting(Sitting sitting, Map<String, String> responses) {
  final firsts = <String, Tally>{};
  final seconds = <String, Tally>{};
  final skipped = <String, int>{};
  final topics = <(String, String), Tally>{};
  final types = <String, Tally>{};
  for (final stage in sitting.stages) {
    if (stage.isEssay) continue;
    var tally = const Tally(0, 0);
    for (final question in sitting.questionsOf(stage)) {
      final response = responses[question.id];
      final right = Tally(isCorrect(question, response) ? 1 : 0, 1);
      tally += right;
      if (!Responses.isAnswered(question, response)) {
        skipped[stage.measure] = (skipped[stage.measure] ?? 0) + 1;
      }
      final key = (question.section, question.topic);
      topics[key] = (topics[key] ?? const Tally(0, 0)) + right;
      final type = '${stage.measure}/${question.type.name}';
      types[type] = (types[type] ?? const Tally(0, 0)) + right;
    }
    (stage.part == 1 ? firsts : seconds)[stage.measure] = tally;
  }
  final measures = {
    for (final key in sitting.paper.order)
      key: MeasureResult(
        key: key,
        first: firsts[key] ?? const Tally(0, 0),
        second: seconds[key] ?? const Tally(0, 0),
        hardRoute: sitting.stages.any((s) => s.measure == key && s.route == 'hard'),
        skipped: skipped[key] ?? 0,
      ),
  };
  final topicScores = [
    for (final MapEntry(:key, :value) in topics.entries)
      TopicScore(section: key.$1, topic: key.$2, tally: value),
  ]..sort((a, b) => a.tally.percent.compareTo(b.tally.percent));
  return MockResult(measures: measures, topics: topicScores, types: types);
}

/// Section 1 correct answers in [measure], which decide the section 2 route.
int firstSectionCorrect(Sitting sitting, String measure, Map<String, String> responses) {
  final stage = sitting.stages.firstWhere((s) => s.measure == measure && s.part == 1);
  return sitting.questionsOf(stage).where((q) => isCorrect(q, responses[q.id])).length;
}

/// Readable name of a question type.
String typeTitle(QuestionType type) => switch (type) {
  QuestionType.tc => 'Text completion',
  QuestionType.se => 'Sentence equivalence',
  QuestionType.mc => 'Multiple choice',
  QuestionType.ma => 'Select one or more',
  QuestionType.sip => 'Select in passage',
  QuestionType.qc => 'Quantitative comparison',
  QuestionType.ne => 'Numeric entry',
  QuestionType.essay => 'Essay',
};
