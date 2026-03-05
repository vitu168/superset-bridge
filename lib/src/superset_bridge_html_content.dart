import 'dart:convert';
import 'superset_bridge_config.dart';

/// Generates the self-contained HTML string for embedding a Superset dashboard.
///
/// ## How dark mode works
///
/// The actual theme ('dark' or 'light') is passed to Superset via
/// `urlParams.theme` in the `embedDashboard()` call. Newer Superset versions
/// natively render the correct theme inside the iframe.
///
/// A `<meta name="color-scheme" content="light">` tag is included to prevent
/// the OS `prefers-color-scheme: dark` from leaking through the WebView and
/// overriding the explicitly requested theme.
///
/// `window.SupersetBridge.updateUI(theme)` toggles the body background class.
/// For a full theme switch (re-embed with new token + theme), use
/// [SupersetBridgeController.reload] with a freshly generated HTML string.
class SupersetBridgeHtmlContent {
  SupersetBridgeHtmlContent._();
  static String generate(SupersetBridgeConfig config) {
    final baseUrlJs          = jsonEncode(config.domain);
    final dashboardIdJs      = jsonEncode(config.dashboardId);
    final themeJs            = jsonEncode(config.theme);
    final siteIdsJs          = (config.siteIds != null && config.siteIds!.isNotEmpty)
        ? jsonEncode(config.siteIds)
        : 'null';
    final hideTitleJs        = jsonEncode(config.hideTitle);
    final filtersExpandedJs  = jsonEncode(config.filtersExpanded);
    final urlParamsRefreshJs = jsonEncode(config.urlParamsRefresh);
    final extraUrlParamsJs   = config.extraUrlParams.isNotEmpty
        ? jsonEncode(config.extraUrlParams)
        : 'null';
    final languageCodeJs      = config.languageCode != null
        ? jsonEncode(config.languageCode)
        : 'null';
    final bodyClass          = config.theme == 'dark' ? 'dark' : 'light';

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0,
        maximum-scale=1.0, user-scalable=no" />
  <title>Superset</title>
  <!-- Match the color-scheme to the requested theme so that the browser
       reports the correct prefers-color-scheme to the Superset iframe. -->
  <meta name="color-scheme" content="$bodyClass" />
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

    /* ── Dark theme ────────────────────────────────────── */
    body.dark { background: #1e293b; }
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
    var _sbExtraUrlParams   = $extraUrlParamsJs;
    var _sbLanguageCode     = $languageCodeJs;
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
      // Pass actual theme to Superset — it natively supports dark/light.
      // The <meta name="color-scheme" content="light"> above prevents
      // the OS prefers-color-scheme from overriding this value.
      urlParams.theme = _sbTheme;
      if (_sbSiteIds && _sbSiteIds.length > 0) urlParams.siteId = _sbSiteIds;
      if (_sbLanguageCode && typeof _sbLanguageCode === 'string') {
        urlParams.lang = _sbLanguageCode;
      }
      // Merge project-specific extra params from SupersetBridgeConfig.extraUrlParams
      if (_sbExtraUrlParams && typeof _sbExtraUrlParams === 'object') {
        Object.assign(urlParams, _sbExtraUrlParams);
      }

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
          languageCode: _sbLanguageCode,
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
