# Definition of done / release checklist

## Build and automated checks

- [x] Backend dependency install succeeds. *(local, 2026-10-18)*
- [x] `python manage.py migrate` succeeds on new database. *(local)*
- [x] `python manage.py makemigrations --check --dry-run` shows no pending changes. *(local)*
- [x] `python manage.py test` passes. *(local, 35 tests)*
- [x] `python manage.py check --deploy` reviewed with production-like env (only W021 HSTS preload, deliberate). Re-run with the real production env.
- [x] `ruff check .` passes. *(local)*
- [ ] Android platform generated, package ID set and tracked in Git. *(generated and tracked; package ID still placeholder)*
- [x] `flutter pub get`, `flutter analyze` and `flutter test` pass. *(local, 40 tests)*
- [ ] End-to-end Android browse offline/online smoke tests pass.
- [ ] Release APK builds with HTTPS-only production API.

## Accessibility and user trust

- [ ] TalkBack navigation verified.
- [ ] Text scales correctly to at least 200%. *(widget tests pass at 200% on 360dp in en/sw; confirm on device)*
- [ ] All touch targets readable and accessible.
- [ ] English and Kiswahili content complete, reviewed by speakers.
- [ ] Helpline and provider details manually verified on launch date.
- [x] Listings with expired applications are automatically excluded offline and online.
- [ ] Reporting mechanism, removal escalation and human support channel operational.

## Privacy/security/safety

- [ ] Public privacy notice and data inventory match actual code.
- [ ] Android backups/secure storage/links/permissions audited.
- [ ] Authentication and audit on staff Admin reviewed.
- [ ] HTTPS, allowed hosts, CORS, CSRF, cookies and rate limits verified.
- [ ] Dependency scan and security review completed.
- [ ] Threat model, deletion process, incident response and ODPC compliance reviewed.
- [ ] Addiction professional confirms medical wording and appropriate referral practices.
- [ ] No clinical AI, recovery-risk scoring, coercive streaks or health-data sharing.
- [ ] Approval by responsible project owner and safeguarding lead before public launch.
