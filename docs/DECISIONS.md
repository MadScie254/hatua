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

Next maintainer: append entries for non-trivial scope, permission, storage, identity and integration changes. Include rejected alternatives and trade-offs where important.
