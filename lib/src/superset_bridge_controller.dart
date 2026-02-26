// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'superset_bridge_config.dart';

/// Controller for the Superset Bridge Library.
///
/// Wraps [InAppWebViewController] to expose high-level methods for
/// loading and dynamically reloading the embedded Superset dashboard.
///
/// ## Typical usage
///
/// ```dart
/// final bridge = SupersetBridgeController();
///
/// // Inside onWebViewCreated:
/// bridge.attach(controller);
///
/// // On theme / language change — regenerate HTML and reload:
/// await bridge.reload(
///   SupersetBridgeHtmlContent.generate(
///     dashboardId: 'uuid',
///     domain: 'https://superset.example.com',
///     theme: 'dark',
///     languageCode: 'fr',          // pass new language
///   ),
/// );
/// ```
class SupersetBridgeController {
  InAppWebViewController? _controller;
  bool get isReady => _controller != null;
  void attach(InAppWebViewController controller) {
    _controller = controller;
  }
  void dispose() {
    _controller = null;
  }
  Future<void> reload(String htmlContent) async {
    if (_controller == null) return;
    await _controller!.loadData(data: htmlContent);
  }

  /// Dynamically switch theme via JS without a full reload.
  ///
  /// Toggles the `dark` / `light` body class in the parent HTML — the CSS
  /// filter on `#superset-mount` then applies or removes instantly.
  ///
  /// Prefer [reload] when changing both theme and language at the same time,
  /// or if the WebView may be obscured at the moment of the call.
  Future<void> updateUI({required String theme}) async {
    if (_controller == null) return;
    await _eval("SupersetBridge.updateUI(${_jsString(theme)})");
  }

  // ── Optional advanced entry-points ───────────────────────────────────────

  /// Embed the dashboard via `window.SupersetBridge.initWithTokenFetch`.
  /// All embed parameters are taken from [config].
  Future<void> initWithTokenFetch(SupersetBridgeConfig config) async {
    if (_controller == null) return;
    final siteIdsJs = _toJsSiteIds(config.siteIds);
    final langJs = config.languageCode != null
        ? _jsString(config.languageCode!)
        : 'null';
    await _eval('''
      SupersetBridge.initWithTokenFetch(
        ${_jsString(config.dashboardId)}, ${_jsString(config.domain)},
        ${_jsString(config.theme)}, $langJs, $siteIdsJs,
        ${config.hideTitle ? 'true' : 'false'},
        ${config.filtersExpanded ? 'true' : 'false'},
        ${config.urlParamsRefresh ? 'true' : 'false'}
      );
    ''');
  }

  /// Embed the dashboard with a **pre-fetched [token]** supplied by the caller.
  /// All other embed parameters are taken from [config].
  Future<void> init(SupersetBridgeConfig config, {required String token}) async {
    if (_controller == null) return;
    final siteIdsJs = _toJsSiteIds(config.siteIds);
    final langJs = config.languageCode != null
        ? _jsString(config.languageCode!)
        : 'null';
    await _eval('''
      SupersetBridge.init(
        ${_jsString(config.dashboardId)}, ${_jsString(config.domain)},
        ${_jsString(token)}, ${_jsString(config.theme)}, $langJs, $siteIdsJs,
        ${config.hideTitle ? 'true' : 'false'},
        ${config.filtersExpanded ? 'true' : 'false'},
        ${config.urlParamsRefresh ? 'true' : 'false'}
      );
    ''');
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<dynamic> _eval(String source) async {
    try {
      return await _controller!.evaluateJavascript(source: source);
    } catch (e) {
      print('[SupersetBridgeController] JS eval error: $e');
      return null;
    }
  }

  String _jsString(String value) => "'${value.replaceAll("'", "\\'")}'";

  String _toJsSiteIds(List<int>? ids) {
    if (ids == null || ids.isEmpty) return 'null';
    return '[${ids.join(', ')}]';
  }
}
