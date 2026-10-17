#!/usr/bin/env bash
# Vercel "Install Command" for the hatua-web project (rootDirectory: mobile).
# Installs the pinned Flutter SDK into ./.flutter-sdk and fetches packages.
# Also works locally on Linux/macOS; skips the clone if the SDK is already there.
set -euo pipefail

FLUTTER_VERSION="3.47.7"   # keep in sync with .github/workflows/flutter.yml
SDK_DIR="${FLUTTER_SDK_DIR:-$PWD/.flutter-sdk}"

if ! command -v unzip >/dev/null 2>&1; then
  # Vercel's build image (Amazon Linux 2023) may lack unzip, which Flutter needs for the Dart SDK.
  dnf install -y unzip >/dev/null
fi

if [ ! -x "$SDK_DIR/bin/flutter" ]; then
  git clone --quiet --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$SDK_DIR"
fi

export PATH="$SDK_DIR/bin:$PATH"
export FLUTTER_SUPPRESS_ANALYTICS=true
flutter config --no-analytics --no-cli-animations >/dev/null
dart --disable-analytics >/dev/null 2>&1 || true
flutter --version
installed="$(flutter --version --machine | sed -n 's/.*"frameworkVersion": *"\([^"]*\)".*/\1/p')"
if [ "$installed" != "$FLUTTER_VERSION" ]; then
  echo "Expected Flutter $FLUTTER_VERSION in $SDK_DIR but found $installed" >&2
  exit 1
fi
flutter pub get
