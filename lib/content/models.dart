typedef Json = Map<String, Object?>;

List<T> _list<T>(Object? raw, T Function(Json) read) => [
  for (final item in raw! as List<Object?>) read(item! as Json),
];

List<List<String>>? _table(Object? raw) => switch (raw) {
  final List<Object?> rows => [
    for (final row in rows) (row! as List<Object?>).cast<String>(),
  ],
  _ => null,
};

ChartSpec? _chart(Object? raw) => switch (raw) {
  final Json json => ChartSpec.fromJson(json),
  _ => null,
};

/// The GRE question formats.
enum QuestionType {
  /// Text completion: one to three blanks, each with its own choices.
  tc,

  /// Sentence equivalence: pick the two choices that fit.
  se,

  /// Multiple choice, one answer.
  mc,

  /// Multiple choice, select all that apply.
  ma,

  /// Reading: select the sentence in the passage.
  sip,

  /// Quantitative comparison of Quantity A and Quantity B.
  qc,

  /// Numeric entry: the candidate types the answer.
  ne,

  /// Analytical Writing: an Issue prompt.
  essay
  ;

  static QuestionType parse(String raw) => values.byName(raw);

  /// Whether the answer is a set of chosen options (as opposed to typed or written).
  bool get isChoice => this != ne && this != essay;
}

/// A chart drawn by the app: bar, line or pie.
class ChartSpec {
  const ChartSpec({
    required this.kind,
    required this.title,
    required this.labels,
    required this.series,
    this.unit,
  });

  factory ChartSpec.fromJson(Json json) => ChartSpec(
    kind: json['kind']! as String,
    title: json['title']! as String,
    labels: (json['labels']! as List<Object?>).map((label) => '$label').toList(),
    series: _list(json['series'], ChartSeries.fromJson),
    unit: json['unit'] as String?,
  );

  final String kind;
  final String title;
  final List<String> labels;
  final List<ChartSeries> series;
  final String? unit;
}

class ChartSeries {
  const ChartSeries({required this.name, required this.values});

  factory ChartSeries.fromJson(Json json) => ChartSeries(
    name: json['name']! as String,
    values: [
      for (final value in json['values']! as List<Object?>) (value! as num).toDouble(),
    ],
  );

  final String name;
  final List<double> values;
}

/// The fixed answer choices of a quantitative comparison.
const qcChoices = [
  'Quantity A is greater.',
  'Quantity B is greater.',
  'The two quantities are equal.',
  'The relationship cannot be determined from the information given.',
];

/// One question (or essay prompt) from the bank.
class Question {
  const Question({
    required this.id,
    required this.section,
    required this.topic,
    required this.isPractice,
    required this.level,
    required this.type,
    required this.stem,
    required this.explanation,
    this.options = const [],
    this.answer = const [],
    this.blanks = const [],
    this.numeric,
    this.quantityA,
    this.quantityB,
    this.setId,
    this.table,
    this.chart,
    this.chart2,
    this.figure,
    this.task,
    this.points = const [],
  });

  factory Question.fromJson(Json json, String section) {
    final type = QuestionType.parse(json['ty']! as String);
    return Question(
      id: json['id']! as String,
      section: section,
      topic: json['tp']! as String,
      isPractice: json['pl'] == 'p',
      level: json['lv']! as int,
      type: type,
      stem: json['s']! as String,
      explanation: json['e']! as String,
      options: type == QuestionType.qc
          ? qcChoices
          : (json['o'] as List<Object?>? ?? const []).cast<String>(),
      answer: (json['a'] as List<Object?>? ?? const []).cast<int>(),
      blanks: (json['b'] as List<Object?>? ?? const []).cast<int>(),
      numeric: json['n'] as String?,
      quantityA: json['qa'] as String?,
      quantityB: json['qb'] as String?,
      setId: json['st'] as String?,
      table: _table(json['tb']),
      chart: _chart(json['ch']),
      chart2: _chart(json['ch2']),
      figure: json['fg'] as String?,
      task: json['tk'] as String?,
      points: (json['pt'] as List<Object?>? ?? const []).cast<String>(),
    );
  }

  final String id;
  final String section;
  final String topic;
  final bool isPractice;
  final int level;
  final QuestionType type;
  final String stem;
  final String explanation;

  /// All choices; for text completion, blank (i)'s choices first, then (ii)'s.
  final List<String> options;

  /// Indexes of the correct options (one per blank for text completion).
  final List<int> answer;

  /// Choices per blank, e.g. [3, 3], for text completion.
  final List<int> blanks;

  /// The exact answer of a numeric entry question, e.g. "4.5" or "3/8".
  final String? numeric;
  final String? quantityA;
  final String? quantityB;
  final String? setId;
  final List<List<String>>? table;
  final ChartSpec? chart;
  final ChartSpec? chart2;

  /// A geometry figure as an SVG document.
  final String? figure;

  /// Essay instructions.
  final String? task;

  /// What a strong essay does with this prompt.
  final List<String> points;

  bool get isFractionEntry => numeric?.contains('/') ?? false;

  /// The blank (0-based) that option [index] belongs to, for text completion.
  int blankOf(int index) {
    var start = 0;
    for (var blank = 0; blank < blanks.length; blank++) {
      if (index < start + blanks[blank]) return blank;
      start += blanks[blank];
    }
    return 0;
  }

  /// First option index of [blank].
  int blankStart(int blank) => blanks.take(blank).fold(0, (sum, size) => sum + size);

  /// How many options must be chosen, or null when any number may be (select all that apply).
  int? get choiceCount => switch (type) {
    QuestionType.se => 2,
    QuestionType.tc => blanks.length,
    QuestionType.ma => null,
    _ => 1,
  };
}

/// A passage or data display shared by several questions.
class QuestionSet {
  const QuestionSet({
    required this.title,
    required this.text,
    this.table,
    this.chart,
    this.chart2,
  });

  factory QuestionSet.fromJson(Json json) => QuestionSet(
    title: json['t'] as String? ?? '',
    text: json['x']! as String,
    table: _table(json['tb']),
    chart: _chart(json['ch']),
    chart2: _chart(json['ch2']),
  );

  final String title;
  final String text;
  final List<List<String>>? table;
  final ChartSpec? chart;
  final ChartSpec? chart2;

  bool get isData => table != null || chart != null;
}

class TopicInfo {
  const TopicInfo({
    required this.key,
    required this.title,
    required this.practiceCount,
    required this.hasLesson,
  });

  factory TopicInfo.fromJson(Json json) => TopicInfo(
    key: json['key']! as String,
    title: json['title']! as String,
    practiceCount: json['practice']! as int,
    hasLesson: json['lesson'] as bool? ?? false,
  );

  final String key;
  final String title;
  final int practiceCount;
  final bool hasLesson;
}

class SectionInfo {
  const SectionInfo({
    required this.key,
    required this.title,
    required this.topics,
  });

  factory SectionInfo.fromJson(Json json) => SectionInfo(
    key: json['key']! as String,
    title: json['title']! as String,
    topics: _list(json['topics'], TopicInfo.fromJson),
  );

  final String key;
  final String title;
  final List<TopicInfo> topics;

  bool get isWriting => key == 'writing';
}

/// Timing and routing of one measure (Verbal or Quant).
class MeasureInfo {
  const MeasureInfo({
    required this.key,
    required this.title,
    required this.minutes,
    required this.counts,
    required this.hardAt,
  });

  factory MeasureInfo.fromJson(Json json) => MeasureInfo(
    key: json['key']! as String,
    title: json['title']! as String,
    minutes: (json['minutes']! as List<Object?>).cast<int>(),
    counts: (json['counts']! as List<Object?>).cast<int>(),
    hardAt: json['hardAt']! as int,
  );

  final String key;
  final String title;

  /// Minutes for section 1 and section 2.
  final List<int> minutes;

  /// Questions in section 1 and section 2.
  final List<int> counts;

  /// Section 1 correct answers needed for the harder section 2.
  final int hardAt;
}

class Catalog {
  const Catalog({
    required this.sections,
    required this.measures,
    required this.writingMinutes,
  });

  factory Catalog.fromJson(Json json) => Catalog(
    sections: _list(json['sections'], SectionInfo.fromJson),
    measures: _list(json['measures'], MeasureInfo.fromJson),
    writingMinutes: json['writingMinutes']! as int,
  );

  final List<SectionInfo> sections;
  final List<MeasureInfo> measures;
  final int writingMinutes;

  MeasureInfo measure(String key) => measures.firstWhere((m) => m.key == key);

  /// Title of a topic, falling back to its key for retired content.
  String topicTitle(String section, String topic) {
    for (final candidate in sections) {
      if (candidate.key != section) continue;
      for (final info in candidate.topics) {
        if (info.key == topic) return info.title;
      }
    }
    return topic;
  }
}

/// Section 1 and both versions of section 2 of one measure in a paper.
class MeasurePaper {
  const MeasurePaper({
    required this.first,
    required this.easy,
    required this.hard,
  });

  factory MeasurePaper.fromJson(Json json) => MeasurePaper(
    first: (json['s1']! as List<Object?>).cast<String>(),
    easy: (json['easy']! as List<Object?>).cast<String>(),
    hard: (json['hard']! as List<Object?>).cast<String>(),
  );

  final List<String> first;
  final List<String> easy;
  final List<String> hard;
}

/// One full-length mock test.
class Paper {
  const Paper({
    required this.id,
    required this.number,
    required this.title,
    required this.essayId,
    required this.order,
    required this.measures,
  });

  factory Paper.fromJson(Json json) => Paper(
    id: json['id']! as String,
    number: json['number']! as int,
    title: json['title']! as String,
    essayId: json['essay']! as String,
    order: (json['order']! as List<Object?>).cast<String>(),
    measures: {
      for (final MapEntry(:key, :value) in (json['measures']! as Json).entries)
        key: MeasurePaper.fromJson(value! as Json),
    },
  );

  final String id;
  final int number;
  final String title;
  final String essayId;

  /// Measure keys in the order the sections are taken, e.g. ["verbal", "quant"].
  final List<String> order;
  final Map<String, MeasurePaper> measures;
}

/// One article of the Guide tab or one topic lesson. Body lines: `## heading`, `- bullet`, `> example`, `! tip`, or a paragraph.
class GuideArticle {
  const GuideArticle({
    required this.id,
    required this.group,
    required this.title,
    required this.lines,
  });

  factory GuideArticle.fromJson(Json json) => GuideArticle(
    id: json['id']! as String,
    group: json['group']! as String,
    title: json['title']! as String,
    lines: (json['lines']! as List<Object?>).cast<String>(),
  );

  final String id;
  final String group;
  final String title;
  final List<String> lines;
}

class Lesson {
  const Lesson({
    required this.section,
    required this.topic,
    required this.title,
    required this.minutes,
    required this.lines,
  });

  factory Lesson.fromJson(Json json) => Lesson(
    section: json['section']! as String,
    topic: json['topic']! as String,
    title: json['title']! as String,
    minutes: json['minutes'] as int? ?? 10,
    lines: (json['lines']! as List<Object?>).cast<String>(),
  );

  final String section;
  final String topic;
  final String title;
  final int minutes;
  final List<String> lines;
}

/// One vocabulary flashcard.
class VocabWord {
  const VocabWord({
    required this.word,
    required this.part,
    required this.definition,
    required this.example,
    required this.synonyms,
  });

  factory VocabWord.fromJson(Json json) => VocabWord(
    word: json['w']! as String,
    part: json['p'] as String? ?? '',
    definition: json['d']! as String,
    example: json['e'] as String? ?? '',
    synonyms: (json['s'] as List<Object?>? ?? const []).cast<String>(),
  );

  final String word;
  final String part;
  final String definition;
  final String example;
  final List<String> synonyms;
}
