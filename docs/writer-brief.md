# Writer brief: Prep Simulator for GRE

You write original practice material for a HomiLabs Android app that simulates the GRE General Test (the shorter
format used since September 2023). Test takers worldwide, many of them non-native English speakers aiming at
graduate school, use it to practise. Accuracy matters more than speed: one wrong key destroys trust in the app.

## Format
Read `docs/content-schema.md` and `content/blueprint.json` (your topic's prefix, set size, scope and targets; run
`python3 tool/make_blueprint.py` to see the test targets per kind and level). Write only the files named in your task.
Write in chunks of at most 15 items (or 5 sets) per tool call, appending with Bash heredocs (`cat >> file <<'EOF'`),
and run `python3 tool/validate.py --files <your files>` after each chunk; fix every ERROR. A file is finished only
when it has 0 errors and no WARN. Use the id ranges your task gives you, so two writers never collide.

## Difficulty (match the real GRE)
- Level 1: most test takers get it right; one clear step, common vocabulary (at the level of "candid", "mitigate").
- Level 2: about half get it right; two or three steps, or a trap that catches a hurried reader.
- Level 3: only strong scorers (160+); subtle logic, harder vocabulary (e.g. "pellucid", "quixotic", "obstreperous"
  in tc/se), multi-step reasoning, or a convincing trap. Hard does not mean obscure or tedious arithmetic.

## Verbal
- Academic register like the real test: sentences and passages about science, history, the arts, economics,
  literature, social science, business. Neutral and respectful; no politics of the day, no religion, no tragedy.
- American spelling (behavior, analyze, center), as on the real GRE.
- Text completion: the answer must follow from clues in the sentence (contrast words, restatement, cause/effect),
  never from outside knowledge. Every wrong choice is a real word that fails for a stated reason. Multi-blank items
  interlock: a choice for one blank must constrain the others. Wrong answers often look right for one blank alone.
- Sentence equivalence: exactly two choices fit AND produce sentences alike in meaning. Include a trap pair of
  synonyms that do not fit, and a word that fits but has no partner. Spread the correct pair across positions.
- Reading: passages must be original prose (never paraphrase a published article) with enough substance to support
  inference. Mix question types: primary purpose, detail, inference, function of a sentence or paragraph, author's
  attitude, vocabulary in context ("In the context in which it appears, 'X' most nearly means"), select-all (ma, 3
  options, 1-3 correct), select-in-passage (sip). About 1 in 5 RC questions should be ma and 1 in 8 sip
  (short and long passages only). Argument paragraphs (arg): one mc question each: weaken, strengthen, assumption,
  resolve the paradox, boldface roles, inference, evaluate.
- Wrong choices in RC are wrong for a reason you can point to in the passage: too extreme, out of scope, reversed,
  true but irrelevant, half right.

## Quantitative
- Content stays within GRE scope: arithmetic, algebra, geometry and data analysis at high-school level, no calculus
  or trigonometry. Mix real-world contexts and pure maths.
- Quantitative comparison (qc): the four standard options are added by the app. Use "cannot be determined" (answer
  3) correctly: about a quarter of qc keys each. Classic traps: zero, negatives, fractions between 0 and 1, non-integers,
  figures not drawn to scale.
- Problem solving: about 70 % mc (5 options), 15 % ma ("Indicate all such values", 3-8 options), 15 % ne (numeric
  entry). Wrong mc options are the results of real mistakes (wrong formula, sign slip, percent of the wrong base).
- VERIFY EVERY KEY WITH CODE. For each quant item, write a short Python check (exact arithmetic with
  `fractions.Fraction` or `sympy`, brute force over cases for qc, enumerate for counting problems) in your scratch
  folder and run it. For qc, test integers, fractions, negatives and zero where the conditions allow. For ma, check
  every option. If the check disagrees with your key, fix the item. Never ship an item you could not verify.
- Geometry figures: optional `figure` SVG (see schema), simple and labelled, used when the real test would show a
  figure. Keep coordinates consistent with the stated facts or add "Note: Figure not drawn to scale."
- Data interpretation: realistic, internally consistent data (totals add up, percentages sum to 100). Questions need
  reading two values, a percent change, a ratio or an estimate. Answer choices for estimates are far enough apart.

## Explanations
Teach in 2-6 sentences: the key clue or step, the working (quant), and why the most tempting wrong choice is wrong.
Do not start with "The answer is". For tc/se, define the hard words used in the key and the main traps.

## Variety and originality
- No near-duplicates within or across files: read your files before each chunk. Vary contexts, numbers, names
  (international names: Priya, Mateo, Chen, Amara, Olga, Kwame, Sofia) and question shapes.
- Original work only. Never copy or closely reword ETS material (Official Guide, POWERPREP, ETS sample questions),
  Manhattan, Magoosh, Kaplan, Princeton Review, GregMat, websites or books. Issue statements are original too.

## Boundaries
Only write the files in your task, plus your scratch folder. Do not edit tools, the blueprint, the app or other topics.
Do not run git. Final reply at most 6 lines: files, counts by pool and level, validator result, any items you are
unsure about (by id).
