import 'package:gre_prep/content/models.dart';

/// Estimated scaled scores, saved when a mock is finished.
class MockScore {
  const MockScore({
    required this.verbal,
    required this.quant,
    required this.verbalCorrect,
    required this.quantCorrect,
    required this.total,
  });

  factory MockScore.fromJson(Json json) => MockScore(
    verbal: json['v']! as int,
    quant: json['q']! as int,
    verbalCorrect: json['vc']! as int,
    quantCorrect: json['qc']! as int,
    total: json['n']! as int,
  );

  /// 130-170.
  final int verbal;
  final int quant;
  final int verbalCorrect;
  final int quantCorrect;

  /// Questions per measure (27).
  final int total;

  Json toJson() => {'v': verbal, 'q': quant, 'vc': verbalCorrect, 'qc': quantCorrect, 'n': total};
}

/// One sitting of a mock test. Immutable; every change goes through
/// the repository as a new value.
class Attempt {
  const Attempt({
    required this.id,
    required this.paperId,
    required this.startedAt,
    required this.remainingSeconds,
    this.stage = 0,
    this.stageStarted = false,
    this.responses = const {},
    this.flagged = const {},
    this.currentIndex = 0,
    this.routes = const {},
    this.essay = '',
    this.finishedAt,
    this.score,
    this.essaySelfScore,
  });

  factory Attempt.fromJson(Json json) => Attempt(
    id: json['id']! as String,
    paperId: json['paperId']! as String,
    startedAt: DateTime.parse(json['startedAt']! as String),
    remainingSeconds: json['remaining']! as int,
    stage: json['stage']! as int,
    stageStarted: json['stageStarted'] as bool? ?? false,
    responses: (json['responses']! as Json).cast<String, String>(),
    flagged: (json['flagged']! as List<Object?>).cast<String>().toSet(),
    currentIndex: json['index']! as int,
    routes: (json['routes']! as Json).cast<String, String>(),
    essay: json['essay'] as String? ?? '',
    finishedAt: switch (json['finishedAt']) {
      final String value => DateTime.parse(value),
      _ => null,
    },
    score: switch (json['score']) {
      final Json value => MockScore.fromJson(value),
      _ => null,
    },
    essaySelfScore: (json['essayScore'] as num?)?.toDouble(),
  );

  final String id;
  final String paperId;
  final DateTime startedAt;

  /// Seconds left in the current stage.
  final int remainingSeconds;

  /// Index of the current stage: 0 essay, then section 1 and 2 of each measure.
  final int stage;

  /// Whether the candidate has begun the current stage (its clock runs).
  final bool stageStarted;

  /// Question id to encoded response (see `Responses`).
  final Map<String, String> responses;
  final Set<String> flagged;

  /// Question index within the current stage.
  final int currentIndex;

  /// Measure key to `easy` or `hard`, decided when its section 1 ends.
  final Map<String, String> routes;
  final String essay;
  final DateTime? finishedAt;
  final MockScore? score;

  /// The candidate's own 0-6 rating of the essay, after reading the model answer.
  final double? essaySelfScore;

  bool get isFinished => finishedAt != null;

  Attempt copyWith({
    int? remainingSeconds,
    int? stage,
    bool? stageStarted,
    Map<String, String>? responses,
    Set<String>? flagged,
    int? currentIndex,
    Map<String, String>? routes,
    String? essay,
    DateTime? finishedAt,
    MockScore? score,
    double? essaySelfScore,
  }) => Attempt(
    id: id,
    paperId: paperId,
    startedAt: startedAt,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    stage: stage ?? this.stage,
    stageStarted: stageStarted ?? this.stageStarted,
    responses: responses ?? this.responses,
    flagged: flagged ?? this.flagged,
    currentIndex: currentIndex ?? this.currentIndex,
    routes: routes ?? this.routes,
    essay: essay ?? this.essay,
    finishedAt: finishedAt ?? this.finishedAt,
    score: score ?? this.score,
    essaySelfScore: essaySelfScore ?? this.essaySelfScore,
  );

  Json toJson() => {
    'id': id,
    'paperId': paperId,
    'startedAt': startedAt.toIso8601String(),
    'remaining': remainingSeconds,
    'stage': stage,
    'stageStarted': stageStarted,
    'responses': responses,
    'flagged': flagged.toList(),
    'index': currentIndex,
    'routes': routes,
    'essay': essay,
    if (finishedAt case final finished?) 'finishedAt': finished.toIso8601String(),
    if (score case final value?) 'score': value.toJson(),
    'essayScore': ?essaySelfScore,
  };
}
