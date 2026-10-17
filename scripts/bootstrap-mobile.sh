#!/usr/bin/env bash
# Checks the Flutter app. The Android runner is tracked in Git: do NOT run `flutter create` here.
set -euo pipefail
cd "$(dirname "$0")/../mobile"
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
printf 'Flutter checks passed. Run: flutter run --dart-define=HATUA_API_URL=http://10.0.2.2:8000\n'
