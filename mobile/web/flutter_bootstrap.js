{{flutter_js}}
{{flutter_build_config}}

// HATUA web start-up.
// - Built with --no-web-resources-cdn, so CanvasKit and the Roboto font are served from this
//   site. fontFallbackBaseUrl points at this site too (nothing is hosted there), so a glyph
//   Roboto lacks shows as a box instead of the engine downloading Noto from fonts.gstatic.com:
//   opening HATUA makes no third-party requests (docs/SAFETY_PRIVACY.md).
// - The plain-HTML loading screen in index.html (with the 1192 line) is removed only once the
//   app is ready to draw.
_flutter.loader.load({
  config: {
    fontFallbackBaseUrl: new URL('font-fallback/', document.baseURI).href,
  },
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    const loading = document.getElementById('hatua-loading');
    if (loading) loading.remove();
    await appRunner.runApp();
  },
});
