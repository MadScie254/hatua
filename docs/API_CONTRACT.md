# API contract | v0.1 public, read-only

Base URL (pilot): `https://hatua-api.vercel.app/api/v1/`, or the Cloudflare edge `https://hatua-api.<subdomain>.workers.dev/api/v1/` once deployed (same paths and payloads, plus an `x-hatua-cache: HIT|MISS|STALE|BYPASS` header and up to 5 minutes of caching). `GET /` returns a short description of the API.

Base prefix `/api/v1/`. Anonymous requests allowed for public GETs; admin access remains protected by Django Admin login. Responses are JSON only. Anonymous requests are throttled (`60/min`).

## What "public" means

A record appears only if **all** of these hold (`PublishedQuerySet.published()` in `backend/directory/models.py`):

- `is_verified = true` and `is_active = true`
- `last_verified_at` is set, not in the future, and newer than `HATUA_VERIFICATION_MAX_AGE_DAYS` (default 90). Records whose verification lapses disappear until staff re-check them.
- Opportunities only: `deadline` is null or today/later (server local date, Africa/Nairobi).

## GET /health/

```json
{"status":"ok","service":"hatua-api","version":"v1"}
```

## GET /opportunities/?county=Nairobi&category=training&q=welding

Returns an array of at most 100 public opportunities, newest first.

| Param | Meaning |
|---|---|
| `county` | One of the 47 county names (e.g. `Nairobi`, `Homa Bay`, `Murang'a`). Matches that county **and** `Nationwide`. Case-insensitive. |
| `category` | `job`, `training`, `grant`, `apprenticeship` or `other`. Any other value → **400** `{"category": "Must be one of: job, training, grant, apprenticeship, other."}`. |
| `q` | Case-insensitive substring of title, summary or organisation (first 100 chars used). |

Structural example, **not a real opportunity**:

```json
[{"id":"uuid","title":"Example only","organisation":"Example Org","summary":"Example data","category":"training","county":"Nairobi","eligibility":"","cost_label":"","application_url":"","source_url":"https://example.invalid/source","deadline":null,"last_verified_at":"2026-10-01T08:00:00Z"}]
```

## GET /support-resources/?county=Nairobi&kind=helpline&q=counselling

Returns at most 100 public resources, ordered by name. `county` and `q` (name, description) behave as above; `kind` is `helpline`, `facility`, `ngo` or `education`, and any other value returns **400**.

Structural example, **not a real service**:

```json
[{"id":"uuid","name":"Example only","description":"Example data","kind":"ngo","county":"Nationwide","phone":"","website_url":"","location_label":"","source_url":"https://example.invalid/source","last_verified_at":"2026-10-01T08:00:00Z"}]
```

## POST/PUT/PATCH/DELETE

405 on public endpoints. Content changes happen only through authenticated Django Admin.

## Contract notes

- Public payloads never include moderation flags (`is_verified`, `is_active`), the reviewer (`verified_by`), timestamps other than `last_verified_at`, personal notes, staff identities or patient details. A test enforces this.
- `county` values are the display names in `backend/directory/counties.py`; the mobile list in `mobile/lib/src/data/counties.dart` must match.
- No pagination today (hard 100-item slice). The app currently fetches the full list and filters on the device (works offline, keeps the county choice off the network). Add pagination and use server filters before any type passes about 100 public entries.
- `phone` is free text from staff; clients must sanitise it before dialling (the app keeps digits and a leading `+` only).
- TLS mandatory outside local development; release app builds refuse non-https API URLs.
