import 'package:gre_prep/content/content_repository.dart';
import 'package:gre_prep/content/models.dart';

Question question(
  String id, {
  String section = 'quant',
  String topic = 'num',
  QuestionType type = QuestionType.mc,
  List<int> answer = const [0],
  List<String> options = const ['a', 'b', 'c', 'd', 'e'],
  List<int> blanks = const [],
  String? numeric,
  String? setId,
}) => Question(
  id: id,
  section: section,
  topic: topic,
  isPractice: false,
  level: 2,
  type: type,
  stem: 'Stem $id',
  options: options,
  answer: answer,
  blanks: blanks,
  numeric: numeric,
  explanation: 'Because.',
  setId: setId,
);

const catalog = Catalog(
  sections: [],
  measures: [
    MeasureInfo(key: 'verbal', title: 'Verbal', minutes: [18, 23], counts: [2, 2], hardAt: 2),
    MeasureInfo(key: 'quant', title: 'Quant', minutes: [21, 26], counts: [2, 2], hardAt: 2),
  ],
  writingMinutes: 30,
);

/// A tiny mock: two questions per section, keyed to option 0.
Sitting sittingOf({required Map<String, String> routes}) {
  final ids = <String, List<String>>{};
  final questions = <String, Question>{
    'essay': question('essay', section: 'writing', type: QuestionType.essay),
  };
  for (final measure in ['verbal', 'quant']) {
    for (final part in ['s1', 'easy', 'hard']) {
      ids['$measure/$part'] = ['$measure-$part-1', '$measure-$part-2'];
      for (final id in ids['$measure/$part']!) {
        questions[id] = question(id, section: measure, topic: part);
      }
    }
  }
  final paper = Paper(
    id: 'gre-01',
    number: 1,
    title: 'Mock Test 1',
    essayId: 'essay',
    order: const ['verbal', 'quant'],
    measures: {
      for (final measure in ['verbal', 'quant'])
        measure: MeasurePaper(
          first: ids['$measure/s1']!,
          easy: ids['$measure/easy']!,
          hard: ids['$measure/hard']!,
        ),
    },
  );
  return Sitting(
    paper: paper,
    stages: buildStages(paper, catalog, routes),
    questions: questions,
    sets: const {},
  );
}
