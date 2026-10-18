# Safety, privacy and safeguarding controls

HATUA concerns financial vulnerability and substance-use support. Its credibility is worth more than clever features.

## Non-negotiable principles

1. No essential support paywalls, coercive subscription prompts or referral steering based on payments.
2. No AI mental-health/medical diagnosis, withdrawal instructions, risk scoring, or implied professional relationships.
3. Clearly state that 1192 is an established substance-use counselling/referral service, NOT an emergency ambulance number. Direct severe withdrawal, overdose, seizures or breathing difficulties to immediate emergency healthcare.
4. No publication of a support facility or job without verified provenance and ongoing review. Never fabricate opening times, costs, qualifications, availability or programme outcomes.
5. Do not link users' help-seeking activity to employment profiles, targeting or advertising.
6. Essential browsing anonymous. Collect only minimum necessary data for optional actions.
7. Informed, purpose-specific, revocable consent before personal referral-sharing; clear explanation of withdrawal limits for data already lawfully processed.
8. No public recovery status, public relapse counters, automated third-party notifications or implicit caregiver access.
9. A qualified addictions professional and privacy specialist must review clinical/referral features before pilot.
10. Never promise confidentiality more broadly than the system and partner contracts can guarantee.

## Kenyan compliance checklist (NOT a substitute for legal advice)

- Determine data controller/processor roles and ODPC registration applicability.
- Perform Data Protection Impact Assessment if required, especially before processing health/addiction information.
- Establish lawful basis, special-category data condition, notices, minimisation, retention and user rights processes.
- Review cross-border transfers, hosting jurisdiction, service agreements and incident/breach handling.
- Verify partner credentials and make referral data available only to assigned/authorised professionals.
- Explicitly define age policy; prototype targets adults only. Safeguarding/legal review before offering minors access to private features.
- Consent must not be bundled with unrelated features.

## Current v0.1 privacy inventory

| Data | Location | Shared with HATUA backend? |
|---|---|---|
| Public opportunity and provider directory | API, local cache (max 24 h, then deleted) | Public content only |
| Bookmarked opportunity IDs (never support resources) | Device preferences (web: browser `localStorage`) | No |
| Chosen county (manual, optional) | Device preferences (web: browser `localStorage`) | No. The app filters on the device and does not send the county |
| Chosen app language | Device preferences (web: browser `localStorage`) | No |
| Personal goal titles / completion state | Android: ciphertext in app-private preferences; AES-256-GCM key held in the Android Keystore (`GoalVault.kt`). Web: not stored at all | No |
| Personal identifier, GPS location, recovery history | Not collected | No |

**Web app (`hatua-web`, same Flutter code in a browser).** Goals are never stored: browsers have no hardware-backed key store, and storing goals with a key the same browser profile can read would only look encrypted, so My Plan is switched off and says so. Bookmarked opportunity IDs, county, language and the 24-hour public directory copy are kept in the site's `localStorage` (cleared by "Delete my local data" or by clearing site data); anyone using the same browser profile can read them, which is acceptable only because none of them reveals support-seeking. The page loads nothing from third parties (CanvasKit, fonts and icons are served by HATUA's own Vercel project; the Flutter engine's Google-hosted fallback font URL is overridden), the CSP allows only same-origin connections, and API calls go to the web app's own origin and are proxied by Vercel to the API. Browser history on a shared computer will show that HATUA was opened (one URL, no per-tab paths); a private window avoids that. Search engines are asked not to index the pilot (`noindex`).

Requesting online public listings exposes typical network metadata such as IP address to hosting infrastructure (Vercel, including the `hatua-web` proxy for browser users, and Cloudflare once the edge cache is deployed); describe this accurately when drafting a public privacy notice.

Server-side data (pilot deployment, 2026-10-18): public directory entries and staff admin accounts only, in Neon Postgres in Frankfurt (EU), served from Vercel functions in Frankfurt. Cloudflare caches only public `/api/v1/` responses for up to 5 minutes (1 hour if the origin is down) and never sees admin traffic. Review cross-border transfer obligations under Kenya's Data Protection Act before any personal data is stored server-side.

Android backup: `allowBackup="false"`, `fullBackupContent="false"` and `data_extraction_rules.xml` exclude all app data from Google cloud backup and device-to-device transfer, so goals never leave the phone through backups (verified in the manifest, not yet on a device). The only Android permission requested is `INTERNET`; opening the dialer for 1192 or a provider needs no phone permission and places no call automatically.

**Listing reports (v0.2).** "Report a problem" sends only the listing id, a reason code and an optional note of up to 300 characters to the API. No account, IP address, device identifier or contact detail is stored with it; the note field tells people not to include their name or phone number. Reports are visible only to staff in Admin, and handled reports are deleted after 90 days. Reporting a support resource reveals to staff only that someone looked at that resource, not who. Behind the web app's `/api` rewrite and the Cloudflare edge, many users can share one client address for the 10/hour report throttle.

**Welcome screen (v0.2).** Shown once; language and county are optional and stay on the device. The "welcome done" flag is not personal and survives "Delete my local data" so the user is not thrown back to the welcome screen.

Support-seeking leaves minimal trace on the device by design: support resources cannot be bookmarked, and the Support tab stores nothing. A shared or inspected phone still shows the app itself and its recent screen in the app switcher; consider `FLAG_SECURE` or a neutral app-switcher preview after user research.

## Work blocked until review

- Counsellor accounts and chat, referrals, peer community, abuse escalation workflows.
- Personal medical notes, addiction history, progress dashboards shared with providers.
- AI-generated coping guidance; any behavioural prediction affecting care or employment.
- Analytics SDKs able to link sensitive screen views to persistent device IDs.

## Incident response (pre-release procedure)

Unpublish harmful listing immediately, preserve minimal audit evidence, investigate, notify affected partners/users where warranted and legally required, implement root-cause fix, verify before republishing. Maintain a human-owned escalation contact. There is currently **no operational incident response team or SLA**: do not launch sensitive services until these exist.
