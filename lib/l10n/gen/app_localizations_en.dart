// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Prep Simulator for GRE';

  @override
  String loadError(String code) {
    return 'Could not load this. Please restart the app. ($code)';
  }

  @override
  String get tabTests => 'Mock tests';

  @override
  String get tabPractice => 'Practice';

  @override
  String get tabGuide => 'Guide';

  @override
  String get tabProgress => 'Progress';

  @override
  String get about => 'About';

  @override
  String testsIntro(int count) {
    return '$count full-length mock tests in the current GRE format: the essay, then two Verbal and two Quantitative sections (about 1 hour 58 minutes). Section 2 of each measure gets easier or harder depending on section 1, as on the real test.';
  }

  @override
  String bestScore(int verbal, int quant) {
    return 'Best V $verbal · Q $quant';
  }

  @override
  String vqScores(int verbal, int quant) {
    return 'Verbal $verbal · Quant $quant';
  }

  @override
  String get inProgress => 'In progress';

  @override
  String get notStarted => 'Not taken';

  @override
  String sectionCount(int count) {
    return '$count questions';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String totalTime(int hours, int minutes) {
    return 'Total time $hours h $minutes min';
  }

  @override
  String get startTest => 'Start mock test';

  @override
  String get resumeTest => 'Resume';

  @override
  String get restartTest => 'Start again';

  @override
  String get paperRules =>
      'Each section is timed separately. Within a section you can skip questions, mark them, go back and change answers; once a section ends you cannot return to it. There is no penalty for wrong answers, so answer every question. Leaving the app pauses the clock (the real test does not). Scores, explanations and a model essay appear at the end.';

  @override
  String get unofficialNote =>
      'Independent practice test. Scores are estimates; ETS sets and scores the real GRE.';

  @override
  String get previousAttempts => 'Previous attempts';

  @override
  String questionOf(int number, int total) {
    return 'Question $number of $total';
  }

  @override
  String get previous => 'Back';

  @override
  String get next => 'Next';

  @override
  String get review => 'Review';

  @override
  String get endSection => 'End section';

  @override
  String get finish => 'Finish';

  @override
  String get mark => 'Mark';

  @override
  String get marked => 'Marked';

  @override
  String get answered => 'Answered';

  @override
  String answeredOf(int answered, int total) {
    return '$answered of $total answered';
  }

  @override
  String get clearAnswer => 'Clear answer';

  @override
  String get calculator => 'Calculator';

  @override
  String get transferDisplay => 'Transfer display to answer box';

  @override
  String get timeLeft => 'Time left in this section';

  @override
  String get leaveTitle => 'Leave the test?';

  @override
  String get leaveBody =>
      'Your answers are saved and the clock pauses. You can resume from the Mock tests tab.';

  @override
  String get stay => 'Stay';

  @override
  String get leave => 'Leave';

  @override
  String get endSectionTitle => 'End this section?';

  @override
  String get finishTitle => 'Finish the test?';

  @override
  String get endSectionBody => 'You cannot return to this section after it ends.';

  @override
  String unansweredWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions are not answered.',
      one: '1 question is not answered.',
    );
    return '$_temp0 There is no penalty for guessing.';
  }

  @override
  String get keepWorking => 'Keep working';

  @override
  String get finishTest => 'Finish and see scores';

  @override
  String stageOf(int number, int total) {
    return 'Part $number of $total';
  }

  @override
  String stageSize(int count, int minutes) {
    return '$count questions · $minutes minutes';
  }

  @override
  String essayMinutes(int minutes) {
    return 'One essay · $minutes minutes';
  }

  @override
  String get beginSection => 'Begin';

  @override
  String get introWriting =>
      'Analyze an Issue. Read the statement and the instructions, then plan and write a response that develops your position with reasons and examples. Raters reward a clear position, strong development, organization and control of language. There is no spell-check. Aim for 400-600 words.';

  @override
  String get introVerbal =>
      'Text completion, sentence equivalence and reading questions. Read each question\'s instructions: some need one answer, some two, some every correct choice. You can move freely within the section and mark questions to revisit.';

  @override
  String get introQuant =>
      'Quantitative comparison, multiple choice and numeric entry questions, some based on data displays. Use the calculator (top right) for awkward arithmetic only. Figures are not necessarily drawn to scale unless stated.';

  @override
  String get introAdaptive =>
      'This first section is of medium difficulty. How you do here decides whether the second section of this measure is easier or harder, and the harder section opens the top of the score scale.';

  @override
  String get measureWriting => 'Analytical Writing';

  @override
  String get measureWritingShort => 'Writing';

  @override
  String get measureVerbal => 'Verbal Reasoning';

  @override
  String get measureQuant => 'Quantitative Reasoning';

  @override
  String measureSection(String measure, int part) {
    return '$measure · Section $part';
  }

  @override
  String stageShort(String measure, int part) {
    return '$measure $part';
  }

  @override
  String get measureVerbalShort => 'Verbal';

  @override
  String get measureQuantShort => 'Quant';

  @override
  String get essayHint => 'Write your response here';

  @override
  String wordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
    );
    return '$_temp0';
  }

  @override
  String get finishEssay => 'Finish and compare';

  @override
  String get passageTitle => 'Passage';

  @override
  String get dataTitle => 'Data';

  @override
  String get readPassage => 'Show passage';

  @override
  String get hidePassage => 'Hide passage';

  @override
  String get showData => 'Show data';

  @override
  String get hideData => 'Hide data';

  @override
  String get quantityA => 'Quantity A';

  @override
  String get quantityB => 'Quantity B';

  @override
  String get pickOne => 'Select one answer choice.';

  @override
  String get pickPerBlank => 'For each blank, select one entry from its column.';

  @override
  String get pickTwo =>
      'Select exactly two answer choices that complete the sentence with the same meaning.';

  @override
  String get pickAll => 'Select all the answer choices that apply.';

  @override
  String get pickSentence => 'Select the sentence.';

  @override
  String get enterNumber => 'Enter your answer as an integer or a decimal.';

  @override
  String get enterFraction => 'Enter your answer as a fraction. Equivalent fractions are accepted.';

  @override
  String blankLabel(String numeral) {
    return 'Blank ($numeral)';
  }

  @override
  String get numerator => 'Numerator';

  @override
  String get denominator => 'Denominator';

  @override
  String get yourAnswer => 'Your answer';

  @override
  String get correct => 'Correct';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get correctAnswer => 'Correct answer';

  @override
  String correctAnswerIs(String value) {
    return 'Answer: $value';
  }

  @override
  String get explanation => 'Explanation';

  @override
  String get check => 'Check answer';

  @override
  String get results => 'Results';

  @override
  String get estimatedScores => 'Estimated scores';

  @override
  String scoreRange(int low, int high) {
    return 'likely $low-$high';
  }

  @override
  String scoreOutOf(int correct, int total) {
    return '$correct of $total';
  }

  @override
  String totalScore(int total) {
    return 'Verbal + Quant: $total (260-340 scale)';
  }

  @override
  String get notRated => 'rate your essay';

  @override
  String get selfRated => 'self-rated';

  @override
  String get reviewAnswers => 'Review answers and explanations';

  @override
  String get rateEssay => 'Rate your essay against a model';

  @override
  String get essayAndModel => 'Your essay and the model answer';

  @override
  String sectionN(int number) {
    return 'Section $number';
  }

  @override
  String get routeHard => 'harder';

  @override
  String get routeEasy => 'easier';

  @override
  String skippedCount(int count) {
    return '$count not answered';
  }

  @override
  String get byType => 'By question type';

  @override
  String get weakTopics => 'Topics to work on';

  @override
  String get scoreDisclaimer =>
      'Practice estimate. ETS equates each test form statistically; these scores follow the shape of the real scale but cannot match it exactly. Use them to track progress over several mocks.';

  @override
  String get backHome => 'Back to home';

  @override
  String get reviewTitle => 'Answer review';

  @override
  String get filterAll => 'All';

  @override
  String get filterWrong => 'Wrong';

  @override
  String get filterSkipped => 'Skipped';

  @override
  String get filterMarked => 'Marked';

  @override
  String get filterEmpty => 'Nothing here.';

  @override
  String get notAnswered => 'not answered';

  @override
  String get yourEssay => 'Your essay';

  @override
  String get essayEmpty => '(No essay written.)';

  @override
  String get strongResponse => 'What a strong response does';

  @override
  String get modelEssay => 'Model essay';

  @override
  String get modelEssayNote =>
      'One way to earn a 6. Many different positions can score just as well.';

  @override
  String get rateYourself => 'Rate yourself';

  @override
  String get rateYourselfHelp =>
      'Tick each statement that is true of your essay, then adjust the score honestly.';

  @override
  String get criterionPosition =>
      'Takes a clear, thoughtful position that answers the specific task.';

  @override
  String get criterionReasons =>
      'Supports it with compelling reasons and specific, well-chosen examples.';

  @override
  String get criterionOrganisation =>
      'Is well organized: each paragraph has a clear job and ideas connect logically.';

  @override
  String get criterionTask =>
      'Deals with the complexity the instructions ask for (counterarguments, conditions, consequences).';

  @override
  String get criterionLanguage => 'Uses precise words and varied sentences.';

  @override
  String get criterionMechanics =>
      'Has few errors of grammar, usage or spelling, none that obscure meaning.';

  @override
  String suggestedScore(String score) {
    return 'Suggested score: $score';
  }

  @override
  String saveScore(String score) {
    return 'Save score $score';
  }

  @override
  String get scoreSaved => 'Score saved';

  @override
  String get practiceIntro =>
      'Every GRE topic, each with a lesson and its own practice questions (never used in the mock tests). Answers and explanations show as you go.';

  @override
  String get lesson => 'Lesson';

  @override
  String get lessonHelp => 'Methods, worked examples and traps';

  @override
  String get practiceSet => 'Practice 10 questions';

  @override
  String practicePool(int count) {
    return '$count practice questions';
  }

  @override
  String practiceTally(int correct, int total) {
    return '$correct of $total correct so far';
  }

  @override
  String get practiceEmpty => 'No practice questions here yet.';

  @override
  String get practiceDone => 'Set complete';

  @override
  String get practiceAgain => 'Another set';

  @override
  String get backToTopic => 'Back to topic';

  @override
  String get practiceNow => 'Practice this topic';

  @override
  String readingTime(int minutes) {
    return 'About $minutes minutes';
  }

  @override
  String levelName(String level) {
    String _temp0 = intl.Intl.selectLogic(
      level,
      {
        '1': 'Easy',
        '2': 'Medium',
        'other': 'Hard',
      },
    );
    return '$_temp0';
  }

  @override
  String get essayPracticeIntro =>
      'Pick a prompt. You get 30 minutes, then compare your essay with a model answer and rate it.';

  @override
  String get vocabulary => 'Vocabulary flashcards';

  @override
  String get vocabularyHelp => 'High-frequency GRE words with meanings, examples and synonyms';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get includeKnown => 'Include words I know';

  @override
  String vocabProgress(int known, int total) {
    return '$known of $total words known';
  }

  @override
  String get vocabDone =>
      'You have marked every word as known. Switch on \"Include words I know\" to review.';

  @override
  String cardOf(int number, int total) {
    return 'Card $number of $total';
  }

  @override
  String get markKnown => 'I know this';

  @override
  String get unmarkKnown => 'Not yet';

  @override
  String get tapToReveal => 'Tap to see the meaning';

  @override
  String synonyms(String list) {
    return 'Synonyms: $list';
  }

  @override
  String get progressEmpty => 'Take a mock test or a practice set and your progress shows here.';

  @override
  String get testsTaken => 'Mocks taken';

  @override
  String get averageVerbal => 'Average Verbal';

  @override
  String get averageQuant => 'Average Quant';

  @override
  String recentAverage(int verbal, int quant) {
    return 'Last 3 mocks: Verbal $verbal, Quant $quant';
  }

  @override
  String get topicMastery => 'Weakest topics';

  @override
  String get history => 'History';

  @override
  String percentLabel(int percent) {
    return '$percent%';
  }

  @override
  String get version => 'Version 1.0.0';

  @override
  String get website => 'Website';

  @override
  String get privacy => 'Privacy policy';

  @override
  String get privacyChoices => 'Privacy choices (ads)';

  @override
  String get terms => 'Terms of use';

  @override
  String get contact => 'Contact: homilabs.smc@gmail.com';

  @override
  String get aboutBody =>
      'Prep Simulator for GRE is an independent practice app by HomiLabs. GRE® is a registered trademark of ETS. This app is not endorsed or approved by ETS and is not affiliated with it. All questions, passages, essay prompts, lessons and explanations are original practice material written for this app, not real test questions, and scores are practice estimates only.';
}
