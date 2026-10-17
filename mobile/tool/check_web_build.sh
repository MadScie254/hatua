#!/usr/bin/env bash
# Checks a Flutter web build for the properties HATUA relies on. Usage: check_web_build.sh build/web
set -euo pipefail
out="${1:-build/web}"
fail() { echo "check_web_build: $*" >&2; exit 1; }

[ -f "$out/index.html" ] || fail "missing index.html"
[ -f "$out/main.dart.js" ] || fail "missing main.dart.js"
grep -q '"useLocalCanvasKit":true' "$out/flutter_bootstrap.js" || fail "CanvasKit would load from Google's CDN (build with --no-web-resources-cdn)"
[ -f "$out/canvaskit/canvaskit.wasm" ] || fail "missing local CanvasKit"
grep -q '"family":"Roboto"' "$out/assets/FontManifest.json" || fail "Roboto is not bundled; the engine would fetch it from fonts.gstatic.com"
grep -q 'fontFallbackBaseUrl' "$out/flutter_bootstrap.js" || fail "fontFallbackBaseUrl is not overridden"
grep -q 'id="hatua-loading"' "$out/index.html" || fail "loading screen missing from index.html"
grep -q 'tel:1192' "$out/index.html" || fail "1192 line missing from the loading screen"
if find "$out" -name '*.map' | grep -q .; then fail "source maps present"; fi
echo "check_web_build: OK ($(du -sh "$out" | cut -f1) in $out)"
