# Build and publishing guide

## Backend

Install Python 3.11+ and backend requirements. Use `DJANGO_DEBUG=1` only for local development. Run `migrate`, `test`, `check`, `makemigrations --check --dry-run`. Create a staff-only superuser to review listings. No real data until verified.

`DJANGO_SECRET_KEY`, `DJANGO_ALLOWED_HOSTS` and `DATABASE_URL` are mandatory with `DJANGO_DEBUG=0`. Set a random secret, production PostgreSQL, TLS reverse proxy and hardened Admin. `backend/.env` is NOT loaded automatically. Use environment management tools and never paste tokens into an AI conversation.

## Flutter

Install a current Flutter stable SDK and Android Studio/SDK, then:

```bash
cd mobile
flutter create --platforms android --project-name hatua_app .
flutter pub get
flutter doctor -v
flutter analyze
flutter test
flutter devices
flutter run --dart-define=HATUA_API_URL=http://10.0.2.2:8000
```

### Local network troubleshooting

- Android emulator host IP: `10.0.2.2`. Local Django server: port 8000.
- Physical device: use reachable computer LAN IP and appropriate firewall rules. Do not expose debug server to the Internet.
- On Android, local HTTP development may require allowing cleartext traffic **only in debug manifest** and `INTERNET` permission in main manifest; check generated files. Prefer local HTTPS tunnel with a trusted development cert if possible.
- Release Android app MUST use an HTTPS base URL supplied as `--dart-define=HATUA_API_URL=https://api.yourdomain.example`.
- Select your own application ID and signing key; don't publish the auto-generated placeholder package ID.
- Flutter production AndroidManifest should not blindly back up app data; review secure storage backup rules and Android 12+ data extraction rules.

## Run GitHub Actions

Once pushed, backend CI runs Python tests and lint. Flutter CI installs stable Flutter, bootstraps Android files if absent, runs analyzer/tests. Review CI logs, don't treat a green badge as a privacy or clinical certification.

## Build APK after tests

```bash
cd mobile
flutter build apk --release --dart-define=HATUA_API_URL=https://api.yourdomain.example
```

This is a template command, not evidence that an APK has been built. Play submission also needs brand rights, app privacy policy, declarations, review/testing requirements and developer account.
