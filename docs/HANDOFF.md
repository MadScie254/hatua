# HATUA continuity / handoff

**Last updated:** 2026-10-18 (Africa/Nairobi) by Claude (session `session_01CVptBsR5mTRtZVvyPpazcF`).
**Repository:** https://github.com/MadScie254/hatua. Created by the owner; GitHub reports it as **public** (README asks for private until licensing is settled; owner to decide).
**Default branch:** `main`.

## Where the work is

| Branch / PR | Contents | State |
|---|---|---|
| **PR #1** | Android runner tracked and hardened, testable catalog repository, CI rework | merged (`3e6fdce`) |
| **PR #2** | time-limited verification and admin workflow, mobile filters/offline states/en+sw strings | merged (`a09c562`) |
| **PR #3** | Vercel-ready backend, `build.py`, `ensure_superuser`, Cloudflare Worker in `edge/`, `docs/DEPLOYMENT.md` | merged (`8f97523`) |
| **PR #4** | own Keystore goal vault replacing `flutter_secure_storage`; storage failure only disables My Plan (v0.1.1) | merged (`1fcc1ca`) |
| **PR #5**, **#6** | Flutter web build on Vercel `hatua-web` (self-hosted assets, CSP, `/api` rewrite, no goals on web) and its handoff | merged (`2e5de52`, `ff08e9a`) |
| **PR #7** (Codex) | private application tracker on Android, encrypted with goals; v2 vault envelope with v1 migration | merged (`611f400`) after validation here: regenerated l10n, one outdated test fixed, 56/56 |
| **PR #13** | v0.2.0: 109 real desk-checked listings via seed batches, anonymous report-a-problem + Admin queue, details page, county-first Support, welcome screen, Home 1192 band | merged (`88b1e19`) |

## Live deployment (2026-10-18)

- **API:** https://hatua-api.vercel.app/api/v1/ (Vercel project `hatua-api`, team "madscie254's projects", functions in `fra1`). Every push to `main` deploys production.
- **Database:** Neon Postgres `hatua-db` (Frankfurt), added by the owner via Vercel Storage; `DATABASE_URL`/`DATABASE_URL_UNPOOLED` injected by the integration.
- **Admin:** at the path in Vercel env `DJANGO_ADMIN_URL` (kept out of this public repo). First superuser `daniel` was created by the first production build. The owner must change the initial password and delete `DJANGO_SUPERUSER_PASSWORD` from Vercel (`docs/DEPLOYMENT.md` step 3).
- **Web app:** https://hatua-web.vercel.app (Vercel project `hatua-web`, root `mobile/`, static). First deployment `dpl_7GrJETYHS8RAU2rfrgxNj6tYK2J3` (commit `e8549a1`, branch build, therefore production): Flutter 3.47.7 installed by `tool/web_install.sh`, web compile 50 s, `check_web_build: OK`, whole build about 2 minutes. Verified from outside: `/` 200 with the CSP, `noindex`, `no-referrer`, `DENY` headers; `/api/v1/health/` 200 and `?category=casino` 400 through the rewrite (Django accepts the proxied host); `/admin/` 404 (only `/api/*` is proxied); `/font-fallback/…` 404. Headless Chromium (412×915, touch) against production: app starts, all five tabs render, only `hatua-web.vercel.app` contacted (10 requests), no page errors, no CSP violations, 1192 present in the accessibility tree, `localStorage` holds only the public directory cache, first load 3.13 MB on the wire.
- Production now builds from `main`: `dpl_8zJbpJDhMpt4CMUqR31PeCTQAmNx` (merge `2e5de52`), aliased to `hatua-web.vercel.app`; rerun of the Chromium check passed (same numbers). Locales: the app starts with `en-US`, `en-KE`, `fr-FR` (English) and `sw`, `sw-KE` (Kiswahili, as expected). It does **not** start when the browser reports the invalid tag `en-US@posix` (only seen in headless Chromium in a container without `LANG`; the engine throws "Incorrect locale information provided"); the HTML loading page with 1192 stays visible in that case. One run right after the alias switch did not start within 60 s; six later loads all started.
- **Cloudflare edge cache:** code in `edge/`, 11 tests, bundles with wrangler 4.147.0. **Not yet deployed**: needs `npx wrangler login && npx wrangler deploy` by the owner (step 4).
- First deployment `dpl_37oghX2URDUHAef6k26zCvBsvgNe` (commit `9f0dd2e`, built from the PR branch because a project's first deployment is always production): `check --deploy` passed (W021 only), all migrations applied, superuser created, `collectstatic` ran.
- Verified against production from outside: health 200; opportunities and support-resources 200 `[]` (~1 s incl. Neon wake-up); `?category=casino` 400; `/admin/` 404; staff login page 200 with CDN CSS; real staff login over HTTPS (CSRF) 302 → admin home 200; http→https 308.

**GitHub Actions has not run.** Both CI jobs on PR #1 were refused with *"The job was not started because your account is locked due to a billing issue."* The owner needs to clear this under GitHub Settings → Billing, then re-run the checks. Until then, every result below is from a local run.

## Verified locally (2026-10-18)

Environment: Linux x86_64, Python 3.13.16, Django 5.2.18, DRF 3.16.1, ruff 0.17.1, Flutter 3.47.7 (stable, rev `abaf9c5237`), Dart 3.13.5, OpenJDK 21, Android SDK platform 36 / build-tools 36.0.0.

| Command (from repo root) | Result |
|---|---|
| `cd backend && python manage.py makemigrations --check --dry-run` | No changes detected (0001 hand-authored migration matched the models; 0002 generated by Django) |
| `python manage.py migrate` (fresh SQLite) | OK |
| `python manage.py check` | 0 issues |
| `python manage.py test` | **35/35 OK** (incl. deploy helpers, ensure_superuser) |
| `ruff check .` | All checks passed (policy in `backend/ruff.toml`) |
| `DJANGO_DEBUG=0 DJANGO_SECRET_KEY='' python manage.py check` | refuses to start (RuntimeError), as intended |
| `check --deploy` with production-like env | 1 warning: `security.W021` `SECURE_HSTS_PRELOAD` off. Deliberate until the production domain is final |
| `cd mobile && flutter pub get` | OK (lockfile committed) |
| `flutter gen-l10n` | OK, generated files committed |
| `flutter analyze` | **No issues found** |
| `flutter test` | **45/45 passed** |
| `flutter test tool/screenshots/screenshots_test.dart --dart-define=SHOTS_DIR=…` | 4/4, 11 PNGs rendered with real fonts and reviewed by eye |
| Fresh clone of PR branch, new venv, `flutter pub get --enforce-lockfile`, gen-l10n diff, ARB key parity | all clean (matches what CI will run) |
| Live smoke test: `runserver` with 3 opportunities + 1 resource, `curl` every endpoint | stale (200-day) record hidden; `?county=Kisumu` → nationwide only; `?category=casino` → 400; helpline served |
| Live contract test: app's real `CatalogRepository` against that server (throwaway test, not committed) | parsed 2 opportunities + 1 resource; `+03:00` timestamps parsed; counties valid |
| `flutter build apk --release --target-platform android-arm64,android-arm --dart-define=HATUA_API_URL=https://hatua-api.vercel.app` | **Built** `app-release.apk` (34.9 MB, debug-signed); aapt2: INTERNET-only, backup off, no cleartext override, minSdk 24; API URL present in both ABIs' `libapp.so` |
| App's `CatalogRepository` (requireHttps) against production (throwaway test) | both directories `network`, 0 items (empty by design) |
| `flutter build apk --debug --target-platform android-arm64` (HEAD `1096783`) | **Built** `app-debug.apk` (after retries past Maven Central 429s) |
| `cd mobile && flutter test` (after web changes) | **48/48 passed** (adds web Plan/Settings copy tests) |
| `bash tool/web_build.sh` (local SDK) | built `build/web` (41 MB on disk incl. unused CanvasKit variants), `check_web_build: OK` |
| `build/web` behind a local HTTPS server that applies `vercel.json` headers and the `/api` rewrite (fixtures, then the live API), driven by Playwright Chromium | all tabs render; only same-origin requests; no CSP violations or page errors; My Plan shows the Android-only card; Settings shows the browser-storage privacy text; 2.67 MB brotli estimate |
| `aapt2 dump` on that APK | package `com.example.hatua_app`, label `HATUA`, minSdk 24 (Android 7.0), targetSdk 36; permissions: `INTERNET` only (+ androidx's internal signature-level `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`); `allowBackup=false`, `fullBackupContent=false`, `dataExtractionRules` set; debug `networkSecurityConfig` present; https/tel queries present |

## v0.2.0 checks (2026-10-18)

| Check | Result |
|---|---|
| GitHub "failures" on PRs #3–#7 | every job refused with *"account is locked due to a billing issue"*; no code failure. Still blocked on the owner's billing |
| `cd backend && python manage.py test` | **47/47 OK** (adds seed loader, shipped-data validity, reports: validation, CSRF-free, write-only, throttle 429, triage, purge) |
| `ruff check .`, `makemigrations --check` | clean; one new migration `0003_seed_batches_reports_notes` |
| `load_directory_seed` twice on a fresh SQLite DB | applied 10 opportunities + 99 resources, second run skipped; API returned all 99 (52 KB JSON) |
| `cd mobile && flutter analyze` / `flutter test` | no issues / **68/68** (new `journeys_test.dart`: welcome, Home 1192 + county, details, report payload, support grouping and county filter, details sheet) |
| `tool/screenshots/screenshots_test.dart` | 4/4 |
| `bash tool/web_build.sh` then Playwright Chromium against the build + local seeded API | welcome → home → explore search → details → report sheet; support with Mombasa, details sheet (call, copy, directions); dark mode + Kiswahili; 1280px desktop column. No page errors |
| `flutter build apk --release --target-platform android-arm64,android-arm` | built `app-release.apk` 35.6 MB, versionName 0.2.0 (code 3), permissions INTERNET only, `allowBackup=false`, API URL in `libapp.so`. Debug-signed |

Production after merging PR #13 (`88b1e19`): API preview build for the branch passed `check --deploy`; production `build.py` migrated and loaded the batch. From outside: `/api/v1/support-resources/` returns 99 records, `/api/v1/opportunities/` 10; `?county=Mombasa` returns 12 (7 Mombasa + 5 nationwide); no private fields (`verification_note`, `is_verified`, `verified_by`) in payloads; `POST /api/v1/reports/` with an unknown id → 400 `{"record_id": ["No published listing with this id."]}` and `GET` → 405 (no test report was written to production). hatua-web production `dpl_GDhXk2YevwmtDbsovmvVdbfwqgvX` built from the merge; Chromium on production: welcome → Home → Explore search → details → report sheet; Support with Mombasa → Kisauni MAT Clinic sheet (call, copy, directions); only `hatua-web.vercel.app` contacted, 3.17 MB first load, no page errors. Spot check of 8 facility phone numbers against a fresh read of NACADA's list: 8/8 match.

Data provenance: each listing's `source_url` is the page that was read on 18 Oct 2026 (NACADA's accredited-facility list for the 92 facilities; official programme pages, or a news article where no official page was reachable: Jitume, PSC portal, good-conduct how-to). Phone numbers were copied as listed; where NACADA listed several, only the first is shown. Nothing was phoned. Treat these as desk checks, not partner verification.

## Not verified

- **Release APK on a real phone.** It builds and passes manifest checks, but nobody has installed it on a device yet.
- No emulator or physical-device run, no TalkBack pass, no end-to-end test against a running Django server.
- Kiswahili strings are a **draft** written by an AI assistant. They need native-speaker review, and the SAFETY COPY keys (`supportNacadaBody`, `supportEmergencyBody`) need review by a qualified professional before any pilot.
- None of the 109 listings has been confirmed by phone or by the provider. Several NACADA entries share one phone number (they share premises); some programmes (NYOTA, PSC) open in windows, which the text says.

## What changed in this round (summary)

Backend
- `PublishedQuerySet.published()` is the single public filter: verified, active, and `last_verified_at` within `HATUA_VERIFICATION_MAX_AGE_DAYS` (default **90**, env-configurable; not a validated figure).
- Admin forms refuse `is_verified` without `source_url` and `last_verified_at`, and refuse `is_active` without `is_verified`. The reviewer is recorded in `verified_by` (staff-only, never serialised). A "Revoke now" bulk action, a publication-state column and a state filter were added.
- `county` is limited to the 47 counties plus `Nationwide`. New `?category=` and `?kind=` filters; unknown values return HTTP 400.

Mobile
- Android: release `INTERNET` permission (it was missing), backups off (`allowBackup=false` + `data_extraction_rules.xml`), cleartext allowed only in debug builds and only to emulator/localhost, label `HATUA`. Application ID is still the placeholder `com.example.hatua_app`.
- Release builds refuse a non-https `HATUA_API_URL`. The cache distinguishes network, offline copy and unavailable states; stale or corrupt caches are deleted.
- County picker, category/kind chips, readable labels, "Last checked by HATUA on …", 1192 and emergency card shown first (even offline), safe `tel:` handling, lazy tab loading, language switch, all strings in `lib/l10n/*.arb`.
- Goal encryption: first `flutter_secure_storage` 11; replaced in v0.1.1 by our own Keystore vault after the plugin failed on the owner's phone (see DECISIONS).

## Known risks and TODOs (carry forward)

1. **Choose the real application ID** (`ke.<org>.hatua`) and a release signing key before any Play upload. Release builds are still signed with the debug key (Flutter template default).
2. **Verification window (90 days)** is a placeholder. Agree it with pilot partners; it might differ for helplines and jobs.
3. **Kiswahili review**: native speaker for all strings; qualified professional for the safety copy.
4. **Emergency numbers**: the emergency card names no number on purpose. Add one only after professional verification for the pilot county.
5. **Admin hardening** before any internet exposure: MFA, separate host/VPN, audit log. A two-person review rule for support providers is still unimplemented.
6. Server-side `?county=` and `?category=` exist, but the app filters on-device over the ≤100-item list, which works offline and keeps the county choice off the network. Add pagination plus server filters before the directory grows past about 100 entries per type.
7. No privacy policy, contact or deletion process yet; no DPIA. Do not run a public beta.
8. CI not yet green on GitHub (billing lock). Once it runs, fix anything it finds and record the run URL here.
9. `ubuntu-latest` moves to Ubuntu 26 from 2026-10-19; workflows are pinned to `ubuntu-24.04`.
10. **Web app and the API throttle:** browser requests reach Django through Vercel's `/api` rewrite. Vercel does not forward external client IPs by default, so DRF's 60/min anonymous throttle may count all web users as one client (per function instance). Harmless at pilot scale (a 429 falls back to the cached copy, 1192 stays visible); before wider use, either call the API directly with CORS for `hatua-web` or make the throttle key on a header Vercel sets. Not measured yet.
11. **Web app weight:** about 3 MB on first visit and no offline start (the Flutter service worker is deprecated). The Android app remains the data-light route; say so wherever the web link is shared. The empty-state text says "Pull down to refresh", which a desktop mouse user cannot do; they have to reload the page.

## Continuation command sequence

```bash
git clone https://github.com/MadScie254/hatua && cd hatua
# Backend
cd backend && python -m venv .venv && source .venv/bin/activate
python -m pip install -r requirements-dev.txt
export DJANGO_DEBUG=1
python manage.py makemigrations --check --dry-run
python manage.py migrate && python manage.py test && python manage.py check && ruff check .
# Mobile: runner is TRACKED, do NOT run `flutter create` again
cd ../mobile
flutter pub get && flutter gen-l10n && flutter analyze && flutter test
flutter run --dart-define=HATUA_API_URL=http://10.0.2.2:8000   # emulator
# Optional: screenshots for review
flutter test tool/screenshots/screenshots_test.dart --dart-define=SHOTS_DIR=$PWD/build/screenshots
```

## Next exact actions

0. Owner: install `hatua-0.2.0.apk` and try Support → your county → call a centre; check Admin → Listing reports works from your phone. Then change the admin password, delete `DJANGO_SUPERUSER_PASSWORD` in Vercel, deploy the Cloudflare Worker (`docs/DEPLOYMENT.md` steps 3–4).
1. Owner: clear the GitHub billing lock so CI (backend, flutter, edge) runs on GitHub.
2. Owner: open https://hatua-web.vercel.app on a phone browser and report anything odd (it is the quickest way to see the app without installing the APK).
3. Run the app on a real Android phone against a local backend (`adb reverse tcp:8000 tcp:8000`, `HATUA_API_URL=http://127.0.0.1:8000`). Do a TalkBack pass and record the observations here.
4. Native-speaker review of `mobile/lib/l10n/app_sw.arb`. Remove the draft note in Settings only after review.
5. Pick the pilot county; source and verify the first real entries through Admin, following `docs/CONTENT_VERIFICATION.md`.
6. Write the threat model (`docs/THREAT_MODEL.md`) and a privacy-notice draft. Both are prerequisites for any beta.

## Important project boundaries (unchanged)

HATUA is not a diagnostic, therapy or medical device, a crisis-response service, a job-placement guarantee, or a lending product. Essential assistance stays free. Never share support-seeking with employers. Keep human oversight of referral and moderation decisions. Update this file after every PR with date, branch/commit, the commands run and their outcomes, and the next action. Never write "all tested" without command output.

## 2026-10-18 proposed feature branch: private application tracker

Branch: `feature/private-application-tracker`. Adds an Android-only application tracker in Explore and My Plan, statuses `interested`, `applied`, `interview`, `offered`, `closed`. **Only a deliberate user action adds or updates a record; simply opening an application link never changes its status.** The entries live in the same encrypted GoalVault ciphertext (v2 object envelope); older goal-only encrypted lists are read without data loss and rewritten on next private change. This retains no recovery information and adds no backend data collection, permissions or external analytics. When the vault is unsupported (Flutter web), tracking is disabled.

Resetting private goals must also delete tracked applications because the key is shared; UI copy was updated. Added unit tests for migration, persistence, duplicate prevention, encryption failure and unsupported platforms. **Validation pending: Flutter SDK unavailable to the editing session, GitHub Actions blocked by billing lock. Do not merge until `flutter gen-l10n`, `flutter analyze`, `flutter test` and an Android smoke test pass.**

### Feature queue for incoming coding assistants

- Draft PR #7: https://github.com/MadScie254/hatua/pull/7 (pending Flutter validation)
- Verified pilot UX and scam reporting: https://github.com/MadScie254/hatua/issues/8
- Goals/CV/education/financial tools: https://github.com/MadScie254/hatua/issues/9
- Recovery support and referral safeguards: https://github.com/MadScie254/hatua/issues/10
- NGO partner/billing: https://github.com/MadScie254/hatua/issues/11
- Optional AI: https://github.com/MadScie254/hatua/issues/12

No feature from this branch is on `main` until PR #7 has been tested, reviewed and merged. Existing production sites are unchanged.
