#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../mobile"
flutter create --platforms android --project-name hatua_app .
flutter pub get
flutter analyze
flutter test
printf 'Android Flutter project initialized; review and commit native Android files.\n'
