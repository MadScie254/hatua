# HATUA continuity / handoff

**Handoff timestamp:** 2026-10-18, Africa/Nairobi
**Repo origin:** Local bootstrapped Git repository, prepared for user to publish to their GitHub account `MadScie254`.
**GitHub remote:** NOT created in this session. Create `MadScie254/hatua` as a new PRIVATE empty repo; then push local `main`.
**Current status:** Source scaffold authored. Tests have NOT been executed against actual Django/Flutter dependencies in this session.

## What exists

- `mobile/` Dart source: `HatuaApp`, Material 3 theme, five tab screens.
- Public API repository with fallback to cached JSON for anonymous directory content.
- Local bookmarks stored in device preferences; goals stored in encrypted `flutter_secure_storage`.
- `backend/` Django model/admin/serializer/API for opportunities and support resources; initial migration authored.
- Read-only GET endpoints, inactive/unverified data never exposed; expired opportunities hidden.
- Django unit tests and Flutter widget tests authored but not executed in bootstrap environment.
- Documentation, safety privacy boundaries, CI stubs, Git publication guide.

## Verified vs unverified claims

| Statement | Status |
|---|---|
| Repo files exist | YES, locally generated |
| Local `git init` and initial commit | Verify final commit with `git log -1` |
| GitHub hosted repo exists | NO |
| Python syntax compiles | Check validation log (run `compileall`) |
| Django tests pass | NOT TESTED, dependency unavailable |
| Django migration matches models | NOT TESTED, run `makemigrations --check --dry-run` |
| Flutter analyzes/builds/runs | NOT TESTED, Flutter SDK unavailable |
| Real vetted support providers published | NO, initial directory is intentionally empty |
| App is live on Play Store | NO |
| User data or health records are collected by backend | NO in current architecture |

## Known technical TODOs and possible risks

1. `flutter create` platform files are not generated yet. Ensure generated package ID is a placeholder, then select owned ID before Play release. Recheck Android internet permission and emulator development cleartext network only.
2. Actual Flutter/Dart and Django analyzers may reveal API or syntax issues missed in static review; resolve rather than claiming success.
3. Verify initial Django migration with `makemigrations --check --dry-run`, adjust as necessary.
4. Current cached public items may become stale after moderator removal. Bound retention, display provenance, and filter expired opportunities on-device.
5. UI currently English. Translate properly into Kiswahili, test at large font sizes and with TalkBack.
6. Admin publication uses boolean flags; strengthen review procedure to require source link, re-verification date and recorded reviewer.
7. No production logging, monitoring, production configuration or complete privacy policy yet. Do not deploy as a public service.
8. No real service/provider data has been populated. Verify every provider before onboarding.
9. Backups of Android secure storage can create issues across device restores; review Android backup exclusions.
10. Consent architecture, age restrictions and DPIA must precede any server-side recovery/referral data.

## Continuation command sequence

```bash
# after cloning repo:
cd backend
python -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-dev.txt
export DJANGO_DEBUG=1
python manage.py migrate
python manage.py makemigrations --check --dry-run
python manage.py test
python manage.py check
ruff check .
cd ../mobile
flutter create --platforms android --project-name hatua_app .
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=HATUA_API_URL=http://10.0.2.2:8000
```

Update this file after each PR with date, branch/commit, tests run with outcomes, known regressions, unimplemented work and the next exact action. Avoid writing 'all tested' without command outputs.

## First GitHub tasks to open

- `build: generate and track Android native runner, fix Flutter analysis` (P0)
- `backend: verify migrations and CI checks` (P0)
- `privacy: document threat model and content verification process` (P0)
- `ux: complete Kiswahili localisation and accessibility checks` (P1)
- `content: verify pilot directory entries for one county` (P1)
- `research: secure NGO pilot and document evidence of demand` (P1)

## Important project boundaries

HATUA is not a diagnostic/therapy/medical device, crisis-response service, job placement guarantee, or borrowing/lending product. Essential assistance stays free. Never share sensitive support status with employers. Maintain human oversight of clinical/referral and content moderation decisions.
