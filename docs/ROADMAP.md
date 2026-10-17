# Roadmap and scoped backlog

**Status:** v0.1.0 scaffold only. Work in reviewed, reversible increments.

## Phase 0: Foundation (CURRENT)

- [x] Product mission, audiences, non-goals documented.
- [x] Flutter starter navigation and five core screens authored.
- [x] Django public directory models and anonymous GET endpoints authored.
- [x] Admin moderation flags; only active/verified records served.
- [x] Encrypted local goals, bookmarks and public offline caching authored.
- [x] API tests and Flutter widget tests written.
- [x] Privacy and Claude handoff documents.
- [x] Bootstrap real Flutter platform projects with Android SDK (Flutter 3.47.7, runner tracked).
- [x] Install dependencies; run and pass backend/unit/Flutter tests and analyzer (locally: 21 backend, 39 Flutter; GitHub Actions blocked by account billing lock).
- [x] Verify manually authored initial Django migration against generated state (no changes detected).
- [ ] Connect Android emulator/physical phone to local backend and run end-to-end smoke test.
- [ ] Capture actual UI screenshots and accessibility observations. (Real-font test-harness screenshots: `mobile/tool/screenshots`; device screenshots and TalkBack still to do.)
- [x] Commit generated Android runner after checking package ID and permissions.
- [x] Build a debug APK (arm64, local) and inspect its merged manifest.
- [ ] Build a release APK (CI job added; local build blocked by Maven Central rate limiting).

## Phase 1: One-county trustworthy public pilot

- [ ] Choose one county and 1-2 partner organisations after interviews.
- [ ] Confirm legal/brand rights to HATUA name; choose package ID `ke.<org>.hatua` after ownership is determined.
- [ ] Source and document official listing/provider verification for first 20 real entries.
- [x] Enforce source URL and verification date before admin publication.
- [x] Add verification expiration workflow and urgent revoke handling (90-day window, Admin "Revoke now"). Recheck reminders still missing.
- [x] County filter + category filter (backend and mobile) with proper empty states.
- [ ] Complete English + Kiswahili localisation, including emergency information. (All strings externalised; Kiswahili is a draft awaiting native-speaker and professional review.)
- [ ] Android app icons, accessibility labels, UI tests and privacy notices.
- [ ] Add secure, proportionate bug/scam reports without publishing private submissions.
- [x] Review offline cache TTL and revocation handling; do not display expired opportunities.
- [x] Confirm mobile HTTPS, safe URL handling, app-backup exclusions (in code/manifests; device check pending). Production secrets: n/a until deployment.
- [ ] Complete legal/regulatory/safeguarding assessment before public beta.
- [ ] Publish privacy policy, user contact email and deletion/support processes.
- [ ] Run private beta with meaningful consent and manual support operations.

## Phase 2: Optional partner pilot, after legal & clinical review

- [ ] Verify pilot partner and staff access procedures.
- [ ] Organisation onboarding, granular role permissions, multi-factor staff auth.
- [ ] Referral request form with consent and minimal information fields.
- [ ] Caseworker dashboard, assignment and resolution workflow.
- [ ] Separate encrypted backend health-data boundary and retention rules.
- [ ] Human crisis escalation procedures; do not promise 24/7 response without staffing.
- [ ] Detailed audit trails, export/deletion rights and DPIA where required.
- [ ] Billing and partner invoice flow only when pilot proves operational value.

## Phase 3: Empowerment additions

- [ ] Micro-learning and literacy resources reviewed by partners.
- [ ] CV writer and templates; user controls content and exports.
- [ ] Optional progress reminders and settings, user-revocable.
- [ ] Mentorship by vetted, supervised adults with moderation procedures.
- [ ] Full opportunity application tracker and verified follow-ups.

## Phase 4: AI, only if problem evidence supports it

- [ ] Semantic search over verified content, small enough to run cheaply.
- [ ] Duplicate/spam detection as a human moderation aid.
- [ ] Document extraction for user-selected application documents, with explicit consent.
- [ ] Explainable, voluntary opportunity recommendations using NON-health profile data.
- [ ] Formal fairness, privacy, hallucination and robustness evaluations.

## Avoid for now

- Clinical advice bot, algorithmic recovery scoring, prediction of relapse.
- Unmoderated anonymous health communities or coercive streaks.
- Scraping copyrighted/private data or quietly extracting WhatsApp/SMS.
- Paid job placement promises, lead resale or addiction-profile advertising.
