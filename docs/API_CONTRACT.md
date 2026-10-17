# API contract | v0.1 public, read-only

Base prefix `/api/v1/`. Anonymous requests allowed for public GETs; admin access remains protected by Django Admin login.

## GET /health/

```json
{"status":"ok","service":"hatua-api","version":"v1"}
```

## GET /opportunities/?county=Nairobi&q=training

Returns array of at most 100 verified, active, unexpired entries. County filters include matching county and `Nationwide`. `q` matches title, summary and organisation. Sample structural example, **not a real opportunity**:

```json
[{"id":"uuid","title":"Example only","organisation":"Example Org","summary":"Example data","category":"training","county":"Nairobi","eligibility":"","cost_label":"","application_url":"","source_url":"","deadline":null,"last_verified_at":null}]
```

## GET /support-resources/?county=Nairobi&q=counselling

Returns at most 100 verified, active entries. County includes `Nationwide`. Structural example, **not a real service**:

```json
[{"id":"uuid","name":"Example only","description":"Example data","kind":"ngo","county":"Nationwide","phone":"","website_url":"","location_label":"","source_url":"","last_verified_at":null}]
```

## POST/PUT/DELETE

Not allowed on public endpoints. Admin content changes only through authenticated Django Admin in v0.1.

## Contract notes

- Public data must never include flags used for moderation, personal notes, staff identities, private contact information or patient details.
- No pagination today (hard 100 result slice); add paginated lists and app support before large-scale growth.
- Errors: JSON with standard DRF HTTP status and response shape, subject to DRF config.
- TLS mandatory outside local development; no tokens required for anonymous catalogue.
