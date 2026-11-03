# Question bank format

Source files: `content/bank/<section>/<topic>.jsonl` (a topic may split: `<topic>-2.jsonl`, `<topic>-3.jsonl`).
One JSON object per line, UTF-8. Sections, topics, id prefixes, set sizes and targets are in `content/blueprint.json`
(`python3 tool/make_blueprint.py` prints the test targets per topic, kind and level).

## Common fields (every question)
| Field | Rule |
|---|---|
| `id` | `<prefix>-t0001` (mock pool) or `<prefix>-p0001` (practice pool). Never reuse an item across pools |
| `pool` | `test` or `practice` |
| `level` | 1 easy, 2 medium, 3 hard (GRE scale: 1 = most test takers get it, 3 = only strong scorers) |
| `type` | `tc`, `se`, `mc`, `ma`, `sip`, `qc`, `ne` or `essay` (see below) |
| `stem` | the question text. Plain Unicode maths (x², √2, π, ≤, ≠, ×, ÷, ½ or 1/2, x^(n+1) for complex exponents). No LaTeX |
| `explanation` | teaches the answer: the key step or clue, then why the most tempting wrong choice is wrong. 2-6 sentences; quant shows the working |
| `set` | id of the set line (passage or data display) the question belongs to; required in set topics |
| `table` | optional: list of equal-length rows of strings, first row is the header |
| `chart` | optional: `{"kind":"bar"|"line"|"pie","title":"...","labels":["2019","2020"],"series":[{"name":"Sales","values":[12,15]}],"unit":"millions of dollars"}`. Pie: one series, values are the slice sizes (percent if `unit` is "%") |
| `figure` | optional, geometry only: a small SVG string (`<svg viewBox="0 0 300 200" ...>`) with black strokes, no fill except `none` or light grey, labels as `<text>` (font-size 14+). Add "Note: Figure not drawn to scale." to the stem when it is not |

## Question types
| `type` | Where | Fields |
|---|---|---|
| `tc` text completion | verbal tc1, tc23 | `stem` marks blanks as `(i) _____`, `(ii) _____`, `(iii) _____` (one-blank items just `_____`). `blanks`: `[5]` for one blank, `[3,3]` or `[3,3,3]`. `options`: flat list, blank (i)'s choices first. `answer`: one index per blank into the flat list, e.g. `[1,4]` for a two-blank item (blank ii's choices are indexes 3-5) |
| `se` sentence equivalence | verbal se | one `_____` in the stem, 6 `options`, `answer`: the 2 indexes (ascending) |
| `mc` multiple choice, one answer | RC (5 options), quant ps (5 options) | `options`, `answer: [i]` |
| `ma` multiple choice, one or more answers | RC (exactly 3 options, 1-3 correct), quant ps (3-8 options, at least 1 correct) | stem says "Select all that apply." (RC) or "Indicate all such ..." (quant); `answer`: ascending indexes |
| `sip` select in passage | RC only | `options`: the candidate sentences, each copied character-for-character from the passage (whole passage, or the paragraph the stem names); `answer: [i]` |
| `qc` quantitative comparison | quant | `stem`: the centred information ("" if none), `qa`: Quantity A, `qb`: Quantity B. No `options`. `answer: [0]` A greater, `[1]` B greater, `[2]` equal, `[3]` cannot be determined |
| `ne` numeric entry | quant ps | `numeric`: the exact answer as a string: integer or decimal (`"12"`, `"0.75"`, `"-3.5"`) or a fraction (`"3/8"`) when the answer box is a fraction. Equivalent values are accepted. Stem states rounding if needed ("Give your answer to the nearest whole number.") |
| `essay` | writing issue | `stem`: the issue statement, `task`: the instruction paragraph, `explanation`: a model essay that would score 6 (480-650 words, paragraphs separated by `\n\n`), `points`: 4-6 strings, what a strong response does with this prompt. No `options` or `answer` |

## Sets
A set line comes before its questions in the same file:
```json
{"type":"set","id":"vr-ts001","pool":"test","level":2,"title":"","text":"passage ..."}
```
- Set ids: `<prefix>-ts001` (test) or `<prefix>-ps001` (practice).
- Topics with `set_size` > 0 put every question in a set of exactly that many questions; all questions of a set share
  the set's `pool` and `level`.
- RC passages go in `text` (paragraphs separated by `\n\n`). Data-interpretation sets put the display in `table`
  and/or `chart` on the set (a set may have both, or two charts as `chart` and `chart2`) and a one-line `text` naming
  the data ("Annual revenue of Company X by division, 2019-2023").

## Examples
```json
{"id":"vt-t0001","pool":"test","level":1,"type":"tc","stem":"Although the critic's review was _____, the director thanked her for its candour.","blanks":[5],"options":["scathing","effusive","tentative","belated","anonymous"],"answer":[0],"explanation":"..."}
{"id":"vd-t0001","pool":"test","level":2,"type":"tc","stem":"... (i) _____ ... (ii) _____ ...","blanks":[3,3],"options":["a","b","c","d","e","f"],"answer":[2,3],"explanation":"..."}
{"id":"vs-t0001","pool":"test","level":2,"type":"se","stem":"... _____ ...","options":["a","b","c","d","e","f"],"answer":[1,4],"explanation":"..."}
{"id":"qn-t0001","pool":"test","level":1,"type":"qc","stem":"n is a positive odd integer.","qa":"The remainder when n² is divided by 2","qb":"1","answer":[2],"explanation":"..."}
{"id":"qw-t0001","pool":"test","level":2,"type":"ne","stem":"... How many hours ...?","numeric":"4.5","explanation":"..."}
```
