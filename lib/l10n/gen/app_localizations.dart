import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Prep Simulator for GRE'**
  String get appTitle;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this. Please restart the app. ({code})'**
  String loadError(String code);

  /// No description provided for @tabTests.
  ///
  /// In en, this message translates to:
  /// **'Mock tests'**
  String get tabTests;

  /// No description provided for @tabPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get tabPractice;

  /// No description provided for @tabGuide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get tabGuide;

  /// No description provided for @tabProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get tabProgress;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @testsIntro.
  ///
  /// In en, this message translates to:
  /// **'{count} full-length mock tests in the current GRE format: the essay, then two Verbal and two Quantitative sections (about 1 hour 58 minutes). Section 2 of each measure gets easier or harder depending on section 1, as on the real test.'**
  String testsIntro(int count);

  /// No description provided for @bestScore.
  ///
  /// In en, this message translates to:
  /// **'Best V {verbal} · Q {quant}'**
  String bestScore(int verbal, int quant);

  /// No description provided for @vqScores.
  ///
  /// In en, this message translates to:
  /// **'Verbal {verbal} · Quant {quant}'**
  String vqScores(int verbal, int quant);

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not taken'**
  String get notStarted;

  /// No description provided for @sectionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String sectionCount(int count);

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total time {hours} h {minutes} min'**
  String totalTime(int hours, int minutes);

  /// No description provided for @startTest.
  ///
  /// In en, this message translates to:
  /// **'Start mock test'**
  String get startTest;

  /// No description provided for @resumeTest.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeTest;

  /// No description provided for @restartTest.
  ///
  /// In en, this message translates to:
  /// **'Start again'**
  String get restartTest;

  /// No description provided for @paperRules.
  ///
  /// In en, this message translates to:
  /// **'Each section is timed separately. Within a section you can skip questions, mark them, go back and change answers; once a section ends you cannot return to it. There is no penalty for wrong answers, so answer every question. Leaving the app pauses the clock (the real test does not). Scores, explanations and a model essay appear at the end.'**
  String get paperRules;

  /// No description provided for @unofficialNote.
  ///
  /// In en, this message translates to:
  /// **'Independent practice test. Scores are estimates; ETS sets and scores the real GRE.'**
  String get unofficialNote;

  /// No description provided for @previousAttempts.
  ///
  /// In en, this message translates to:
  /// **'Previous attempts'**
  String get previousAttempts;

  /// No description provided for @questionOf.
  ///
  /// In en, this message translates to:
  /// **'Question {number} of {total}'**
  String questionOf(int number, int total);

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @endSection.
  ///
  /// In en, this message translates to:
  /// **'End section'**
  String get endSection;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @mark.
  ///
  /// In en, this message translates to:
  /// **'Mark'**
  String get mark;

  /// No description provided for @marked.
  ///
  /// In en, this message translates to:
  /// **'Marked'**
  String get marked;

  /// No description provided for @answered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get answered;

  /// No description provided for @answeredOf.
  ///
  /// In en, this message translates to:
  /// **'{answered} of {total} answered'**
  String answeredOf(int answered, int total);

  /// No description provided for @clearAnswer.
  ///
  /// In en, this message translates to:
  /// **'Clear answer'**
  String get clearAnswer;

  /// No description provided for @calculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculator;

  /// No description provided for @transferDisplay.
  ///
  /// In en, this message translates to:
  /// **'Transfer display to answer box'**
  String get transferDisplay;

  /// No description provided for @timeLeft.
  ///
  /// In en, this message translates to:
  /// **'Time left in this section'**
  String get timeLeft;

  /// No description provided for @leaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave the test?'**
  String get leaveTitle;

  /// No description provided for @leaveBody.
  ///
  /// In en, this message translates to:
  /// **'Your answers are saved and the clock pauses. You can resume from the Mock tests tab.'**
  String get leaveBody;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @endSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'End this section?'**
  String get endSectionTitle;

  /// No description provided for @finishTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish the test?'**
  String get finishTitle;

  /// No description provided for @endSectionBody.
  ///
  /// In en, this message translates to:
  /// **'You cannot return to this section after it ends.'**
  String get endSectionBody;

  /// No description provided for @unansweredWarning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question is not answered.} other{{count} questions are not answered.}} There is no penalty for guessing.'**
  String unansweredWarning(int count);

  /// No description provided for @keepWorking.
  ///
  /// In en, this message translates to:
  /// **'Keep working'**
  String get keepWorking;

  /// No description provided for @finishTest.
  ///
  /// In en, this message translates to:
  /// **'Finish and see scores'**
  String get finishTest;

  /// No description provided for @stageOf.
  ///
  /// In en, this message translates to:
  /// **'Part {number} of {total}'**
  String stageOf(int number, int total);

  /// No description provided for @stageSize.
  ///
  /// In en, this message translates to:
  /// **'{count} questions · {minutes} minutes'**
  String stageSize(int count, int minutes);

  /// No description provided for @essayMinutes.
  ///
  /// In en, this message translates to:
  /// **'One essay · {minutes} minutes'**
  String essayMinutes(int minutes);

  /// No description provided for @beginSection.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get beginSection;

  /// No description provided for @introWriting.
  ///
  /// In en, this message translates to:
  /// **'Analyze an Issue. Read the statement and the instructions, then plan and write a response that develops your position with reasons and examples. Raters reward a clear position, strong development, organization and control of language. There is no spell-check. Aim for 400-600 words.'**
  String get introWriting;

  /// No description provided for @introVerbal.
  ///
  /// In en, this message translates to:
  /// **'Text completion, sentence equivalence and reading questions. Read each question\'s instructions: some need one answer, some two, some every correct choice. You can move freely within the section and mark questions to revisit.'**
  String get introVerbal;

  /// No description provided for @introQuant.
  ///
  /// In en, this message translates to:
  /// **'Quantitative comparison, multiple choice and numeric entry questions, some based on data displays. Use the calculator (top right) for awkward arithmetic only. Figures are not necessarily drawn to scale unless stated.'**
  String get introQuant;

  /// No description provided for @introAdaptive.
  ///
  /// In en, this message translates to:
  /// **'This first section is of medium difficulty. How you do here decides whether the second section of this measure is easier or harder, and the harder section opens the top of the score scale.'**
  String get introAdaptive;

  /// No description provided for @measureWriting.
  ///
  /// In en, this message translates to:
  /// **'Analytical Writing'**
  String get measureWriting;

  /// No description provided for @measureWritingShort.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get measureWritingShort;

  /// No description provided for @measureVerbal.
  ///
  /// In en, this message translates to:
  /// **'Verbal Reasoning'**
  String get measureVerbal;

  /// No description provided for @measureQuant.
  ///
  /// In en, this message translates to:
  /// **'Quantitative Reasoning'**
  String get measureQuant;

  /// No description provided for @measureSection.
  ///
  /// In en, this message translates to:
  /// **'{measure} · Section {part}'**
  String measureSection(String measure, int part);

  /// No description provided for @stageShort.
  ///
  /// In en, this message translates to:
  /// **'{measure} {part}'**
  String stageShort(String measure, int part);

  /// No description provided for @measureVerbalShort.
  ///
  /// In en, this message translates to:
  /// **'Verbal'**
  String get measureVerbalShort;

  /// No description provided for @measureQuantShort.
  ///
  /// In en, this message translates to:
  /// **'Quant'**
  String get measureQuantShort;

  /// No description provided for @essayHint.
  ///
  /// In en, this message translates to:
  /// **'Write your response here'**
  String get essayHint;

  /// No description provided for @wordCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 word} other{{count} words}}'**
  String wordCount(int count);

  /// No description provided for @finishEssay.
  ///
  /// In en, this message translates to:
  /// **'Finish and compare'**
  String get finishEssay;

  /// No description provided for @passageTitle.
  ///
  /// In en, this message translates to:
  /// **'Passage'**
  String get passageTitle;

  /// No description provided for @dataTitle.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataTitle;

  /// No description provided for @readPassage.
  ///
  /// In en, this message translates to:
  /// **'Show passage'**
  String get readPassage;

  /// No description provided for @hidePassage.
  ///
  /// In en, this message translates to:
  /// **'Hide passage'**
  String get hidePassage;

  /// No description provided for @showData.
  ///
  /// In en, this message translates to:
  /// **'Show data'**
  String get showData;

  /// No description provided for @hideData.
  ///
  /// In en, this message translates to:
  /// **'Hide data'**
  String get hideData;

  /// No description provided for @quantityA.
  ///
  /// In en, this message translates to:
  /// **'Quantity A'**
  String get quantityA;

  /// No description provided for @quantityB.
  ///
  /// In en, this message translates to:
  /// **'Quantity B'**
  String get quantityB;

  /// No description provided for @pickOne.
  ///
  /// In en, this message translates to:
  /// **'Select one answer choice.'**
  String get pickOne;

  /// No description provided for @pickPerBlank.
  ///
  /// In en, this message translates to:
  /// **'For each blank, select one entry from its column.'**
  String get pickPerBlank;

  /// No description provided for @pickTwo.
  ///
  /// In en, this message translates to:
  /// **'Select exactly two answer choices that complete the sentence with the same meaning.'**
  String get pickTwo;

  /// No description provided for @pickAll.
  ///
  /// In en, this message translates to:
  /// **'Select all the answer choices that apply.'**
  String get pickAll;

  /// No description provided for @pickSentence.
  ///
  /// In en, this message translates to:
  /// **'Select the sentence.'**
  String get pickSentence;

  /// No description provided for @enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your answer as an integer or a decimal.'**
  String get enterNumber;

  /// No description provided for @enterFraction.
  ///
  /// In en, this message translates to:
  /// **'Enter your answer as a fraction. Equivalent fractions are accepted.'**
  String get enterFraction;

  /// No description provided for @blankLabel.
  ///
  /// In en, this message translates to:
  /// **'Blank ({numeral})'**
  String blankLabel(String numeral);

  /// No description provided for @numerator.
  ///
  /// In en, this message translates to:
  /// **'Numerator'**
  String get numerator;

  /// No description provided for @denominator.
  ///
  /// In en, this message translates to:
  /// **'Denominator'**
  String get denominator;

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get yourAnswer;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get correctAnswer;

  /// No description provided for @correctAnswerIs.
  ///
  /// In en, this message translates to:
  /// **'Answer: {value}'**
  String correctAnswerIs(String value);

  /// No description provided for @explanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanation;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check answer'**
  String get check;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @estimatedScores.
  ///
  /// In en, this message translates to:
  /// **'Estimated scores'**
  String get estimatedScores;

  /// No description provided for @scoreRange.
  ///
  /// In en, this message translates to:
  /// **'likely {low}-{high}'**
  String scoreRange(int low, int high);

  /// No description provided for @scoreOutOf.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total}'**
  String scoreOutOf(int correct, int total);

  /// No description provided for @totalScore.
  ///
  /// In en, this message translates to:
  /// **'Verbal + Quant: {total} (260-340 scale)'**
  String totalScore(int total);

  /// No description provided for @notRated.
  ///
  /// In en, this message translates to:
  /// **'rate your essay'**
  String get notRated;

  /// No description provided for @selfRated.
  ///
  /// In en, this message translates to:
  /// **'self-rated'**
  String get selfRated;

  /// No description provided for @reviewAnswers.
  ///
  /// In en, this message translates to:
  /// **'Review answers and explanations'**
  String get reviewAnswers;

  /// No description provided for @rateEssay.
  ///
  /// In en, this message translates to:
  /// **'Rate your essay against a model'**
  String get rateEssay;

  /// No description provided for @essayAndModel.
  ///
  /// In en, this message translates to:
  /// **'Your essay and the model answer'**
  String get essayAndModel;

  /// No description provided for @sectionN.
  ///
  /// In en, this message translates to:
  /// **'Section {number}'**
  String sectionN(int number);

  /// No description provided for @routeHard.
  ///
  /// In en, this message translates to:
  /// **'harder'**
  String get routeHard;

  /// No description provided for @routeEasy.
  ///
  /// In en, this message translates to:
  /// **'easier'**
  String get routeEasy;

  /// No description provided for @skippedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} not answered'**
  String skippedCount(int count);

  /// No description provided for @byType.
  ///
  /// In en, this message translates to:
  /// **'By question type'**
  String get byType;

  /// No description provided for @weakTopics.
  ///
  /// In en, this message translates to:
  /// **'Topics to work on'**
  String get weakTopics;

  /// No description provided for @scoreDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Practice estimate. ETS equates each test form statistically; these scores follow the shape of the real scale but cannot match it exactly. Use them to track progress over several mocks.'**
  String get scoreDisclaimer;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backHome;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Answer review'**
  String get reviewTitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get filterWrong;

  /// No description provided for @filterSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get filterSkipped;

  /// No description provided for @filterMarked.
  ///
  /// In en, this message translates to:
  /// **'Marked'**
  String get filterMarked;

  /// No description provided for @filterEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here.'**
  String get filterEmpty;

  /// No description provided for @notAnswered.
  ///
  /// In en, this message translates to:
  /// **'not answered'**
  String get notAnswered;

  /// No description provided for @yourEssay.
  ///
  /// In en, this message translates to:
  /// **'Your essay'**
  String get yourEssay;

  /// No description provided for @essayEmpty.
  ///
  /// In en, this message translates to:
  /// **'(No essay written.)'**
  String get essayEmpty;

  /// No description provided for @strongResponse.
  ///
  /// In en, this message translates to:
  /// **'What a strong response does'**
  String get strongResponse;

  /// No description provided for @modelEssay.
  ///
  /// In en, this message translates to:
  /// **'Model essay'**
  String get modelEssay;

  /// No description provided for @modelEssayNote.
  ///
  /// In en, this message translates to:
  /// **'One way to earn a 6. Many different positions can score just as well.'**
  String get modelEssayNote;

  /// No description provided for @rateYourself.
  ///
  /// In en, this message translates to:
  /// **'Rate yourself'**
  String get rateYourself;

  /// No description provided for @rateYourselfHelp.
  ///
  /// In en, this message translates to:
  /// **'Tick each statement that is true of your essay, then adjust the score honestly.'**
  String get rateYourselfHelp;

  /// No description provided for @criterionPosition.
  ///
  /// In en, this message translates to:
  /// **'Takes a clear, thoughtful position that answers the specific task.'**
  String get criterionPosition;

  /// No description provided for @criterionReasons.
  ///
  /// In en, this message translates to:
  /// **'Supports it with compelling reasons and specific, well-chosen examples.'**
  String get criterionReasons;

  /// No description provided for @criterionOrganisation.
  ///
  /// In en, this message translates to:
  /// **'Is well organized: each paragraph has a clear job and ideas connect logically.'**
  String get criterionOrganisation;

  /// No description provided for @criterionTask.
  ///
  /// In en, this message translates to:
  /// **'Deals with the complexity the instructions ask for (counterarguments, conditions, consequences).'**
  String get criterionTask;

  /// No description provided for @criterionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Uses precise words and varied sentences.'**
  String get criterionLanguage;

  /// No description provided for @criterionMechanics.
  ///
  /// In en, this message translates to:
  /// **'Has few errors of grammar, usage or spelling, none that obscure meaning.'**
  String get criterionMechanics;

  /// No description provided for @suggestedScore.
  ///
  /// In en, this message translates to:
  /// **'Suggested score: {score}'**
  String suggestedScore(String score);

  /// No description provided for @saveScore.
  ///
  /// In en, this message translates to:
  /// **'Save score {score}'**
  String saveScore(String score);

  /// No description provided for @scoreSaved.
  ///
  /// In en, this message translates to:
  /// **'Score saved'**
  String get scoreSaved;

  /// No description provided for @practiceIntro.
  ///
  /// In en, this message translates to:
  /// **'Every GRE topic, each with a lesson and its own practice questions (never used in the mock tests). Answers and explanations show as you go.'**
  String get practiceIntro;

  /// No description provided for @lesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get lesson;

  /// No description provided for @lessonHelp.
  ///
  /// In en, this message translates to:
  /// **'Methods, worked examples and traps'**
  String get lessonHelp;

  /// No description provided for @practiceSet.
  ///
  /// In en, this message translates to:
  /// **'Practice 10 questions'**
  String get practiceSet;

  /// No description provided for @practicePool.
  ///
  /// In en, this message translates to:
  /// **'{count} practice questions'**
  String practicePool(int count);

  /// No description provided for @practiceTally.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct so far'**
  String practiceTally(int correct, int total);

  /// No description provided for @practiceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No practice questions here yet.'**
  String get practiceEmpty;

  /// No description provided for @practiceDone.
  ///
  /// In en, this message translates to:
  /// **'Set complete'**
  String get practiceDone;

  /// No description provided for @practiceAgain.
  ///
  /// In en, this message translates to:
  /// **'Another set'**
  String get practiceAgain;

  /// No description provided for @backToTopic.
  ///
  /// In en, this message translates to:
  /// **'Back to topic'**
  String get backToTopic;

  /// No description provided for @practiceNow.
  ///
  /// In en, this message translates to:
  /// **'Practice this topic'**
  String get practiceNow;

  /// No description provided for @readingTime.
  ///
  /// In en, this message translates to:
  /// **'About {minutes} minutes'**
  String readingTime(int minutes);

  /// No description provided for @levelName.
  ///
  /// In en, this message translates to:
  /// **'{level, select, 1{Easy} 2{Medium} other{Hard}}'**
  String levelName(String level);

  /// No description provided for @essayPracticeIntro.
  ///
  /// In en, this message translates to:
  /// **'Pick a prompt. You get 30 minutes, then compare your essay with a model answer and rate it.'**
  String get essayPracticeIntro;

  /// No description provided for @vocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary flashcards'**
  String get vocabulary;

  /// No description provided for @vocabularyHelp.
  ///
  /// In en, this message translates to:
  /// **'High-frequency GRE words with meanings, examples and synonyms'**
  String get vocabularyHelp;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @includeKnown.
  ///
  /// In en, this message translates to:
  /// **'Include words I know'**
  String get includeKnown;

  /// No description provided for @vocabProgress.
  ///
  /// In en, this message translates to:
  /// **'{known} of {total} words known'**
  String vocabProgress(int known, int total);

  /// No description provided for @vocabDone.
  ///
  /// In en, this message translates to:
  /// **'You have marked every word as known. Switch on \"Include words I know\" to review.'**
  String get vocabDone;

  /// No description provided for @cardOf.
  ///
  /// In en, this message translates to:
  /// **'Card {number} of {total}'**
  String cardOf(int number, int total);

  /// No description provided for @markKnown.
  ///
  /// In en, this message translates to:
  /// **'I know this'**
  String get markKnown;

  /// No description provided for @unmarkKnown.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get unmarkKnown;

  /// No description provided for @tapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to see the meaning'**
  String get tapToReveal;

  /// No description provided for @synonyms.
  ///
  /// In en, this message translates to:
  /// **'Synonyms: {list}'**
  String synonyms(String list);

  /// No description provided for @progressEmpty.
  ///
  /// In en, this message translates to:
  /// **'Take a mock test or a practice set and your progress shows here.'**
  String get progressEmpty;

  /// No description provided for @testsTaken.
  ///
  /// In en, this message translates to:
  /// **'Mocks taken'**
  String get testsTaken;

  /// No description provided for @averageVerbal.
  ///
  /// In en, this message translates to:
  /// **'Average Verbal'**
  String get averageVerbal;

  /// No description provided for @averageQuant.
  ///
  /// In en, this message translates to:
  /// **'Average Quant'**
  String get averageQuant;

  /// No description provided for @recentAverage.
  ///
  /// In en, this message translates to:
  /// **'Last 3 mocks: Verbal {verbal}, Quant {quant}'**
  String recentAverage(int verbal, int quant);

  /// No description provided for @topicMastery.
  ///
  /// In en, this message translates to:
  /// **'Weakest topics'**
  String get topicMastery;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @percentLabel.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String percentLabel(int percent);

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacy;

  /// No description provided for @privacyChoices.
  ///
  /// In en, this message translates to:
  /// **'Privacy choices (ads)'**
  String get privacyChoices;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get terms;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact: homilabs.smc@gmail.com'**
  String get contact;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Prep Simulator for GRE is an independent practice app by HomiLabs. GRE® is a registered trademark of ETS. This app is not endorsed or approved by ETS and is not affiliated with it. All questions, passages, essay prompts, lessons and explanations are original practice material written for this app, not real test questions, and scores are practice estimates only.'**
  String get aboutBody;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
