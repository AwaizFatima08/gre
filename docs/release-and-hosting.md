# Release and hosting kit: Prep Simulator for GRE

## Build
- Package `com.homilabs.gre_prep` (locked after the first Play upload). Version 1.0.0 (versionCode 1).
- Build: `jobq run --name gre-release-aab -- flutter build appbundle --release`, then `./gradlew --stop` in `android/`.
- Before every release: `bash scripts/check-release-ad-ids.sh`, `python3 tool/validate.py`, `flutter test`.
- Signing: `android/key.properties` → `.secrets/gre-upload.keystore` (not created yet). `.secrets/` goes to the local and Drive backups, never GitHub.

## Website: https://gre.homilabs.org
- Hostinger: subdomain `gre.homilabs.org` created 4 Nov 2026 (folder `public_html/gre` of the homilabs.org website).
- `public_html/gre` is a git checkout of this repo's `deploy` branch (cloned over SSH, as for nts; hPanel's one Git slot for homilabs.org belongs to the games site).
- Change `website/`, commit, then `bash scripts/publish-site.sh` (pushes `deploy`, then pulls it on the server over SSH). Flush the CDN cache in hPanel if pages look stale.
- Pages: landing, `/privacy.html`, `/terms.html`, `/app-ads.txt`.
- After Play launch: replace "Coming soon on Google Play" with the Play link, and add the app to homilabs.org.

## AdMob (account homilabs.smc@gmail.com)
- Created 4 Nov 2026: app "Prep Simulator for GRE", App ID `ca-app-pub-2087846699268567~4316606727`; units banner `gre_home_banner` and interstitial `gre_results_interstitial` (ids in `config/admob.json`). Debug builds use Google test units.
- "Limited ad serving" until the Play listing is live. After launch: AdMob → Apps → this app → Add store (com.homilabs.gre_prep).
- Privacy & messaging: the account's European regulations message covers EEA/UK users (the app runs Google UMP).

## Play Console
| Item | Value |
|---|---|
| App icon 512×512 | `store-assets/icon-512.png` |
| Feature graphic | `store-assets/feature-graphic.png` |
| Privacy policy URL | https://gre.homilabs.org/privacy.html |
| Website | https://gre.homilabs.org |
| Contact email | homilabs.smc@gmail.com |
| Ads | Yes (AdMob banner on home tabs; one interstitial after results or practice) |
| App access | All functionality available without login |
| Data safety | Collected and shared: Device or other IDs (advertising ID) and app activity via the ads SDK, purpose Advertising, shared with Google AdMob; encrypted in transit. Attempts and essays stay on the device |
| Content rating | Reference/educational; No to violence, sexuality, language, drugs, gambling, purchases, user interaction |
| Target audience | 18+ |
| Category | Education |

**App name** (22 characters): `Prep Simulator for GRE`

**Short description** (80 max): `20 adaptive GRE mock tests with scores, explanations, lessons and practice.`

**Full description**:
```
Practise for the GRE General Test the way it feels on the day, in the current shorter format.

20 FULL-LENGTH MOCK TESTS
• The Analyze an Issue essay (30 min), then two Verbal Reasoning sections (12 + 15 questions) and two Quantitative Reasoning sections (12 + 15 questions), timed separately.
• Adaptive like the real test: your first section of each measure decides whether the second is easier or harder.
• Mark and review, a section clock and an on-screen calculator for Quant.
• Estimated 130-170 Verbal and Quant scores, results by section, question type and topic, and every question explained.
• Rate your essay against six clear criteria and compare it with a model essay.

EVERY QUESTION TYPE
Text completion (one to three blanks), sentence equivalence, reading comprehension with select-all and select-in-passage, quantitative comparison, multiple choice, numeric entry and data interpretation with tables and charts.

LESSONS AND PRACTICE FOR EVERY TOPIC
• Methods, worked examples and traps for each Verbal, Quant and Writing topic.
• Separate practice questions with instant answers, so practice never spoils a mock.
• Timed Issue essay practice with model answers.
• Vocabulary flashcards of high-frequency GRE words.

TIPS AND STUDY PLANS
Format and scoring, test day, time management, verbal and quant tricks, essay template, and 4, 8 and 12-week study plans.

PRIVATE AND OFFLINE
No account. Everything works offline, and your scores and essays stay on your phone. Free, with light ads, never during a test or a practice question.

Prep Simulator for GRE is independent practice material by HomiLabs. GRE® is a registered trademark of ETS. This app is not endorsed or approved by ETS and is not affiliated with it. All questions are original practice material, and scores are practice estimates.
```

## Before production (open items)
- Homi reviews the content flags in `docs/review-flags.md` and spot-checks mocks.
- Phone screenshots (2-8) for the listing.
