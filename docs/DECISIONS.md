# Architectural/product decision record (ADR-lite)

| Date | Decision | Why / caveat |
|---|---|---|
| 2026-10-18 | Android first with Flutter | Kenya-first, Android reach, one team can ship mobile; iOS later |
| 2026-10-18 | Django/DRF backend | Python expertise and simple admin moderation |
| 2026-10-18 | Public content verified-only | Job scams and inaccurate treatment resources pose direct user risks |
| 2026-10-18 | Guest access to public listings and helpline | Reduce access barriers and unnecessary identity collection |
| 2026-10-18 | Addiction and opportunity pathways independent | Avoid sensitive data leakage and discriminatory matching |
| 2026-10-18 | No health profile/clinical AI in MVP | Safeguarding, clinical validation and legal questions unresolved |
| 2026-10-18 | Offline public cache, encrypted on-device goals | Minimise data cost and server-side collection of private details |
| 2026-10-18 | Admin Django only (not partner-facing) | Minimise scope; staff can vet first entries manually |
| 2026-10-18 | Partner subscriptions are future revenue, not current feature | Validate buyers first, keep essential public help free |
| 2026-10-18 | Repo bootstrapped locally rather than on GitHub | Connected GitHub tooling cannot create new repositories; remote creation requires owner action |

| 2026-10-18 | Repo created by owner as `MadScie254/hatua`; work proceeds through PRs | Session GitHub access could push but not create repos. GitHub shows it public; owner to decide visibility |
| 2026-10-18 | Track the generated Android runner; never regenerate in CI | Manifests carry deliberate edits (INTERNET in release, backups off, debug-only cleartext) that `flutter create` would not reproduce |
| 2026-10-18 | Keep placeholder application ID `com.example.hatua_app` for now | Play rejects `com.example.*`, which forces a deliberate choice of `ke.<org>.hatua` once ownership/brand is settled |
| 2026-10-18 | Disable Android backup and device transfer entirely | Goals use a device-bound key (restores would fail to decrypt) and must not leave the phone silently. Trade-off: goals are lost on phone change |
| 2026-10-18 | `flutter_secure_storage` 9 → 11 before any install exists | v9's Jetpack EncryptedSharedPreferences backend is removed upstream; upgrading later would need a two-step data migration |
| 2026-10-18 | Public = verified + active + verified within 90 days | Turns "verified" into a time-limited claim. 90 days is a placeholder to agree with partners. Rejected: no expiry (stale helplines stay up indefinitely) |
| 2026-10-18 | Record the verifying staff user; never serialise it | Accountability for moderation without exposing staff identities |
| 2026-10-18 | County is a fixed list of 47 + Nationwide in both backend and app | Free text made filters unreliable ("Nairobi City" vs "Nairobi"). Display names kept as values for readability |
| 2026-10-18 | App filters county/category on-device over the full (≤100) list | Works offline, no extra requests on cheap data plans, county choice never sent. Revisit with pagination when lists grow |
| 2026-10-18 | Unknown API filter values return 400 | Silent empty results hide client bugs |
| 2026-10-18 | Kiswahili shipped as a labelled draft behind the phone-language default | Lets the owner and testers review in place. Must be reviewed (and the safety copy professionally checked) before any pilot |
| 2026-10-18 | Emergency card names no phone number | Unverified emergency numbers are worse than none; add only after professional verification for the pilot county |
| 2026-10-18 | Release builds refuse non-https API URLs | Prevents shipping an APK that silently talks to the emulator default or plain http |

Next maintainer: append entries for non-trivial scope, permission, storage, identity and integration changes. Include rejected alternatives and trade-offs where important.
