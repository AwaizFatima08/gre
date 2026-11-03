#!/usr/bin/env python3
"""Writes lib/l10n/app_en.arb from the table below. Placeholders are {name}; they are int unless listed in STRINGS."""
import json, re
from pathlib import Path

STRINGS = {"code", "letter", "value", "list", "score", "numeral"}
T = {
 "appTitle": "Prep Simulator for GRE",
 "loadError": "Could not load this. Please restart the app. ({code})",
 "tabTests": "Mock tests", "tabPractice": "Practice", "tabGuide": "Guide", "tabProgress": "Progress", "about": "About",
 "testsIntro": "{count} full-length mock tests in the current GRE format: the essay, then two Verbal and two Quantitative sections (about 1 hour 58 minutes). Section 2 of each measure gets easier or harder depending on section 1, as on the real test.",
 "bestScore": "Best V {verbal} · Q {quant}", "vqScores": "Verbal {verbal} · Quant {quant}",
 "inProgress": "In progress", "notStarted": "Not taken",
 "sectionCount": "{count} questions", "minutesShort": "{minutes} min", "totalTime": "Total time {hours} h {minutes} min",
 "startTest": "Start mock test", "resumeTest": "Resume", "restartTest": "Start again",
 "paperRules": "Each section is timed separately. Within a section you can skip questions, mark them, go back and change answers; once a section ends you cannot return to it. There is no penalty for wrong answers, so answer every question. Leaving the app pauses the clock (the real test does not). Scores, explanations and a model essay appear at the end.",
 "unofficialNote": "Independent practice test. Scores are estimates; ETS sets and scores the real GRE.",
 "previousAttempts": "Previous attempts",
 "questionOf": "Question {number} of {total}",
 "previous": "Back", "next": "Next", "review": "Review", "endSection": "End section", "finish": "Finish",
 "mark": "Mark", "marked": "Marked", "answered": "Answered", "answeredOf": "{answered} of {total} answered",
 "clearAnswer": "Clear answer", "calculator": "Calculator", "transferDisplay": "Transfer display to answer box",
 "timeLeft": "Time left in this section",
 "leaveTitle": "Leave the test?", "leaveBody": "Your answers are saved and the clock pauses. You can resume from the Mock tests tab.", "stay": "Stay", "leave": "Leave",
 "endSectionTitle": "End this section?", "finishTitle": "Finish the test?",
 "endSectionBody": "You cannot return to this section after it ends.", "unansweredWarning": "{count, plural, =1{1 question is not answered.} other{{count} questions are not answered.}} There is no penalty for guessing.",
 "keepWorking": "Keep working", "finishTest": "Finish and see scores",
 "stageOf": "Part {number} of {total}", "stageSize": "{count} questions · {minutes} minutes", "essayMinutes": "One essay · {minutes} minutes",
 "beginSection": "Begin",
 "introWriting": "Analyze an Issue. Read the statement and the instructions, then plan and write a response that develops your position with reasons and examples. Raters reward a clear position, strong development, organization and control of language. There is no spell-check. Aim for 400-600 words.",
 "introVerbal": "Text completion, sentence equivalence and reading questions. Read each question's instructions: some need one answer, some two, some every correct choice. You can move freely within the section and mark questions to revisit.",
 "introQuant": "Quantitative comparison, multiple choice and numeric entry questions, some based on data displays. Use the calculator (top right) for awkward arithmetic only. Figures are not necessarily drawn to scale unless stated.",
 "introAdaptive": "This first section is of medium difficulty. How you do here decides whether the second section of this measure is easier or harder, and the harder section opens the top of the score scale.",
 "measureWriting": "Analytical Writing", "measureWritingShort": "Writing", "measureVerbal": "Verbal Reasoning", "measureQuant": "Quantitative Reasoning",
 "measureSection": "{measure} · Section {part}",
 "stageShort": "{measure} {part}", "measureVerbalShort": "Verbal", "measureQuantShort": "Quant",
 "essayHint": "Write your response here", "wordCount": "{count, plural, =1{1 word} other{{count} words}}", "finishEssay": "Finish and compare",
 "passageTitle": "Passage", "dataTitle": "Data", "readPassage": "Show passage", "hidePassage": "Hide passage", "showData": "Show data", "hideData": "Hide data",
 "quantityA": "Quantity A", "quantityB": "Quantity B",
 "pickOne": "Select one answer choice.", "pickPerBlank": "For each blank, select one entry from its column.",
 "pickTwo": "Select exactly two answer choices that complete the sentence with the same meaning.",
 "pickAll": "Select all the answer choices that apply.", "pickSentence": "Select the sentence.",
 "enterNumber": "Enter your answer as an integer or a decimal.", "enterFraction": "Enter your answer as a fraction. Equivalent fractions are accepted.",
 "blankLabel": "Blank ({numeral})", "numerator": "Numerator", "denominator": "Denominator", "yourAnswer": "Your answer",
 "correct": "Correct", "incorrect": "Incorrect", "correctAnswer": "Correct answer", "correctAnswerIs": "Answer: {value}",
 "explanation": "Explanation", "check": "Check answer",
 "results": "Results", "estimatedScores": "Estimated scores", "scoreRange": "likely {low}-{high}", "scoreOutOf": "{correct} of {total}",
 "totalScore": "Verbal + Quant: {total} (260-340 scale)", "notRated": "rate your essay", "selfRated": "self-rated",
 "reviewAnswers": "Review answers and explanations", "rateEssay": "Rate your essay against a model", "essayAndModel": "Your essay and the model answer",
 "sectionN": "Section {number}", "routeHard": "harder", "routeEasy": "easier", "skippedCount": "{count} not answered",
 "byType": "By question type", "weakTopics": "Topics to work on",
 "scoreDisclaimer": "Practice estimate. ETS equates each test form statistically; these scores follow the shape of the real scale but cannot match it exactly. Use them to track progress over several mocks.",
 "backHome": "Back to home", "reviewTitle": "Answer review",
 "filterAll": "All", "filterWrong": "Wrong", "filterSkipped": "Skipped", "filterMarked": "Marked", "filterEmpty": "Nothing here.", "notAnswered": "not answered",
 "yourEssay": "Your essay", "essayEmpty": "(No essay written.)", "strongResponse": "What a strong response does",
 "modelEssay": "Model essay", "modelEssayNote": "One way to earn a 6. Many different positions can score just as well.",
 "rateYourself": "Rate yourself", "rateYourselfHelp": "Tick each statement that is true of your essay, then adjust the score honestly.",
 "criterionPosition": "Takes a clear, thoughtful position that answers the specific task.",
 "criterionReasons": "Supports it with compelling reasons and specific, well-chosen examples.",
 "criterionOrganisation": "Is well organized: each paragraph has a clear job and ideas connect logically.",
 "criterionTask": "Deals with the complexity the instructions ask for (counterarguments, conditions, consequences).",
 "criterionLanguage": "Uses precise words and varied sentences.",
 "criterionMechanics": "Has few errors of grammar, usage or spelling, none that obscure meaning.",
 "suggestedScore": "Suggested score: {score}", "saveScore": "Save score {score}", "scoreSaved": "Score saved",
 "practiceIntro": "Every GRE topic, each with a lesson and its own practice questions (never used in the mock tests). Answers and explanations show as you go.",
 "lesson": "Lesson", "lessonHelp": "Methods, worked examples and traps", "practiceSet": "Practice 10 questions",
 "practicePool": "{count} practice questions", "practiceTally": "{correct} of {total} correct so far",
 "practiceEmpty": "No practice questions here yet.", "practiceDone": "Set complete", "practiceAgain": "Another set",
 "backToTopic": "Back to topic", "practiceNow": "Practice this topic", "readingTime": "About {minutes} minutes",
 "levelName": "{level, select, 1{Easy} 2{Medium} other{Hard}}",
 "essayPracticeIntro": "Pick a prompt. You get 30 minutes, then compare your essay with a model answer and rate it.",
 "vocabulary": "Vocabulary flashcards", "vocabularyHelp": "High-frequency GRE words with meanings, examples and synonyms",
 "shuffle": "Shuffle", "includeKnown": "Include words I know", "vocabProgress": "{known} of {total} words known",
 "vocabDone": "You have marked every word as known. Switch on \"Include words I know\" to review.",
 "cardOf": "Card {number} of {total}", "markKnown": "I know this", "unmarkKnown": "Not yet", "tapToReveal": "Tap to see the meaning",
 "synonyms": "Synonyms: {list}",
 "progressEmpty": "Take a mock test or a practice set and your progress shows here.",
 "testsTaken": "Mocks taken", "averageVerbal": "Average Verbal", "averageQuant": "Average Quant",
 "recentAverage": "Last 3 mocks: Verbal {verbal}, Quant {quant}", "topicMastery": "Weakest topics", "history": "History",
 "percentLabel": "{percent}%",
 "version": "Version 1.0.0", "website": "Website", "privacy": "Privacy policy", "privacyChoices": "Privacy choices (ads)", "terms": "Terms of use",
 "contact": "Contact: homilabs.smc@gmail.com",
 "aboutBody": "Prep Simulator for GRE is an independent practice app by HomiLabs. GRE® is a registered trademark of ETS. This app is not endorsed or approved by ETS and is not affiliated with it. All questions, passages, essay prompts, lessons and explanations are original practice material written for this app, not real test questions, and scores are practice estimates only.",
}
arb = {"@@locale": "en"}
for key, text in T.items():
    arb[key] = text
    if key == "levelName":
        arb["@levelName"] = {"placeholders": {"level": {"type": "String"}}}
        continue
    names = list(dict.fromkeys(re.findall(r"\{(\w+)[,}]", text)))
    if names:
        arb[f"@{key}"] = {"placeholders": {n: {"type": "String" if n in STRINGS or n == "measure" else "int"} for n in names}}
Path(__file__).resolve().parent.parent.joinpath("lib/l10n/app_en.arb").write_text(json.dumps(arb, indent=2, ensure_ascii=False) + "\n")
print(len(T), "strings")
