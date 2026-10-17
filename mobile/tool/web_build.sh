#!/usr/bin/env bash
# Vercel "Build Command" for hatua-web; run tool/web_install.sh first.
# Output: build/web (static files). /api/* is proxied to the Django API by vercel.json.
set -euo pipefail

SDK_DIR="${FLUTTER_SDK_DIR:-$PWD/.flutter-sdk}"
if [ -x "$SDK_DIR/bin/flutter" ]; then export PATH="$SDK_DIR/bin:$PATH"; fi

# Committed generated l10n must match the ARB files (same rule as CI).
before="$(cat lib/l10n/*.dart | sha256sum)"
flutter gen-l10n
if [ "$before" != "$(cat lib/l10n/*.dart | sha256sum)" ]; then
  echo "Generated l10n is stale: run flutter gen-l10n and commit the result" >&2
  exit 1
fi

# --no-web-resources-cdn: CanvasKit and the Roboto font are served from our own origin, so the
#   app makes no requests to Google's CDNs (docs/SAFETY_PRIVACY.md).
# --csp: no eval in the generated JavaScript, so the Content-Security-Policy in vercel.json holds.
flutter build web --release --no-web-resources-cdn --csp --no-source-maps

bash tool/check_web_build.sh build/web
