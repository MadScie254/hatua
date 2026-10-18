# Feature matrix | HATUA

Legend: **S** = starter source implemented (still uncompiled here); **P1** = pilot priority; **P2** = later; **BLOCKED** = requires legal/clinical safeguarding review.

| User-facing screen / feature | State | Notes |
|---|---|---|
| Splash/loading | S | Basic loading; no custom splash graphics |
| Welcome carousel | P1 | Explain purpose, skip easily |
| Language choice | S | Phone default / English / Kiswahili in Settings; Kiswahili is a reviewed-pending draft |
| Guest / account choice | S | Guest only; registration absent by design |
| Registration/login | P2 | Only if user benefit and legal basis clear |
| Privacy and consent | P1 | Public policy essential; personal consent when needed |
| Interest selection | P2 | No invasive profiling |
| County selection | S | Manual picker, 47 counties, stored on device only; no GPS |
| Home | S | Quick actions to three journeys |
| Opportunity categories | S | Category chips; API `?category=` |
| Search/filter | S | On-device text, county, category/kind filters; server filters exist |
| Opportunity detail | S | Summary/card with eligibility, official links |
| Saved opportunities | S | On-device bookmark + saved filter |
| Application tracking | FEATURE BRANCH (Android) | Interested / applied / interview / offered / closed, stored only inside encrypted goal vault; web disabled; pending tests before merge |
| Support home | S | NACADA 1192 dialer shortcut |
| Emergency help | S (copy only) | Card above the directory, offline-safe; no numbers until professionally verified |
| Support directory | S | Kind chips, county filter, last-checked date; no real entries yet |
| Support provider detail | S | In-card details, external contact |
| Confidential referrals | BLOCKED | Consent architecture, provider onboarding, law |
| Wellbeing check-in | BLOCKED | Health data and clinical safeguards |
| Personal goals | S | Encrypted on-device goal checklist; v1 goal-only payloads migrate to a v2 envelope when private data is next saved |
| Goal details/subtasks | P2 | Flat goals only currently |
| Notifications | P2 | Device permission not requested currently |
| Profile/settings | S | Guest status, privacy copy, local data deletion |
| Offline public info | S | 24-hour public cache, deleted after expiry, labelled with save time; distinct "unavailable" state |
| Feedback/report listing | P1 | Moderate safely, no public accusations |
| Private journal | BLOCKED | Requires security, safety and consent review |
| Lessons/micro-learning | P2 | Reviewed sources and licences |
| CV builder | P2 | Locally authored; user owns exports |
| Financial planning | P2 | Optional, no debt collection |
| Mentorship | P2 | Human verification, moderation first |
| Community events | P2 | Partner curated |
| Partner admin portal | P2 | Internal Django Admin is NOT partner portal |
| Caseworker referral inbox | BLOCKED | Consent, role isolation, audit required |
| Moderation admin | S | Staff-only Admin; provenance rules, reviewer recorded, state filter, "Revoke now" |
| AI recommendation/assistant | P2 | No clinical/health scoring |

## Interaction acceptance cases

1. Guest launches app without asking for phone number, exact location or recovery status.
2. Opportunity list returns empty until staff verifies and activates a real listing.
3. Expired or unverified listings never appear as active opportunities.
4. Offline listing is clearly marked cached and discarded after 24 hours.
5. Support tab can open dialer for 1192 without contacting the service automatically.
6. Goals can be created, checked, removed, and deleted on demand, with no backend sync.
7. Saved listings do not accidentally reveal sensitive recovery status.
8. Any external links open only http/https URLs, not arbitrary app-specific schemes from remote payloads.
9. No cash collection, advertising, automated health advice or medical/rehab partner promises.

10. Tracking a listing must require an explicit tap; opening a source URL alone never means an application was submitted.
11. Android application records are encrypted with the private goals, never put in public directory caches, and never shared with an employer.
12. A vault failure disables tracking and goals but leaves public browsing and support resources available.
