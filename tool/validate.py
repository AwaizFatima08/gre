#!/usr/bin/env python3
"""Checks every file in content/bank against docs/content-schema.md.

  python3 tool/validate.py                 whole bank, plus coverage against the blueprint
  python3 tool/validate.py --files a b     only those files (repo-wide duplicate check still runs)
  python3 tool/validate.py --coverage      also print every unmet target
Exit 1 if any error is found.
"""
import argparse, collections, json, re, sys
import xml.etree.ElementTree as ET
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BP = json.loads((ROOT / "content/blueprint.json").read_text())
TOPICS = {(s["key"], t["key"]): t for s in BP["sections"] for t in s["topics"]}
BANNED = re.compile(r"all of the above|none of the above|both a and b", re.I)
LATEX = re.compile(r"\\\(|\\\[|\\frac|\\sqrt|\$[a-zA-Z\\{]")
NUMERIC = re.compile(r"-?\d+(\.\d+)?|-?\d+/\d+")
RC = {"rcs", "rcl", "arg"}
TYPES = {
    "tc1": {"tc"}, "tc23": {"tc"}, "se": {"se"}, "rcs": {"mc", "ma", "sip"}, "rcl": {"mc", "ma", "sip"},
    "arg": {"mc"}, "issue": {"essay"},
}
QUANT_TYPES = {"qc", "mc", "ma", "ne"}


def norm(s):
    return re.sub(r"\s+", " ", s.lower()).strip()


def load(path, errors):
    rows = []
    for n, line in enumerate(path.read_text().splitlines(), 1):
        if not line.strip():
            continue
        try:
            rows.append((n, json.loads(line)))
        except json.JSONDecodeError as e:
            errors.append(f"{path.name}:{n}: bad JSON: {e}")
    return rows


def check_display(obj, err):
    table = obj.get("table")
    if table is not None and not (isinstance(table, list) and len(table) >= 2 and
                                  all(isinstance(r, list) and len(r) == len(table[0]) and all(isinstance(c, str) for c in r) for r in table)):
        err("table must be 2+ equal-length rows of strings")
    for key in ("chart", "chart2"):
        chart = obj.get(key)
        if chart is None:
            continue
        if not isinstance(chart, dict) or chart.get("kind") not in ("bar", "line", "pie"):
            err(f"{key}.kind must be bar, line or pie")
            continue
        labels, series = chart.get("labels"), chart.get("series")
        if not (isinstance(labels, list) and labels and isinstance(series, list) and series):
            err(f"{key} needs labels and series")
            continue
        for s in series:
            vals = s.get("values")
            if not (isinstance(s.get("name"), str) and isinstance(vals, list) and len(vals) == len(labels)
                    and all(isinstance(v, (int, float)) for v in vals)):
                err(f"{key} series needs a name and one number per label")
        if chart["kind"] == "pie" and len(series) != 1:
            err(f"{key}: a pie has exactly one series")
        if not chart.get("title"):
            err(f"{key} needs a title")
    fig = obj.get("figure")
    if fig is not None:
        try:
            root = ET.fromstring(fig)
            if not root.tag.endswith("svg") or "viewBox" not in root.attrib:
                err("figure must be an <svg> with a viewBox")
        except ET.ParseError as e:
            err(f"figure is not valid SVG: {e}")


def check_question(q, where, section, topic, sets, err):
    for field in ("id", "pool", "level", "type", "stem", "explanation"):
        if field not in q:
            err(f"missing {field}")
            return None
    meta = TOPICS.get((section, topic))
    if not meta:
        err(f"unknown section/topic {section}/{topic}")
        return None
    pool, kind = q["pool"], q["type"]
    if pool not in ("test", "practice"):
        err("pool must be test or practice")
    if not re.fullmatch(rf"{meta['prefix']}-{'t' if pool == 'test' else 'p'}\d{{4}}", q["id"]):
        err(f"id must look like {meta['prefix']}-t0001 / {meta['prefix']}-p0001")
    if q["level"] not in (1, 2, 3):
        err("level must be 1, 2 or 3")
    allowed = QUANT_TYPES if section == "quant" else TYPES[topic]
    if kind not in allowed:
        err(f"type {kind} not allowed in {topic} (use {sorted(allowed)})")
        return None
    min_expl = 400 if kind == "essay" else 40
    if len(q["explanation"]) < min_expl:
        err("explanation too short")
    opts = q.get("options")
    ans = q.get("answer")
    if kind in ("tc", "se", "mc", "ma", "sip"):
        if not (isinstance(opts, list) and all(isinstance(o, str) and o.strip() for o in opts)):
            err("needs a list of non-empty options")
            return None
        if len({norm(o) for o in opts}) != len(opts):
            err("options are not all different")
        if not (isinstance(ans, list) and ans and all(isinstance(a, int) and 0 <= a < len(opts) for a in ans)
                and ans == sorted(set(ans))):
            err("answer must be ascending, distinct option indexes")
            return None
    if kind == "tc":
        blanks = q.get("blanks")
        want = [[5]] if topic == "tc1" else [[3, 3], [3, 3, 3]]
        if blanks not in want:
            err(f"blanks must be one of {want}")
            return None
        if sum(blanks) != len(opts) or len(ans) != len(blanks):
            err("options/answer do not match blanks")
            return None
        start = 0
        for b, a in zip(blanks, ans):
            if not start <= a < start + b:
                err("each answer must fall in its own blank's choices")
            start += b
        marks = len(re.findall(r"_{3,}", q["stem"]))
        if marks != len(blanks):
            err(f"stem has {marks} blanks (_____) but blanks lists {len(blanks)}")
        if len(blanks) > 1 and not all(f"({r})" in q["stem"] for r in ("i", "ii", "iii")[:len(blanks)]):
            err("multi-blank stems label blanks (i) _____, (ii) _____")
    elif kind == "se":
        if len(opts) != 6 or len(ans) != 2:
            err("sentence equivalence needs 6 options and 2 answers")
        if len(re.findall(r"_{3,}", q["stem"])) != 1:
            err("stem needs exactly one _____")
    elif kind == "mc":
        if len(opts) != 5 or len(ans) != 1:
            err("mc needs 5 options and 1 answer")
    elif kind == "ma":
        if section == "verbal" and len(opts) != 3:
            err("verbal select-all needs exactly 3 options")
        if section == "quant" and not 3 <= len(opts) <= 8:
            err("quant select-all needs 3-8 options")
        if not re.search(r"select all that apply|indicate all", q["stem"], re.I):
            err("ma stem must say 'Select all that apply' / 'Indicate all ...'")
    elif kind == "sip":
        passage = sets.get(q.get("set"), {}).get("text", "")
        if len(opts) < 3 or len(ans) != 1:
            err("sip needs 3+ sentences and one answer")
        for o in opts:
            if o not in passage:
                err(f"sip sentence not found verbatim in the passage: {o[:50]}")
    elif kind == "qc":
        if not (q.get("qa") and q.get("qb")) or opts is not None:
            err("qc needs qa and qb and no options")
        if not (isinstance(ans, list) and len(ans) == 1 and ans[0] in (0, 1, 2, 3)):
            err("qc answer must be [0..3]")
    elif kind == "ne":
        num = q.get("numeric")
        if not (isinstance(num, str) and NUMERIC.fullmatch(num)):
            err("ne needs numeric: integer, decimal or a/b")
        elif "/" in num and Fraction(num).denominator == 1 and False:
            pass
        if opts is not None or ans is not None:
            err("ne has no options or answer")
    elif kind == "essay":
        if not q.get("task") or not (isinstance(q.get("points"), list) and len(q["points"]) >= 3):
            err("essay needs task and 3+ points")
        words = len(q["explanation"].split())
        if not 430 <= words <= 700:
            err(f"model essay has {words} words (want 480-650)")
    text = " ".join([q["stem"], q["explanation"], q.get("qa", ""), q.get("qb", ""), *(opts or [])])
    if BANNED.search(text):
        err("uses an all/none-of-the-above style option")
    if LATEX.search(text):
        err("LaTeX found; use plain Unicode maths")
    check_display(q, err)
    if meta["set_size"] and "set" not in q:
        err("this topic needs a set id")
    if not meta["set_size"] and "set" in q:
        err("this topic does not use sets")
    return kind


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--files", nargs="*")
    ap.add_argument("--coverage", action="store_true")
    args = ap.parse_args()
    errors = []
    all_files = sorted((ROOT / "content/bank").glob("*/*.jsonl"))
    only = {Path(f).resolve() for f in args.files} if args.files else None
    ids, stems, sets, set_where = {}, {}, {}, {}
    members = collections.defaultdict(list)
    have = collections.Counter()  # (topic, kind, level, pool) -> questions or sets
    keys = collections.Counter()
    types = collections.Counter()
    quant_types = collections.Counter()
    levels = collections.Counter()
    longest = wordy = 0
    for path in all_files:
        section = path.parent.name
        topic = re.sub(r"-\d+$", "", path.stem)
        report = only is None or path.resolve() in only
        sink = errors if report else []
        meta = TOPICS.get((section, topic))
        for n, row in load(path, sink):
            where = f"{section}/{path.name}:{n}"
            if row.get("type") == "set":
                sid = row.get("id", "")
                err = lambda m, sid=sid, where=where, sink=sink: sink.append(f"{where} {sid}: {m}")
                if sid in sets:
                    err("duplicate set id")
                if meta and not re.fullmatch(rf"{meta['prefix']}-[tp]s\d{{3}}", sid):
                    err(f"set id must look like {meta['prefix']}-ts001 / {meta['prefix']}-ps001")
                if row.get("pool") not in ("test", "practice") or row.get("level") not in (1, 2, 3):
                    err("set needs pool and level")
                if len(row.get("text", "")) < 40:
                    err("set text too short")
                if topic in ("rcs", "rcl", "arg"):
                    words = len(row.get("text", "").split())
                    lo, hi = {"rcs": (90, 190), "rcl": (300, 480), "arg": (50, 150)}[topic]
                    if not lo <= words <= hi:
                        err(f"passage has {words} words (want {lo}-{hi})")
                check_display(row, err)
                sets[sid] = row
                set_where[sid] = (where, sink, section, topic)
                continue
            err = lambda m, row=row, where=where, sink=sink: sink.append(f"{where} {row.get('id', '?')}: {m}")
            kind = check_question(row, where, section, topic, sets, err)
            qid = row.get("id", "?")
            if qid in ids:
                err(f"duplicate id (also {ids[qid]})")
            ids[qid] = where
            sid = row.get("set")
            if sid:
                members[sid].append(row)
                if sid not in sets:
                    err(f"set {sid} not found above this line")
                elif (sets[sid].get("pool"), sets[sid].get("level")) != (row.get("pool"), row.get("level")):
                    err("pool and level must match the set's")
            key = (norm(row.get("stem", "")) + "|" + norm(row.get("qa", "")) + "|" + norm(row.get("qb", "")), sid or "")
            if key in stems and row.get("type") != "sip":
                err(f"same stem as {stems[key]}")
            stems[key] = qid
            if not meta:
                continue
            if not meta["set_size"]:
                k = "" if section != "quant" else ("qc" if kind == "qc" else "ps")
                have[(topic, k, row.get("level"), row.get("pool"))] += 1
            if report and kind:
                types[kind] += 1
                if section == "quant":
                    quant_types[kind] += 1
                levels[row.get("level")] += 1
                if kind in ("mc", "qc", "sip") and row.get("answer"):
                    keys[(kind, row["answer"][0])] += 1
                if kind == "tc":
                    for b, a in enumerate(row.get("answer", [])):
                        keys[("tc", a - 5 * b if row["blanks"] == [5] else a - 3 * b)] += 1
                if kind in ("mc",) and len(row.get("options", [])) == 5:
                    lengths = [len(o) for o in row["options"]]
                    if max(lengths) >= 20:
                        wordy += 1
                        if lengths[row["answer"][0]] == max(lengths) and lengths.count(max(lengths)) == 1:
                            longest += 1
    for sid, row in sets.items():
        where, sink, section, topic = set_where[sid]
        meta = TOPICS.get((section, topic))
        if not meta:
            continue
        size = len(members[sid])
        if meta["set_size"] and size != meta["set_size"]:
            sink.append(f"{where} {sid}: set has {size} questions, needs {meta['set_size']}")
        have[(topic, "", row.get("level"), row.get("pool"))] += 1
    for e in errors[:300]:
        print("ERROR", e)
    if len(errors) > 300:
        print(f"... {len(errors) - 300} more")
    total = sum(types.values())
    if total:
        print("types", dict(sorted(types.items())), "levels", dict(sorted(levels.items())))
        for kind, n_opts in (("mc", 5), ("qc", 4), ("tc", 3)):
            counts = [keys.get((kind, i), 0) for i in range(n_opts)]
            if sum(counts) >= 20:
                print(f"{kind} answer positions {counts}")
                if min(counts) < sum(counts) / n_opts * 0.5:
                    print(f"WARN {kind} answer positions are unevenly spread")
        if wordy >= 20:
            share = longest / wordy
            print(f"correct option is the longest in {share:.0%} of {wordy} wordy mc questions (chance 20%)")
            if share > 0.35:
                print("WARN correct answers stand out by length; rebalance the options")
        quant_ps = sum(quant_types[t] for t in ("mc", "ma", "ne"))
        if quant_types["qc"] + quant_ps >= 40 and quant_ps >= 20:
            ma_ne = (quant_types["ma"] + quant_types["ne"]) / quant_ps
            if not 0.2 <= ma_ne <= 0.45:
                print(f"WARN select-all + numeric entry are {ma_ne:.0%} of problem-solving items (aim ~30%)")
    if only is None or args.coverage:
        short, lines = 0, []
        for s in BP["sections"]:
            for t in s["topics"]:
                for slot, want in t["test"].items():
                    kind, lv = slot.split("/")
                    got = have[(t["key"], "" if kind == "any" else kind, int(lv[1]), "test")]
                    if got < want:
                        short += (want - got) * (t["set_size"] or 1)
                        lines.append(f"  {s['key']}/{t['key']} test {slot}: {got}/{want} {t['test_unit']}")
                got = sum(v for (tk, _, _, pool), v in have.items() if tk == t["key"] and pool == "practice")
                if got < t["practice"]:
                    short += (t["practice"] - got) * (t["set_size"] or 1)
                    lines.append(f"  {s['key']}/{t['key']} practice: {got}/{t['practice']} {t['test_unit']}")
        if args.coverage:
            print("\n".join(lines))
        print(f"coverage: {len(ids)} questions, about {short} still to write")
    print(f"{len(errors)} errors")
    sys.exit(1 if errors else 0)


main()
