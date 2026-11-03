#!/usr/bin/env python3
"""Builds assets/data from content/: one bank file per section, forms.json (the 20 mock papers), catalog.json,
lessons.json, guide.json and vocab.json.

Each paper holds, per measure, section 1 and both versions of section 2 (easy and hard), filled slot by slot from
the blueprint recipes. Same input gives the same papers (fixed seeds), so paper contents stay stable.
  python3 tool/build_content.py            needs the full bank
  python3 tool/build_content.py --partial  builds only the papers the bank can fill (development)
"""
import collections, json, random, re, shutil, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets/data"
BP = json.loads((ROOT / "content/blueprint.json").read_text())
PAPERS = BP["papers"]
PARTIAL = "--partial" in sys.argv
SET_SIZE = {t["key"]: t["set_size"] for s in BP["sections"] for t in s["topics"]}
SECTION_OF = {t["key"]: s["key"] for s in BP["sections"] for t in s["topics"]}
# Order of items inside a section, as on the real test: completions first, then reading and equivalence mixed;
# quantitative comparison first, then problem solving with the data set in the middle.
VERBAL_ORDER = ["tc1", "tc23", "rcs", "se", "rcl", "arg"]


def load():
    sets, questions = {}, []
    for path in sorted((ROOT / "content/bank").glob("*/*.jsonl")):
        topic = re.sub(r"-\d+$", "", path.stem)
        for line in path.read_text().splitlines():
            if not line.strip():
                continue
            row = json.loads(line)
            row["topic"], row["section"] = topic, path.parent.name
            if row.get("type") == "set":
                sets[row["id"]] = row
            else:
                questions.append(row)
    return sets, questions


def kind_of(q):
    if q["section"] != "quant" or SET_SIZE[q["topic"]]:
        return ""
    return "qc" if q["type"] == "qc" else "ps"


def units(questions, sets):
    """Test-pool units keyed by (topic, kind, level): single question ids, or the ordered ids of a set."""
    by_set = collections.defaultdict(list)
    out = collections.defaultdict(list)
    for q in questions:
        if q["pool"] != "test" or q["type"] == "essay":
            continue
        if q.get("set"):
            by_set[q["set"]].append(q["id"])
        else:
            out[(q["topic"], kind_of(q), q["level"])].append([q["id"]])
    for sid, ids in by_set.items():
        s = sets[sid]
        out[(s["topic"], "", s["level"])].append(ids)
    for key in out:
        out[key].sort()
    return out


def build_papers(pool, essays):
    """Returns the papers that can be filled, and the shortfalls."""
    papers = [{"number": k + 1, "measures": {}} for k in range(PAPERS)]
    short = []
    for measure, m in BP["measures"].items():
        need = collections.defaultdict(list)  # key -> [(stage, count)]
        for stage, slots in m["stages"].items():
            for slot in slots:
                need[(slot["topic"], slot["kind"] or "", slot["level"])].append((stage, slot["count"]))
        for k in range(PAPERS):
            papers[k]["measures"][measure] = {"s1": [], "easy": [], "hard": []}
        for key, wants in need.items():
            per_paper = sum(n for _, n in wants)
            items = list(pool.get(key, []))
            random.Random(f"{measure}/{key}").shuffle(items)
            if len(items) < per_paper * PAPERS:
                short.append(f"{measure} {key}: {len(items)}/{per_paper * PAPERS}")
            for k in range(PAPERS):
                chunk = items[k * per_paper:(k + 1) * per_paper]
                if len(chunk) < per_paper:
                    papers[k]["broken"] = True
                    continue
                for stage, n in wants:
                    papers[k]["measures"][measure][stage] += [(key[0], key[1], u) for u in chunk[:n]]
                    chunk = chunk[n:]
    built = []
    for k, paper in enumerate(papers):
        if paper.get("broken") or k >= len(essays):
            continue
        measures = {}
        for measure, stages in paper["measures"].items():
            rng = random.Random(f"order/{measure}/{k}")
            measures[measure] = {stage: order(measure, units_, rng) for stage, units_ in stages.items()}
            for stage, ids in measures[measure].items():
                want = BP["measures"][measure]["counts"][0 if stage == "s1" else 1]
                assert len(ids) == want, (k, measure, stage, len(ids))
        built.append({
            "id": f"gre-{k + 1:02d}", "number": k + 1, "title": f"Mock Test {k + 1}",
            "essay": essays[k], "order": ["verbal", "quant"] if k % 2 == 0 else ["quant", "verbal"],
            "measures": measures,
        })
    return built, short


def order(measure, stage_units, rng):
    stage_units = list(stage_units)
    rng.shuffle(stage_units)
    if measure == "verbal":
        stage_units.sort(key=lambda u: VERBAL_ORDER.index(u[0]))
        # interleave reading sets with sentence equivalence after the completions, like the real test
        head = [u for u in stage_units if u[0] in ("tc1", "tc23")]
        rest = [u for u in stage_units if u[0] not in ("tc1", "tc23")]
        rng.shuffle(rest)
        stage_units = head + rest
    else:
        qc = [u for u in stage_units if u[1] == "qc"]
        ps = [u for u in stage_units if u[1] != "qc" and u[0] != "di"]
        di = [u for u in stage_units if u[0] == "di"]
        mid = len(ps) // 2 + 1
        stage_units = qc + ps[:mid] + di + ps[mid:]
    return [i for _, _, u in stage_units for i in u]


def check(papers, pool):
    used = collections.Counter(i for p in papers for m in p["measures"].values() for ids in m.values() for i in ids)
    repeats = [i for i, n in used.items() if n > 1]
    if repeats:
        sys.exit(f"{len(repeats)} questions used twice, e.g. {repeats[:3]}")
    all_ids = {i for units_ in pool.values() for u in units_ for i in u}
    unused = all_ids - set(used)
    if unused:
        print(f"note: {len(unused)} test questions not used in any paper (more than the blueprint asks), e.g. {sorted(unused)[:5]}")


def compact(q, t):
    row = {"id": q["id"], "tp": t, "pl": q["pool"][0], "lv": q["level"], "ty": q["type"], "s": q["stem"], "e": q["explanation"]}
    for src, dst in (("options", "o"), ("answer", "a"), ("blanks", "b"), ("numeric", "n"), ("qa", "qa"), ("qb", "qb"),
                     ("set", "st"), ("table", "tb"), ("chart", "ch"), ("chart2", "ch2"), ("figure", "fg"),
                     ("task", "tk"), ("points", "pt")):
        if src in q:
            row[dst] = q[src]
    return row


def main():
    sets, questions = load()
    pool = units(questions, sets)
    essays = sorted(q["id"] for q in questions if q["type"] == "essay" and q["pool"] == "test")
    papers, short = build_papers(pool, essays)
    if short and not PARTIAL:
        sys.exit("bank is short:\n  " + "\n  ".join(short))
    check(papers, pool)
    if OUT.exists():
        shutil.rmtree(OUT)
    OUT.mkdir(parents=True)
    for s in BP["sections"]:
        rows, used_sets = [], {}
        for q in questions:
            if q["section"] != s["key"]:
                continue
            rows.append(compact(q, q["topic"]))
            if "set" in q:
                src = sets[q["set"]]
                used_sets[q["set"]] = {k2: src[k1] for k1, k2 in (("title", "t"), ("text", "x"), ("table", "tb"), ("chart", "ch"), ("chart2", "ch2")) if k1 in src}
        rows.sort(key=lambda r: r["id"])
        (OUT / f"bank_{s['key']}.json").write_text(json.dumps({"sets": used_sets, "questions": rows}, ensure_ascii=False, separators=(",", ":")))
    practice = collections.Counter(q["topic"] for q in questions if q["pool"] == "practice")
    lessons = [json.loads(p.read_text()) for p in sorted((ROOT / "content/lessons").glob("*.json"))]
    have_lesson = {l["topic"] for l in lessons}
    catalog = {
        "sections": [{"key": s["key"], "title": s["title"], "topics": [
            {"key": t["key"], "title": t["title"], "practice": practice[t["key"]], "lesson": t["key"] in have_lesson}
            for t in s["topics"]]} for s in BP["sections"]],
        "measures": [{"key": k, "title": m["title"], "minutes": m["minutes"], "counts": m["counts"], "hardAt": BP["route_hard_at"][k]}
                     for k, m in BP["measures"].items()],
        "writingMinutes": BP["writing"]["minutes"],
    }
    (OUT / "catalog.json").write_text(json.dumps(catalog, ensure_ascii=False, separators=(",", ":")))
    (OUT / "forms.json").write_text(json.dumps(papers, separators=(",", ":")))
    (OUT / "lessons.json").write_text(json.dumps(lessons, ensure_ascii=False, separators=(",", ":")))
    guide = [json.loads(p.read_text()) for p in sorted((ROOT / "content/guide").glob("*.json"))]
    (OUT / "guide.json").write_text(json.dumps({"articles": guide}, ensure_ascii=False, separators=(",", ":")))
    vocab = sorted((w for p in sorted((ROOT / "content/vocab").glob("*.json")) for w in json.loads(p.read_text())), key=lambda w: w["w"].lower())
    (OUT / "vocab.json").write_text(json.dumps(vocab, ensure_ascii=False, separators=(",", ":")))
    size = sum(f.stat().st_size for f in OUT.iterdir())
    print(f"{len(papers)} papers built, {len(questions)} questions, {len(lessons)} lessons, {len(guide)} articles, {len(vocab)} words, {size / 1e6:.1f} MB")
    if short:
        print("short (partial build):\n  " + "\n  ".join(short[:20]))


main()
