# HATUA | One step forward, every day

**Status: v0.2.0 pilot. NOT a finished, released, or clinically validated app.**

**Live API (staging/pilot):** https://hatua-api.vercel.app/api/v1/health/ (Vercel + Neon Postgres; 10 opportunities and 99 support services, real and sourced, desk-checked 18 Oct 2026). **Web app (same Flutter code):** https://hatua-web.vercel.app (My Plan is Android-only). Deployment and operations: [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md).

Kenya-first Android project connecting people to **verified economic opportunities** and **reliable addiction support resources**, plus private, on-device goals. Job discovery and recovery support remain separate and optional. The public app is free; future partner subscriptions can fund operations without charging for essential assistance.

## What's here today

- Flutter Android-first app (runner tracked): Home, Explore, Support, My Plan, Settings, with county/category filters, offline and error states, and English plus **draft** Kiswahili.
- Guest browsing; no signup, no collected health history, no AI counsellor. Only Android permission: `INTERNET`. Backups disabled.
- Public Django REST API: opportunities, support resources, health check, with county/category/kind filters.
- Only **verified, active and recently re-verified** records are published (90-day window by default); expired opportunities excluded.
- Django Admin for staff (internal only): provenance required before verification, reviewer recorded, "Revoke now".
- Offline fallback for **public** listings (24 h, then deleted); encrypted local goal storage.
- The same app as a web build on Vercel (`hatua-web`): self-hosted assets, strict CSP, `/api` proxied to the API, no goals stored in browsers.
- Real listings: NACADA-accredited treatment centres in 31 counties, helplines (Befrienders, Childline 116, one2one 1190), AA Kenya, SAPTA, and training/work programmes (Generation Kenya, ALX, NYOTA, Jitume, KNQA RPL, PSC portal). Each links to the official source it was checked against.
- Anonymous "report a problem" on every listing, with a staff moderation queue.
- Private application tracker on Android (Interested → Applied → Interview → Offer → Closed), encrypted with the goals.
- Tests (47 backend, 68 Flutter, 11 edge Worker, all passing locally), CI workflows, product/privacy/architecture docs.
- Claude handoff: [`CLAUDE.md`](CLAUDE.md), [`docs/HANDOFF.md`](docs/HANDOFF.md).

### What's deliberately NOT built

A partner- or phone-verified provider catalogue (current listings are desk-checked against official pages), user accounts, applications, referrals, partner billing, **reviewed** Kiswahili, live notification system, AI matching, clinical tools, iOS app, production infrastructure, a release-signed APK. Do not advertise these as implemented.

## Repository layout

```text
backend/       Django API + staff-managed directory + tests (deployed to Vercel)
edge/          Cloudflare Worker: edge cache in front of the public API
mobile/        Flutter app incl. tracked Android runner, l10n ARB files, tests, screenshot tool
docs/          requirements, architecture, privacy, decisions, business, roadmap, handoff
.github/       CI definitions
scripts/       developer bootstrap scripts
CLAUDE.md      instructions for Claude / other coding assistants
```

## Quick start

### 1. Backend (Python 3.11+, virtualenv)

```bash
cd backend
python -m venv .venv
# Linux/macOS: source .venv/bin/activate
# Windows PowerShell: .venv\\Scripts\\Activate.ps1
python -m pip install -r requirements-dev.txt
export DJANGO_DEBUG=1                        # Windows PowerShell: $env:DJANGO_DEBUG="1"
python manage.py migrate
python manage.py createsuperuser              # local-only staff admin account
python manage.py runserver 0.0.0.0:8000
```

For local production-like PostgreSQL development use `DATABASE_URL`. Environment examples: [`.env.example`](.env.example). The backend **does not automatically read .env files**: use shell exports, an env loader, or your process manager. NEVER commit real secrets.

Quick checks:

```bash
curl http://127.0.0.1:8000/api/v1/health/
curl http://127.0.0.1:8000/api/v1/opportunities/
curl http://127.0.0.1:8000/api/v1/support-resources/
```

Both directory lists start EMPTY by design. Admin records must be reviewed and explicitly set `is_verified=True`, `is_active=True` before appearing.

### 2. Flutter Android (Flutter stable SDK + Android Studio)

```bash
cd mobile
flutter pub get
flutter run --dart-define=HATUA_API_URL=http://10.0.2.2:8000
```

The Android runner is already in the repo; **do not run `flutter create`** over it. `10.0.2.2` reaches the host machine from the standard Android emulator. On a USB-connected phone, run `adb reverse tcp:8000 tcp:8000` and use `HATUA_API_URL=http://127.0.0.1:8000`. Debug builds allow plain http only to those local hosts. Release builds refuse any non-https API URL. See [`docs/BUILD_GUIDE.md`](docs/BUILD_GUIDE.md).

### 3. Checks

```bash
cd backend
python manage.py test
python manage.py makemigrations --check --dry-run
python manage.py check
ruff check .

cd ../mobile
flutter gen-l10n          # regenerate after editing lib/l10n/*.arb, commit the output
flutter analyze
flutter test
```

Latest local results and anything not yet verified: [`docs/HANDOFF.md`](docs/HANDOFF.md).

## Safety and trust

HATUA is **information/referral software, not medical care**. It cannot diagnose addiction, manage withdrawal, guarantee employment, or promise provider availability. Seek immediate medical assistance for overdose, severe withdrawal, difficulty breathing, seizures, or other emergencies. NACADA support: **1192**, distinct from emergency medical response. See [`docs/SAFETY_PRIVACY.md`](docs/SAFETY_PRIVACY.md).

No sensitive recovery profile or casework feature is enabled in this starter. A professional safeguarding review and Kenyan data protection review are prerequisites before adding them.

## How to continue with Claude

1. Give Claude the repository or GitHub link and tell it to read [`CLAUDE.md`](CLAUDE.md) first.
2. Have it run the setup and tests above and report what actually passes.
3. Continue in small reviewed PRs following [`docs/ROADMAP.md`](docs/ROADMAP.md).
4. Record decisions and verification results in [`docs/HANDOFF.md`](docs/HANDOFF.md).

## Commercial direction

Free for individuals; paid plans for verified NGO/community partners **only after pilot validation**. Hypothetical pricing and buyer interviews live in [`docs/BUSINESS_MODEL.md`](docs/BUSINESS_MODEL.md).

## License

No open-source license selected yet. All rights reserved by the repository owner until a license is explicitly chosen. Keep this repository private while privacy, branding and licensing decisions are being finalised.
