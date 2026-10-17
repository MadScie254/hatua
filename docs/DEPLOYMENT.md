# Deployment runbook

**Status (2026-10-18):** the API is live on Vercel with a Neon Postgres database, and the same Flutter app is live as a web app (section 6). The Cloudflare edge cache is written and tested but must be deployed once by the owner (step 4). This is a **pilot/staging** deployment: the directory is empty until staff verify real entries. It is not a public launch (see `docs/QUALITY_GATES.md`).

```text
Browser ─────https─▶ Vercel "hatua-web" (static Flutter web build) ──/api/* rewrite──▶ Vercel "hatua-api"
Android app ──https──▶ Cloudflare Worker "hatua-api" (edge cache, optional) ──▶ Vercel "hatua-api" (Django, fra1) ──▶ Neon Postgres (Frankfurt, eu-central-1)
Staff browser ─https─▶ Vercel directly (admin is never proxied or cached by Cloudflare)
```

| Piece | Where | Notes |
|---|---|---|
| Public API | `https://hatua-api.vercel.app/api/v1/` | `health/`, `opportunities/`, `support-resources/` |
| Staff admin | `https://hatua-api.vercel.app/<DJANGO_ADMIN_URL>/` | Path is in Vercel → hatua-api → Settings → Environment Variables. Deliberately **not** written in this public repo. `/admin/` returns 404. |
| Vercel project | `hatua-api` (team "madscie254's projects"), root directory `backend/`, Django preset | Git-connected: every push to `main` deploys production. |
| Database | Neon (Vercel Marketplace store `hatua-db`), free plan | Vercel injects `DATABASE_URL` (pooled) and `DATABASE_URL_UNPOOLED` (direct). |
| Web app | `https://hatua-web.vercel.app` | Vercel project `hatua-web`, root directory `mobile/`, static output; see section 6. |
| Edge cache | Cloudflare Worker `hatua-api` from `edge/` | 5-minute cache of public GETs; serves last good copy for up to 1 h if Vercel/Neon fail. |

## 1. Environment variables (Vercel → hatua-api → Settings → Environment Variables)

| Variable | Target | Purpose |
|---|---|---|
| `DATABASE_URL`, `DATABASE_URL_UNPOOLED` (+ `PG*`/`POSTGRES_*`) | Production, Preview | Added by the Neon integration. Do not edit by hand. |
| `DJANGO_SECRET_KEY` | Production (one value), Preview (another) | Signing key. Sensitive. |
| `DJANGO_DEBUG` | Production, Preview | Always `0`. |
| `DJANGO_ADMIN_URL` | Production, Preview | Admin path segment, e.g. `staff-xxxxxxxx`. |
| `DJANGO_SUPERUSER_USERNAME`, `DJANGO_SUPERUSER_PASSWORD` | Production | Create the first staff account once. **Delete the password variable after you change the password** (step 3). |
| `HATUA_VERIFICATION_MAX_AGE_DAYS` | optional | Defaults to 90. |

`ALLOWED_HOSTS` and `CSRF_TRUSTED_ORIGINS` are derived from Vercel's system variables (`VERCEL_PROJECT_PRODUCTION_URL`, `VERCEL_URL`, `VERCEL_BRANCH_URL`); "Automatically expose System Environment Variables" must stay on. For a custom domain, add `DJANGO_ALLOWED_HOSTS=api.example.org` and `DJANGO_CSRF_TRUSTED_ORIGINS=https://api.example.org`.

## 2. What a deploy does

Push or merge to `main` → Vercel builds `backend/`:

1. installs `requirements.txt` with Python 3.12 (`backend/.python-version`);
2. runs `python build.py`: `check --deploy` (fails on errors), then **production only**: `migrate` over the direct (unpooled) connection, then `ensure_superuser` (creates the account only if missing; never changes an existing one);
3. runs `collectstatic` (Vercel does this automatically) and serves `/static/` from its CDN;
4. deploys one Python function in `fra1` (Frankfurt), next to the database.

Preview deployments (pull-request branches) never migrate and are protected by Vercel Authentication. Note: the very first deployment of a project is always production, even from a branch.

Rollback: Vercel → Deployments → pick the previous production deployment → **Promote**. Database migrations are not reversed automatically; write a reverse migration if a schema change must be undone.

## 3. First login (do this once, now)

1. Open the admin URL (see table above) and sign in as `daniel` with the initial password you were given.
2. Top right → **Change password** → set your own strong password.
3. Vercel → Environment Variables → **delete `DJANGO_SUPERUSER_PASSWORD`** (it is only needed for the first build).
4. Optional hardening: rotate `DJANGO_SECRET_KEY` (generate with `python -c "import secrets; print(secrets.token_urlsafe(50))"`, update the variable, redeploy). This signs everyone out.

Then add real, verified entries following `docs/CONTENT_VERIFICATION.md`. Each one needs a source URL and a check date before it can be marked verified.

## 4. Deploy the Cloudflare edge cache (one time)

The Cloudflare connection available to the assistant cannot publish Workers, so this step is yours.

**Option A: from a phone browser (no laptop needed).** Cloudflare's Git integration builds and deploys from GitHub on every push to `main`:

1. Open https://dash.cloudflare.com → **Workers & Pages** → **Create application** → **Import a repository** (GitHub).
2. Authorise the Cloudflare GitHub app for `MadScie254/hatua` if asked, then pick that repository.
3. **Project name: `hatua-api`** (must equal `name` in `edge/wrangler.toml`, or the build fails).
4. **Advanced settings → Root directory / Path: `edge`**. Leave the build command empty; the deploy command stays `npx wrangler deploy` (it uses the wrangler version pinned in `edge/package.json`).
5. **Deploy**. When it finishes, the Worker's page shows its `https://hatua-api.<subdomain>.workers.dev` URL.

**Option B: from a computer:**

```bash
git pull
cd edge
npm ci                    # installs the pinned wrangler (4.147.0)
npm test                  # 11 tests, should all pass
npx wrangler login        # opens the browser; sign in to your Cloudflare account
npx wrangler deploy       # prints https://hatua-api.<your-subdomain>.workers.dev
```

Check it:

```bash
curl -i https://hatua-api.<your-subdomain>.workers.dev/api/v1/health/          # x-hatua-cache: BYPASS
curl -i https://hatua-api.<your-subdomain>.workers.dev/api/v1/opportunities/   # MISS, then HIT on a second call
curl -i https://hatua-api.<your-subdomain>.workers.dev/admin/                  # 404: admin is never proxied
```

Then rebuild the app against the Worker URL (step 5). Tuning lives in `edge/wrangler.toml`: `FRESH_SECONDS` (default 300) is also the longest a revoked listing can still be served by the edge; keep it short.

## 5. Build the Android app against the live API

```bash
cd mobile
flutter build apk --release --target-platform android-arm64,android-arm \
  --dart-define=HATUA_API_URL=https://hatua-api.vercel.app
# after step 4, use the Worker URL instead:
#   --dart-define=HATUA_API_URL=https://hatua-api.<your-subdomain>.workers.dev
```

Release builds already default to `https://hatua-api.vercel.app` when `HATUA_API_URL` is not given (debug builds default to the emulator's local server). Output: `mobile/build/app/outputs/flutter-apk/app-release.apk`. It is signed with the Flutter debug key and uses the placeholder ID `com.example.hatua_app`: fine for sideloading to pilot testers, **not** for Google Play (needs a real application ID, a release key, an icon and a privacy policy).

## 6. The web app (`hatua-web`)

The web app is the same Flutter code built for browsers (`mobile/web/`, `mobile/vercel.json`). It is a convenience for people without the APK; the Android app stays the main, data-light route.

What a deploy does (push or merge to `main` that touches `mobile/`; other pushes are skipped by `ignoreCommand`):

1. `tool/web_install.sh` clones Flutter **3.47.7** (same pin as CI) into `mobile/.flutter-sdk` and runs `flutter pub get` (about 1 minute; installs `unzip` with `dnf` if the build image lacks it);
2. `tool/web_build.sh` checks the committed l10n is current, runs `flutter build web --release --no-web-resources-cdn --csp --no-source-maps`, then `tool/check_web_build.sh` (local CanvasKit, bundled Roboto, overridden font fallback, 1192 line in the loading page, no source maps);
3. Vercel serves `build/web` as static files. `/api/*` is rewritten (proxied) to `https://hatua-api.vercel.app/api/*`, so the browser only ever talks to the web app's own origin: no CORS on the API, `connect-src 'self'` in the CSP.

Headers (all in `mobile/vercel.json`): strict Content-Security-Policy (`script-src 'self' 'wasm-unsafe-eval'`, no third-party origins, `frame-ancestors 'none'`), `Referrer-Policy: no-referrer`, `X-Frame-Options: DENY`, `Permissions-Policy` denying camera/microphone/location/payment, and `X-Robots-Tag: noindex` (plus a `robots` meta tag) while this is a pilot. Remove both noindex markers only at public launch.

Differences from the Android app:

- **My Plan is off.** Browsers have no hardware-backed key store, so the web build never stores goals; the tab says so and points to the Android app.
- Saved listings, county, language and the 24-hour public directory copy live in the browser's `localStorage` for that site.
- First visit downloads about **3.1 MB** (measured on production with Chromium; 8.9 MB before compression: CanvasKit ~5 MB, app ~3 MB). The browser then revalidates files with ETags, so repeat visits are small, but there is no offline start: the page itself needs a connection.
- No third-party requests: CanvasKit and Roboto are served from `hatua-web`, and the engine's Noto fallback-font URL points at `hatua-web` too (nothing is hosted there, so a character Roboto lacks shows as a box rather than triggering a download from Google).

Rollback: Vercel → hatua-web → Deployments → previous production deployment → **Promote**. Previews (other branches) are protected by Vercel Authentication; production is public.

Custom domain later: add it to `hatua-web` in Vercel. Nothing else changes, because the app calls its own origin.

## 7. Operating it

- Logs: Vercel → hatua-api → Logs (Django warnings/errors go to stdout). The web app is static; its only server-side part is the `/api` rewrite. Edge: `cd edge && npm run tail`.
- Health: `https://hatua-api.vercel.app/api/v1/health/` (no database access).
- Rate limit: anonymous requests are throttled at 60/min per client IP by Django. Requests arriving through the Worker share Cloudflare's egress addresses, which is fine at pilot scale because the edge cache absorbs most traffic. If origin traffic grows, give the Worker a secret header and exempt it from the throttle.
- Neon free plan: compute scales to zero after 5 minutes idle (first request afterwards takes ~1 s), 1 GB storage, 6-hour history window. There are no long-term backups on the free plan, so take a periodic `pg_dump` using `DATABASE_URL_UNPOOLED` (Vercel → Storage → hatua-db → connection details) once real data exists.
- Rate limit and the web app: browser requests reach Django through Vercel's rewrite, so check which client address DRF sees before raising traffic (see `docs/HANDOFF.md`, known risks).
- Plans in use: Vercel Hobby (non-commercial use only; move to Pro before any paid partner plan), Neon Free, Cloudflare Workers Free.

## 8. Data location

The server stores only public directory entries and staff accounts; no user data. The web app is static files plus a proxy and stores nothing server-side. The database is in Frankfurt (EU) and functions run in Frankfurt; Cloudflare caches public listings at edge locations. Record this in the privacy notice and review cross-border transfer requirements under Kenya's Data Protection Act before storing any personal data server-side.
