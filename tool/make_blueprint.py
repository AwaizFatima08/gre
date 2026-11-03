#!/usr/bin/env python3
"""Writes content/blueprint.json: topics, per-topic targets and the GRE General Test pattern.

GRE General Test since 22 Sep 2023 (checked against ets.org, 4 Nov 2026): Analytical Writing first (one "Analyze an
Issue" task, 30 min), then Verbal and Quantitative in either order, two sections each: section 1 has 12 questions
(Verbal 18 min, Quant 21 min), section 2 has 15 (Verbal 23 min, Quant 26 min). Section 2 is easier or harder
depending on section 1. Scores 130-170 per measure, Writing 0-6 in half points.

Every mock paper holds section 1 plus BOTH versions of section 2 (easy and hard) for each measure. A slot is
(topic, kind, level, count); count is in questions, or in sets for set topics. Quant `kind` is "qc" (quantitative
comparison) or "ps" (problem solving: mc / ma / ne). Targets per topic, kind and level = slot counts x PAPERS.
"""
import collections, json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PAPERS = 20

# section key, title, [(topic key, id prefix, title, set size or 0, practice target, scope)]
SECTIONS = [
    ("verbal", "Verbal Reasoning", [
        ("tc1", "vt", "Text Completion: one blank", 0, 30,
         "Single-sentence or short two-sentence items with one blank and five choices. Contrast, cause, restatement and degree clues; GRE-level vocabulary (e.g. laconic, obdurate, mitigate, equivocal)."),
        ("tc23", "vd", "Text Completion: two and three blanks", 0, 30,
         "Two- or three-blank passages of 1-5 sentences; three choices per blank, no credit unless every blank is right. Logical structure, tone and idiom, not just vocabulary."),
        ("se", "vs", "Sentence Equivalence", 0, 30,
         "One sentence, one blank, six choices; exactly two choices give sentences alike in meaning. Include near-synonym traps that do not fit the sentence and pairs of synonyms that both fail."),
        ("rcs", "vr", "Reading: short passages", 2, 10,
         "Passages of 100-170 words (sciences, humanities, social sciences, business) with 2 questions each: main idea, detail, inference, function of a sentence, author's attitude, vocabulary in context, select-all, select-in-passage."),
        ("rcl", "vl", "Reading: long passages", 3, 6,
         "Passages of 330-450 words with 3 questions each; structure and purpose of paragraphs, contrasting views, inference, detail, select-all, select-in-passage."),
        ("arg", "va", "Reading: argument paragraphs", 1, 20,
         "One paragraph of 60-130 words presenting an argument, plan or puzzling fact with one question: weaken, strengthen, assumption, explain the discrepancy, role of a boldface portion, inference, flaw."),
    ]),
    ("quant", "Quantitative Reasoning", [
        ("num", "qn", "Integers and number properties", 0, 25,
         "Divisibility, factors and multiples, primes, GCD/LCM, remainders, odd/even, positive/negative, consecutive integers, digits, number line."),
        ("frac", "qf", "Fractions, decimals, percents and ratios", 0, 25,
         "Fraction and decimal arithmetic, percent change, successive percents, ratios and proportions, estimation, place value."),
        ("exp", "qe", "Exponents, roots and absolute value", 0, 25,
         "Exponent rules, negative and fractional exponents, roots, scientific notation, absolute value, comparing powers."),
        ("alg", "qa", "Algebra: equations and inequalities", 0, 25,
         "Linear equations, systems, inequalities (including with absolute value), simplifying expressions, factoring, symbolic manipulation."),
        ("fun", "qx", "Functions, quadratics and coordinate geometry", 0, 25,
         "Function notation and custom operations, quadratics and roots, slopes, lines, intercepts, distance and midpoint, parabolas, graphs of functions."),
        ("word", "qw", "Word problems", 0, 25,
         "Rates, speed and work, mixtures, simple and compound interest, profit and cost, ages, sequences, unit conversion."),
        ("geo1", "qg", "Lines, angles, triangles and polygons", 0, 25,
         "Parallel lines and angles, triangle angle and side rules, Pythagorean theorem and special right triangles, similar and congruent triangles, quadrilaterals and polygons, perimeter and area."),
        ("geo2", "qo", "Circles, solids and coordinate figures", 0, 25,
         "Circles (arcs, sectors, chords, tangents, inscribed angles), area of composite figures, rectangular solids and cylinders (volume, surface area), figures on the coordinate plane."),
        ("stat", "qs", "Statistics", 0, 25,
         "Mean, median, mode, range, standard deviation (concept), weighted averages, quartiles and percentiles, box plots, normal distribution, frequency distributions."),
        ("prob", "qp", "Counting, probability and sets", 0, 25,
         "Counting principle, permutations and combinations, probability of independent and dependent events, at least one, Venn diagrams and overlapping sets."),
        ("di", "qd", "Data interpretation", 3, 5,
         "A table or graph (bar, line, pie) shared by 3 questions: reading values, percent and percent change, ratios, estimation, combining two data displays."),
    ]),
    ("writing", "Analytical Writing", [
        ("issue", "wi", "Analyze an Issue", 0, 10,
         "An issue statement with one of the official-style task instructions; a model essay scoring 6 and the key points of a strong response."),
    ]),
]

# Mock paper recipes: (topic, kind or None, level, count). Counts are questions, or sets for set topics.
V1 = [("tc1", None, 1, 1), ("tc1", None, 2, 1), ("tc23", None, 2, 1), ("tc23", None, 3, 1),
      ("se", None, 1, 1), ("se", None, 2, 1), ("se", None, 3, 1),
      ("rcs", None, 1, 1), ("rcs", None, 2, 1), ("arg", None, 3, 1)]
V2_EASY = [("tc1", None, 1, 2), ("tc23", None, 1, 1), ("tc23", None, 2, 2), ("se", None, 1, 2), ("se", None, 2, 1),
           ("rcl", None, 1, 1), ("rcs", None, 2, 1), ("arg", None, 1, 1), ("arg", None, 2, 1)]
V2_HARD = [("tc1", None, 3, 2), ("tc23", None, 2, 1), ("tc23", None, 3, 2), ("se", None, 2, 1), ("se", None, 3, 2),
           ("rcl", None, 3, 1), ("rcs", None, 3, 1), ("arg", None, 2, 1), ("arg", None, 3, 1)]
Q1 = [("num", "qc", 1, 1), ("exp", "qc", 2, 1), ("geo1", "qc", 2, 1), ("stat", "qc", 3, 1),
      ("frac", "ps", 1, 1), ("alg", "ps", 1, 1), ("fun", "ps", 2, 1), ("word", "ps", 2, 1), ("geo2", "ps", 2, 1),
      ("prob", "ps", 2, 1), ("word", "ps", 3, 1), ("alg", "ps", 3, 1)]
Q2_EASY = [("num", "qc", 1, 1), ("frac", "qc", 1, 1), ("geo2", "qc", 2, 1), ("alg", "qc", 2, 1), ("stat", "qc", 1, 1),
           ("exp", "ps", 1, 1), ("fun", "ps", 1, 1), ("word", "ps", 1, 1), ("geo1", "ps", 2, 1), ("prob", "ps", 2, 1),
           ("word", "ps", 2, 1), ("num", "ps", 2, 1), ("di", None, 1, 1)]
Q2_HARD = [("num", "qc", 3, 1), ("frac", "qc", 2, 1), ("geo2", "qc", 3, 1), ("alg", "qc", 3, 1), ("stat", "qc", 2, 1),
           ("exp", "ps", 3, 1), ("fun", "ps", 3, 1), ("word", "ps", 3, 1), ("geo1", "ps", 3, 1), ("prob", "ps", 3, 1),
           ("word", "ps", 2, 1), ("num", "ps", 2, 1), ("di", None, 3, 1)]

MEASURES = {
    "verbal": {"title": "Verbal Reasoning", "s1": V1, "easy": V2_EASY, "hard": V2_HARD,
               "minutes": [18, 23], "counts": [12, 15]},
    "quant": {"title": "Quantitative Reasoning", "s1": Q1, "easy": Q2_EASY, "hard": Q2_HARD,
              "minutes": [21, 26], "counts": [12, 15]},
}

SET_SIZE = {t[0]: t[3] for _, _, ts in SECTIONS for t in ts}


def questions(recipe):
    return sum(n * (SET_SIZE[t] or 1) for t, _, _, n in recipe)


for key, m in MEASURES.items():
    assert questions(m["s1"]) == m["counts"][0], (key, "s1", questions(m["s1"]))
    assert questions(m["easy"]) == questions(m["hard"]) == m["counts"][1], key

targets = collections.Counter()  # (topic, kind, level) -> questions (or sets for set topics) in the test pool
for m in MEASURES.values():
    for stage in ("s1", "easy", "hard"):
        for t, kind, level, n in m[stage]:
            targets[(t, kind or "", level)] += n * PAPERS
targets[("issue", "", 2)] = PAPERS  # one essay prompt per paper; write every prompt at level 2

doc = {
    "papers": PAPERS,
    "sections": [
        {"key": k, "title": title, "topics": [
            {"key": tk, "prefix": p, "title": tt, "set_size": size, "practice": prac, "scope": scope,
             "test": {f"{kind or 'any'}/L{lv}": n for (t, kind, lv), n in sorted(targets.items()) if t == tk},
             "test_unit": "sets" if size else "questions"}
            for tk, p, tt, size, prac, scope in topics
        ]} for k, title, topics in SECTIONS
    ],
    "writing": {"minutes": 30, "test_prompts": PAPERS},
    "measures": {k: {"title": m["title"], "minutes": m["minutes"], "counts": m["counts"],
                     "stages": {s: [{"topic": t, "kind": kind, "level": lv, "count": n} for t, kind, lv, n in m[s]]
                                for s in ("s1", "easy", "hard")}}
                 for k, m in MEASURES.items()},
    "route_hard_at": {"verbal": 7, "quant": 7},
}
prefixes = [t[1] for *_, ts in SECTIONS for t in ts]
assert len(prefixes) == len(set(prefixes)), "duplicate prefix"
(ROOT / "content/blueprint.json").write_text(json.dumps(doc, indent=1) + "\n")
total = sum(n * (SET_SIZE[t] or 1) for (t, _, _), n in targets.items() if t != "issue")
print("test questions", total, "+", PAPERS, "essay prompts")
for (t, kind, lv), n in sorted(targets.items()):
    print(f"  {t:5} {kind or '-':3} L{lv}: {n}{' sets' if SET_SIZE[t] else ''}")
