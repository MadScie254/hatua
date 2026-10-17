# Verification and moderation workflow

Publication status controls exist in code, but a formal human review process must be created before real data appears. **Verified** is a process, not merely a checked box.

1. Source from official programme pages, verified NGO channels, NACADA public resources or direct accredited-provider confirmation. Never fill unknown fields by guessing.
2. Record organisation, exact source URL, county, programme terms, contact, eligibility, deadline, fees/costs and time of last successful verification.
3. Confirm the opportunity/service is currently active. Mark `is_verified` only when evidence is available, and then `is_active`. Apply expiry dates; do not silently refresh expired listings.
4. Add a two-person reviewer process for recovery-provider and financial assistance listings before pilot.
5. Establish routine source rechecks, de-publication on false information, and a user-facing reporting mechanism.
6. Treat paid listings and partnerships differently from editorial verification. Never let payment affect whether risky referrals are presented as safe.
7. Store audit logs and reviewer IDs only in staff-access-controlled storage. Don't publish staff private contact details.
8. Offline cached public content is bounded to 24 hours and visibly marked stale. Recheck source links before applications or clinic journeys.

## Current state

No partner verification database, two-person approval flow, or recheck job has been implemented yet. `is_verified` and `is_active` fields provide basic gating only. **Do not preload unverified Kenyan providers** or assume official status without checking sources immediately before publication.
