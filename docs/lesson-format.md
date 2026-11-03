# Lessons, guide articles and vocabulary

## Lessons: `content/lessons/<topic>.json` (one per blueprint topic, shown before that topic's practice)
```json
{"section":"quant","topic":"num","title":"Integers and number properties","minutes":10,"lines":["..."]}
```
## Guide articles: `content/guide/<nn>-<slug>.json` (the Guide tab, grouped by `group`, sorted by file name)
```json
{"id":"exam-format","group":"The exam","title":"GRE format at a glance","lines":["..."]}
```
## Line syntax (lessons and guide)
| Line starts with | Shows as |
|---|---|
| `## ` | heading |
| `- ` | bullet |
| `> ` | example box (worked example, sample sentence); consecutive `> ` lines form one box |
| `! ` | tip box (a trick or a trap to avoid) |
| anything else | paragraph |
Plain Unicode maths (x², √, π, ≤), no LaTeX, no Markdown tables, no bold/italic markers.
A lesson teaches every subtopic in its blueprint scope: the rule or concept, a worked example per subtopic, the
traps the GRE sets, and timing advice. 900-1800 words.

## Vocabulary: `content/vocab/<letters>.json` (flashcards)
```json
[{"w":"laconic","p":"adj.","d":"using very few words","e":"Her laconic reply, a single 'no', ended the meeting.","s":["terse","succinct"]}]
```
Definitions and example sentences are original. `s`: 1-3 synonyms (for sentence equivalence practice).
