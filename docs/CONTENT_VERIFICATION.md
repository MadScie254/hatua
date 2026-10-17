# Verification and moderation workflow

**Verified** is a process, not merely a checked box. The code now enforces parts of that process; the rest is human procedure that must exist before real data appears.

1. Source from official programme pages, verified NGO channels, NACADA public resources or direct accredited-provider confirmation. Never fill unknown fields by guessing.
2. Record organisation, exact source URL, county, programme terms, contact, eligibility, deadline, fees/costs and time of last successful verification.
3. Confirm the opportunity/service is currently active. Mark `is_verified` only when evidence is available, and then `is_active`. Apply expiry dates; do not silently refresh expired listings.
4. Add a two-person reviewer process for recovery-provider and financial assistance listings before pilot.
5. Establish routine source rechecks, de-publication on false information, and a user-facing reporting mechanism.
6. Treat paid listings and partnerships differently from editorial verification. Never let payment affect whether risky referrals are presented as safe.
7. Store audit logs and reviewer IDs only in staff-access-controlled storage. Don't publish staff private contact details.
8. Offline cached public content is bounded to 24 hours and visibly marked as a saved copy. Recheck source links before applications or clinic journeys.

## What the code enforces (since 2026-10-18)

| Rule | Where |
|---|---|
| A record cannot be saved as verified without `source_url` and `last_verified_at`; the time cannot be in the future | `PublishedRecord.clean()`, enforced by Admin forms |
| A record cannot be active unless verified | `PublishedRecord.clean()` |
| Public API shows only verified + active + verified within `HATUA_VERIFICATION_MAX_AGE_DAYS` (default 90) | `PublishedQuerySet.published()` |
| Reviewer recorded on every verification change, never exposed publicly | `verified_by`, set in `PublishedRecordAdmin.save_model` |
| Urgent removal in one step | Admin bulk action "Revoke now" (sets `is_active=False`) |
| Staff can see what is live, expired or unverified | Admin "publication state" filter and `State` column |
| County must be one of the 47 counties or Nationwide | model `choices` |
| App deletes saved public copies older than 24 h and labels offline data with its save time | `CatalogRepository` |

Note: `clean()` runs through Admin forms. Code that writes with `objects.create()` or `update()` (shell, scripts, future importers) bypasses it, so any importer must call `full_clean()`.

## Still missing (do not pilot without these)

- Two-person approval for support providers and financial assistance listings.
- An audit history of who changed what (only the last verifier is stored).
- A recheck queue that reminds staff before a verification lapses (today records simply drop out of the API).
- User-facing "report a problem with this listing" with safe handling of submissions.
- A written sourcing procedure per category, and the agreed verification window per type.

**Do not preload unverified Kenyan providers** or assume official status without checking sources immediately before publication.
