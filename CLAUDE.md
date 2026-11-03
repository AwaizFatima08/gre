# Prep Simulator for GRE (HomiLabs) — project notes

Flutter Android app simulating the GRE General Test (shorter format since Sep 2023): 20 full mock tests with
section-level adaptive section 2, estimated 130-170 scores, every answer explained, essay self-rating against a model
essay; lessons and practice for every Verbal and Quant topic; essay practice; vocabulary flashcards; guide articles.
Package `gre_prep`, app id `com.homilabs.gre_prep` (locked after the first Play upload). Launcher name "GRE Simulator".
Built on the NLE/NTS engine, reworked for GRE question types.

## Locations
- Code: `/mnt/storage/projects/gre` · GitHub `AwaizFatima08/gre` (PUBLIC repo: no secrets)
- Local backup: `/mnt/storage/project_backups/gre_backup` · Google Drive: https://drive.google.com/drive/folders/1qX-l2SJuS0QP12FsWou9-OYZ1x4Cc6q7
- Backups: `bash scripts/backup.sh` (all three layers)
- Site: https://gre.homilabs.org (Hostinger `public_html/gre`, a checkout of the `deploy` branch), source in `website/`, `bash scripts/publish-site.sh`

## Exam format (ets.org, checked 4 Nov 2026)
Analytical Writing first (one Issue task, 30 min), then Verbal (12 q/18 min, 15 q/23 min) and Quant (12 q/21 min,
15 q/26 min) in either order; section 2 easier or harder depending on section 1. `tool/make_blueprint.py` holds the
recipes; the hard route needs 7+ correct of 12 in section 1 (`route_hard_at`). Scores are estimates (`lib/core/scoring.dart`).

## Content
- `content/bank/<section>/<topic>.jsonl` (format in `docs/content-schema.md`, quality bar `docs/writer-brief.md`),
  lessons/guide/vocab in `content/lessons|guide|vocab` (`docs/lesson-format.md`).
- `python3 tool/validate.py`, `python3 tool/build_content.py` (fixed seeds: papers stay stable), `tool/blind.py`
  (independent answer check). `flutter test test/content` checks the built papers.
- Each paper holds section 1 plus both section-2 versions per measure (84 questions + essay); practice pool separate.
- Every item is original HomiLabs work. Never copy ETS (Official Guide, POWERPREP) or prep-company material.
- Items writers flagged for a human look: `docs/review-flags.md`.

## Ads
Ids in `config/admob.json`. Banner on Home tabs only; interstitial when leaving results or a practice set, 5 minutes
apart. Never on exam, review or practice question screens. Debug builds use Google test units;
`bash scripts/check-release-ad-ids.sh` before a release build.

## Gate before commit
```
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```
Heavy jobs follow `~/.claude/heavy-jobs.md`: use `jobq`, then `./gradlew --stop`.
