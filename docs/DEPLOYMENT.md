# Deployment runbook

**Status (2026-10-18):** the API is live on Vercel with a Neon Postgres database. The Cloudflare edge cache is written and tested but must be deployed once by the owner (step 4). This is a **pilot/staging** deployment: the directory is empty until staff verify real entries. It is not a public launch (see `docs/QUALITY_GATES.md`).

```text
Android app ──https──▶ Cloudflare Worker "hatua-api" (edge cache, optional) ──▶ Vercel "hatua-api" (Django, fra1) ──▶ Neon Postgres (Frankfurt, eu-central-1)
Staff browser ─https─▶ Vercel directly (admin is never proxied or cached by Cloudflare)
```

| Piece | Where | Notes |
|---|---|---|
| Public API | `https://hatua-api.vercel.app/api/v1/` | `health/`, `opportunities/`, `support-resources/` |
| Staff admin | `https://hatua-api.vercel.app/<DJANGO_ADMIN_URL>/` | Path is in Vercel → hatua-api → Settings → Environment Variables. Deliberately **not** written in this public repo. `/admin/` returns 404. |
| Vercel project | `hatua-api` (team "madscie254's projects"), root directory `backend/`, Django preset | Git-connected: every push to `main` deploys production. |
| Database | Neon (Vercel Marketplace store `hatua-db`), free plan | Vercel injects `DATABASE_URL` (pooled) and `DATABASE_URL_UNPOOLED` (direct). |
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

## 4. Deploy the Cloudflare edge cache (one time, from your computer)

The Cloudflare connection available to the assistant cannot publish Workers, so this step is yours:

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

## 6. Operating it

- Logs: Vercel → hatua-api → Logs (Django warnings/errors go to stdout). Edge: `cd edge && npm run tail`.
- Health: `https://hatua-api.vercel.app/api/v1/health/` (no database access).
- Rate limit: anonymous requests are throttled at 60/min per client IP by Django. Requests arriving through the Worker share Cloudflare's egress addresses, which is fine at pilot scale because the edge cache absorbs most traffic. If origin traffic grows, give the Worker a secret header and exempt it from the throttle.
- Neon free plan: compute scales to zero after 5 minutes idle (first request afterwards takes ~1 s), 1 GB storage, 6-hour history window. There are no long-term backups on the free plan, so take a periodic `pg_dump` using `DATABASE_URL_UNPOOLED` (Vercel → Storage → hatua-db → connection details) once real data exists.
- Plans in use: Vercel Hobby (non-commercial use only; move to Pro before any paid partner plan), Neon Free, Cloudflare Workers Free.

## 7. Data location

The server stores only public directory entries and staff accounts; no user data. The database is in Frankfurt (EU) and functions run in Frankfurt; Cloudflare caches public listings at edge locations. Record this in the privacy notice and review cross-border transfer requirements under Kenya's Data Protection Act before storing any personal data server-side.
