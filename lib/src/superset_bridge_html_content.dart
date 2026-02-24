import 'dart:convert';

/// Generates the self-contained HTML string for embedding a Superset dashboard.
///
/// ## How dark mode works
///
/// Superset loads inside a cross-origin `<iframe>`.  The browser **blocks**:
/// - `iframe.contentDocument` access (SecurityError)
/// - CSS injection into the iframe's document
/// - `embedDashboard().setThemeConfig()` — that method does not exist in any
///   released version of `@superset-ui/embedded-sdk`
///
/// The solution is a CSS visual filter applied to `#superset-mount` in the
/// **parent** document (which we fully control):
///
/// ```css
/// body.dark #superset-mount { filter: invert(1) hue-rotate(180deg); }
/// ```
///
/// - `invert(1)` flips pixel brightness (white ↔ black).
/// - `hue-rotate(180deg)` spins hues so chart colours land roughly back where
///   they started after the inversion.
///
/// `window.SupersetBridge.updateUI(theme)` toggles the body class instantly.
/// For a full reload (theme + language + fresh token), use
/// [SupersetBridgeController.reload] with a freshly generated HTML string.
class SupersetBridgeHtmlContent {
  SupersetBridgeHtmlContent._();
  static String generate({
    required String dashboardId,
    required String domain,
    String theme = 'light',
    List<int>? siteIds,
    bool hideTitle = true,
    bool filtersExpanded = false,
    bool urlParamsRefresh = true,
  }) {
    final baseUrlJs          = jsonEncode(domain);
    final dashboardIdJs      = jsonEncode(dashboardId);
    final themeJs            = jsonEncode(theme);
    final siteIdsJs          = (siteIds != null && siteIds.isNotEmpty)
        ? jsonEncode(siteIds)
        : 'null';
    final hideTitleJs        = jsonEncode(hideTitle);
    final filtersExpandedJs  = jsonEncode(filtersExpanded);
    final urlParamsRefreshJs = jsonEncode(urlParamsRefresh);
    final bodyClass          = theme == 'dark' ? 'dark' : 'light';

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0,
        maximum-scale=1.0, user-scalable=no" />
  <title>Superset</title>
  <script src="https://unpkg.com/@superset-ui/embedded-sdk"></script>
  <style>
    /* ── Base layout ───────────────────────────────────── */
    *, *::before, *::after { box-sizing: border-box; }
    html, body {
      margin: 0; padding: 0;
      width: 100%; height: 100%;
      overflow: hidden;
      transition: background 0.25s;
    }
    #superset-mount {
      width: 100%; height: 100%;
      transition: filter 0.25s;
    }
    #superset-mount iframe {
      width: 100%; height: 100%;
      border: none; display: block;
    }

    /* ── Light theme ───────────────────────────────────── */
    body.light { background: #f8fafc; }
    body.light #superset-mount { filter: none; }

    /* ── Dark theme ────────────────────────────────────── */
    /* Filter applied to mount div in PARENT doc — not cross-origin. */
    body.dark { background: #1e293b; }
    body.dark #superset-mount { filter: invert(1) hue-rotate(180deg); }
    /* Re-invert images so they are not colour-flipped. */
    body.dark #superset-mount img { filter: invert(1) hue-rotate(180deg); }
  </style>
</head>
<body class="$bodyClass">
  <div id="superset-mount"></div>
  <script>
    var _sbDomain           = $baseUrlJs;
    var _sbUUID             = $dashboardIdJs;
    var _sbTheme            = $themeJs;
    var _sbSiteIds          = $siteIdsJs;
    var _sbHideTitle        = $hideTitleJs;
    var _sbFiltersExpanded  = $filtersExpandedJs;
    var _sbUrlParamsRefresh = $urlParamsRefreshJs;
    var _sbDashboard        = null;

    async function _sbGetToken() {
      var resp = await fetch(_sbDomain + '/guest-token?dashboard_id=' + _sbUUID);
      if (!resp.ok) throw new Error('Token fetch HTTP ' + resp.status);
      var data = await resp.json();
      return data.token;
    }

    async function _sbEmbed() {
      var token = await _sbGetToken();
      var urlParams = {};
      if (_sbUrlParamsRefresh) urlParams.refresh = true;
      urlParams.theme = _sbTheme;
      if (_sbSiteIds && _sbSiteIds.length > 0) urlParams.siteId = _sbSiteIds;

      _sbDashboard = await supersetEmbeddedSdk.embedDashboard({
        id: _sbUUID,
        supersetDomain: _sbDomain,
        mountPoint: document.getElementById('superset-mount'),
        fetchGuestToken: function() { return Promise.resolve(token); },
        dashboardUiConfig: {
          hideTitle: _sbHideTitle,
          standalone: true,
          filters: { expanded: _sbFiltersExpanded },
          urlParams: urlParams,
        },
        iframeSandboxExtras: ['allow-top-navigation', 'allow-popups-to-escape-sandbox'],
      });

      _sbSetBodyTheme(_sbTheme);
      console.log('[SupersetBridge] Dashboard ready, theme:', _sbTheme);
    }

    function _sbSetBodyTheme(theme) {
      var isDark = theme === 'dark';
      document.body.classList.toggle('dark', isDark);
      document.body.classList.toggle('light', !isDark);
      _sbTheme = theme;
      console.log('[SupersetBridge] Theme \u2192 ' + theme);
    }

    // Public API callable from Flutter via evaluateJavascript
    window.SupersetBridge = {
      updateUI: function(theme) { _sbSetBodyTheme(theme); }
    };

    _sbEmbed();
  </script>
</body>
</html>''';
  }
}
