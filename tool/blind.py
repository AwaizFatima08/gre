#!/usr/bin/env python3
"""Answer-free copy of bank files for a blind solver, and the comparison afterwards.

  python3 tool/blind.py export <out.jsonl> file1.jsonl file2.jsonl ...
  python3 tool/blind.py compare <solver.jsonl> file1.jsonl file2.jsonl ...
Set lines are copied as they are. Solver lines: {"id": "...", "answer": [indexes], "note": "optional doubt"},
or {"id": "...", "numeric": "..."} for numeric entry. Options keep their order.
"""
import json, sys
from fractions import Fraction
from pathlib import Path


def rows(files):
    for f in files:
        for line in Path(f).read_text().splitlines():
            if line.strip():
                yield json.loads(line)


def same_number(a, b):
    try:
        return Fraction(a) == Fraction(b)
    except (ValueError, ZeroDivisionError):
        return False


cmd, out, *files = sys.argv[1:]
if cmd == "export":
    with open(out, "w") as fh:
        for r in rows(files):
            if r.get("type") == "essay":
                continue
            for key in ("answer", "explanation", "numeric"):
                r.pop(key, None)
            fh.write(json.dumps(r, ensure_ascii=False) + "\n")
else:
    solved = {r["id"]: r for r in rows([out])}
    bad = missing = ok = 0
    for r in rows(files):
        if r.get("type") in ("set", "essay"):
            continue
        s = solved.get(r["id"])
        if s is None:
            missing += 1
            print("MISSING", r["id"])
            continue
        agree = same_number(s.get("numeric", ""), r["numeric"]) if r["type"] == "ne" else sorted(s.get("answer", [])) == r["answer"]
        if agree and not s.get("note"):
            ok += 1
        else:
            bad += 1
            key = r.get("numeric", r.get("answer"))
            got = s.get("numeric", s.get("answer"))
            print(f"CHECK {r['id']}: key {key}, solver {got}. {s.get('note', '')}\n  {r['stem'][:200]}\n  {r.get('options', '')}")
    print(f"{ok} agree, {bad} to check, {missing} missing")
