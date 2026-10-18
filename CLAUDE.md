# CLAUDE.md | REQUIRED context for any coding assistant

You are continuing **HATUA**, a Kenya-first Android product for verified economic opportunity discovery and safe, voluntary addiction support signposting. Start with this file, then `docs/HANDOFF.md`, `docs/ROADMAP.md`, and `docs/SAFETY_PRIVACY.md` before changing code.

## Operating agreement

- Owner's priority: useful, trustworthy Android mobile app with eventual sustainable income. Do not pivot into a generic AI chatbot or inventory/POS product.
- Be explicit about what works, what is mocked, what is untested. Do not invent metrics, citations, clinical evidence, verified partners, or commitments.
- **Never introduce addiction diagnosis, detox advice, autonomous counselling, relapse predictions, or paid access to essential support.** Refer clinical decisions to qualified professionals.
- Recovery data must never appear in employment recommendations, employer products or ads. Separate opt-in, consent, minimal collection, and strong permissions are non-negotiable.
- No unverified job/provider listings in the public API. `PublishedQuerySet.published()` (backend/directory/models.py) is the ONLY public filter: `is_verified` AND `is_active` AND a `last_verified_at` within `HATUA_VERIFICATION_MAX_AGE_DAYS`; opportunities also exclude expired deadlines. Preserve this; never add a second, weaker filter.
- Keep free guest access for public discovery and contact information. Accessibility, small downloads, affordable data and offline public content are core requirements.
- Before adding registration, referrals, analytics or partner case management, complete threat model, privacy review, and appropriate regulatory/clinical review.
- Prefer narrow, tested, documented changes. Don't silently introduce tracking/SDKs, broad Android permissions, scraping or sensitive data collection.

## Present architecture

- `mobile/` Flutter 3.47.7 + Material 3. The Android runner in `mobile/android/` is **tracked**; do not re-run `flutter create` over it (its manifests carry deliberate privacy edits, see `mobile/README.md`). Application ID is still the placeholder `com.example.hatua_app`.
- `backend/` Django 5.2 LTS + DRF with PostgreSQL for production / SQLite for local debug.
- `backend/directory/models.py`: Opportunity and SupportResource, default unpublished; `clean()` enforces provenance; `verified_by` is staff-only.
- `backend/directory/counties.py` and `mobile/lib/src/data/counties.dart`: the 47 counties + Nationwide. Keep them identical.
- `backend/directory/views.py`: GET-only public endpoints sharing one `PublicDirectoryList` base.
- `backend/directory/admin.py`: staff curation with state filter, reviewer recording and "Revoke now"; not a partner dashboard.
- Mobile `CatalogRepository`: read-only API, 24h public offline copy, https-only in release, reports network/cache/unavailable.
- Mobile `LocalStore`: opportunity bookmarks, county and language prefs (SharedPreferences) + goals AND local application statuses encrypted by our own Android Keystore AES-GCM vault (`GoalVault.kt` + `lib/src/data/goal_vault.dart`, channel `hatua/goal_vault`). A vault failure must only disable My Plan, never block the app. Support resources are never bookmarked.
- Web: `mobile/web/` (branding, loading page with 1192, `flutter_bootstrap.js`), `mobile/vercel.json` (CSP, `/api` rewrite), `mobile/tool/web_*.sh`. On the web `CatalogRepository` calls its own origin and `GoalVault.isSupported` is false (My Plan off). Keep the build free of third-party requests (`--no-web-resources-cdn`, `tool/check_web_build.sh`).
- Directory data: curated batches in `backend/directory/seed/*.json`, applied once per database by `load_directory_seed` (runs on production deploys). Never put invented listings there; every record needs the official `source_url` that was checked. Reports: `POST /api/v1/reports/` → `ListingReport` (Admin queue), purged 90 days after handling.
- Mobile strings: `mobile/lib/l10n/app_en.arb` (template) and `app_sw.arb` (**draft** Kiswahili). Never hard-code UI text; run `flutter gen-l10n` and commit the generated files.

## Deployment

Live pilot API: https://hatua-api.vercel.app (Vercel project `hatua-api`, root `backend/`, Neon Postgres, functions in fra1). Pushing to `main` deploys production; `backend/build.py` migrates (production only) and creates the first superuser. Web app: https://hatua-web.vercel.app (Vercel project `hatua-web`, root `mobile/`, Flutter installed at build time by `tool/web_install.sh`; skipped when `mobile/` is unchanged). Cloudflare edge cache lives in `edge/` (deployed manually with wrangler). Never commit secrets or the admin path (`DJANGO_ADMIN_URL`). Runbook: `docs/DEPLOYMENT.md`.

## Existing API

- `GET /api/v1/health/`
- `GET /api/v1/opportunities/?county=&category=&q=`
- `GET /api/v1/support-resources/?county=&kind=&q=`
- `POST /api/v1/reports/` (anonymous report about a published listing)

Unknown `category`/`kind` returns 400. See `docs/API_CONTRACT.md`.

## How to start

Backend: create a Python venv, install `backend/requirements-dev.txt`, export `DJANGO_DEBUG=1`, migrate and test. Mobile: install Flutter 3.47.x stable and the Android SDK, then in `mobile/` run `flutter pub get`, `flutter gen-l10n`, `flutter analyze`, `flutter test`, and run against the local backend via `--dart-define=HATUA_API_URL=http://10.0.2.2:8000` (emulator) or `adb reverse tcp:8000 tcp:8000` + `http://127.0.0.1:8000` (USB phone).

## Validation status (updated 2026-10-18)

Locally verified: backend migrations/check/47 tests/ruff, Flutter analyze/68 tests, web release build checked in headless Chromium (CSP, no third-party requests), edge Worker 11 tests, live Vercel deployment checks, release APK, real-font screenshots, debug APK build with merged-manifest inspection, live API smoke test. NOT yet verified: release APK (Maven Central rate limiting locally; CI builds and checks it), device run, TalkBack, GitHub Actions (account billing lock). Exact commands and outcomes live in `docs/HANDOFF.md`; rerun before claiming anything is tested.

## Next PRs (suggested sequence)

1. ~~CI + build correctness~~ (PR #1). Remaining: CI green on GitHub and an APK build.
2. ~~Mobile polish~~ (PR #2). Remaining: native-speaker Kiswahili review, TalkBack pass on a device.
3. **Trustable listings**: time-limited verification, provenance rules, reviewer and revoke are done (PR #2). Report-a-problem and first real listings (desk-checked, 109 records) shipped in v0.2. Remaining: two-person review for support providers, phone re-verification with a pilot county's partners.
4. **User research**: pilot with a local NGO and users in one county, measure time to verified action. NO patient-level data.
5. **Partner portal**: build only after legal/clinical reviews and signed pilot with explicit privacy/consent requirements.

## Definition of done for changes

- Code runs on target platforms; automated tests pass, static analysis clean.
- Sensitive data access reviewed; no secrets in repository or logs.
- Document migration changes, permissions, API/schema changes, and user-visible copy.
- Add/adjust tests for both success and failure paths.
- Release notes and handoff (`docs/HANDOFF.md`) updated with last commit SHA, tested commands and next task.

## Current important design decisions

See `docs/DECISIONS.md`. Especially: Android first, guest-first, public verified directories, user support and economic opportunities separated, mobile goals local only, no private backend profiles in v0.1, no AI care features, B2B orgs as future payers.

## Copy-paste continuation prompt

> Read `CLAUDE.md`, `README.md`, `docs/HANDOFF.md`, `docs/ROADMAP.md` and `docs/SAFETY_PRIVACY.md`. Inspect the repo rather than assuming code is tested. First bootstrap Flutter Android platform, install backend deps, run the specified tests/static analysis/migration check, and fix issues. Commit changes in small coherent commits. Keep guest access, verified-only publication, and recovery-data isolation. Report exactly what passed, what failed, any safety/security concerns, and update `docs/HANDOFF.md` so another assistant can take over.

## Pending features and GitHub delivery queue (2026-10-18)

- **PR #7** (application tracker): merged 2026-10-18 at the owner's request after Flutter validation (gen-l10n, analyze, tests). Still needs a device smoke test of the legacy goal migration. Goals and application records share one vault key, so "reset" deletes both.
- **Issue #8:** partly done in v0.2 (PR #8 branch `claude/real-data-ux`): first real listings (desk-checked), details view, welcome screen, anonymous report flow with moderation queue. Still open: real-device/TalkBack test, pilot-county partner verification, privacy notice and complaint contact, native-speaker Kiswahili.
- **Issue #9:** goal subtasks, reminders, CV builder, skills/financial modules.
- **Issue #10:** addiction support and consented referrals, blocked on clinical/privacy review.
- **Issue #11:** NGO partner dashboard and billing, blocked on partner agreements/security reviews.
- **Issue #12:** optional low-cost AI search/matching, never using recovery data.

Take one reviewed PR at a time; do not mark issues as implemented. GitHub Actions still needs billing lock resolved. Changes to `main` deploy to production.
