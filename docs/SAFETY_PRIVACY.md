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
| Bookmarked opportunity IDs (never support resources) | Device preferences | No |
| Chosen county (manual, optional) | Device preferences | No. The app filters on the device and does not send the county |
| Chosen app language | Device preferences | No |
| Personal goal titles / completion state | Encrypted device storage (Keystore-backed) | No |
| Personal identifier, GPS location, recovery history | Not collected | No |

Requesting online public listings exposes typical network metadata such as IP address to hosting infrastructure; describe this accurately when drafting a public privacy notice.

Android backup: `allowBackup="false"`, `fullBackupContent="false"` and `data_extraction_rules.xml` exclude all app data from Google cloud backup and device-to-device transfer, so goals never leave the phone through backups (verified in the manifest, not yet on a device). The only Android permission requested is `INTERNET`; opening the dialer for 1192 or a provider needs no phone permission and places no call automatically.

Support-seeking leaves minimal trace on the device by design: support resources cannot be bookmarked, and the Support tab stores nothing. A shared or inspected phone still shows the app itself and its recent screen in the app switcher; consider `FLAG_SECURE` or a neutral app-switcher preview after user research.

## Work blocked until review

- Counsellor accounts and chat, referrals, peer community, abuse escalation workflows.
- Personal medical notes, addiction history, progress dashboards shared with providers.
- AI-generated coping guidance; any behavioural prediction affecting care or employment.
- Analytics SDKs able to link sensitive screen views to persistent device IDs.

## Incident response (pre-release procedure)

Unpublish harmful listing immediately, preserve minimal audit evidence, investigate, notify affected partners/users where warranted and legally required, implement root-cause fix, verify before republishing. Maintain a human-owned escalation contact. There is currently **no operational incident response team or SLA**: do not launch sensitive services until these exist.
