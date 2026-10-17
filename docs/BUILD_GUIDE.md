# Build and publishing guide

## Backend

Install Python 3.11+ and backend requirements. Use `DJANGO_DEBUG=1` only for local development. Run `migrate`, `test`, `check`, `makemigrations --check --dry-run`. Create a staff-only superuser to review listings. No real data until verified.

`DJANGO_SECRET_KEY`, `DJANGO_ALLOWED_HOSTS` and `DATABASE_URL` are mandatory with `DJANGO_DEBUG=0`. Set a random secret, production PostgreSQL, TLS reverse proxy and hardened Admin. `backend/.env` is NOT loaded automatically. Use environment management tools and never paste tokens into an AI conversation.

## Flutter

Install Flutter **3.47.x stable** (CI pins 3.47.7) and Android Studio/SDK, then:

```bash
cd mobile
flutter pub get
flutter gen-l10n
flutter doctor -v
flutter analyze
flutter test
flutter devices
flutter run --dart-define=HATUA_API_URL=http://10.0.2.2:8000
```

### Local network troubleshooting

- Android emulator host IP: `10.0.2.2`. Local Django server: port 8000.
- Physical device: use reachable computer LAN IP and appropriate firewall rules. Do not expose debug server to the Internet.
- Physical phone over USB: `adb reverse tcp:8000 tcp:8000`, then `--dart-define=HATUA_API_URL=http://127.0.0.1:8000`. No LAN IP or firewall changes needed.
- Cleartext http is allowed **only in debug builds** and only to `10.0.2.2`, `localhost`, `127.0.0.1` (`android/app/src/debug/res/xml/network_security_config.xml`). The release manifest declares `INTERNET` and no cleartext override. The app itself also refuses non-https URLs in release builds.
- Release Android app MUST use an HTTPS base URL supplied as `--dart-define=HATUA_API_URL=https://api.yourdomain.example`.
- Select your own application ID and signing key; don't publish the placeholder `com.example.hatua_app` (Play rejects it anyway). Release builds currently fall back to the debug signing key (Flutter template); add a proper `signingConfig` before any upload.
- Backups are disabled: `allowBackup="false"`, `fullBackupContent="false"`, `res/xml/data_extraction_rules.xml` (Android 12+). Keep it that way unless a reviewed, encrypted backup design replaces it.
- Do not re-run `flutter create` over the tracked runner. If you must regenerate (e.g. a Flutter major upgrade), diff the manifests and restore the edits above.

### Screenshots without a device

```bash
flutter test tool/screenshots/screenshots_test.dart --dart-define=SHOTS_DIR=$PWD/build/screenshots
```

Renders key screens with real fonts (from the Flutter SDK cache) using fake fixtures. Useful for review; not a substitute for device and TalkBack testing.

## Run GitHub Actions

Backend CI: migrations check, migrate, system check, tests, ruff, a check that production settings refuse to start without secrets, and `check --deploy`. Flutter CI (pinned 3.47.7): lockfile enforced, gen-l10n up to date, en/sw keys match, analyze, test, then a debug APK build with manifest assertions. Workflows run on `ubuntu-24.04`. Review CI logs; don't treat a green badge as a privacy or clinical certification.

## Build APK after tests

```bash
cd mobile
flutter build apk --release --dart-define=HATUA_API_URL=https://api.yourdomain.example
```

This is a template command, not evidence that an APK has been built. Play submission also needs brand rights, app privacy policy, declarations, review/testing requirements and developer account.
