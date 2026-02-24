// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
///   ),
/// );
/// ```
class SupersetBridgeController {
  InAppWebViewController? _controller;

  /// `true` once [attach] has been called with a valid controller.
  bool get isReady => _controller != null;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Attach the underlying WebView controller.
  /// Call this inside `onWebViewCreated`.
  void attach(InAppWebViewController controller) {
    _controller = controller;
  }

  /// Detach the controller and free resources.
  void dispose() {
    _controller = null;
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Reload the WebView with entirely new [htmlContent].
  ///
  /// This is the primary way to apply a theme or language change:
  /// 1. Call [SupersetBridgeHtmlContent.generate] with the new settings.
  /// 2. Pass the result here.
  ///
  /// `loadData()` is a navigation action — it always succeeds regardless of
  /// whether the WebView is currently the foreground surface, unlike
  /// `evaluateJavascript` which may be silently dropped when the WebView
  /// is obscured.
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

  /// Embed the dashboard via the `window.SupersetBridge.initWithTokenFetch`
  /// JS function — only useful when the HTML was loaded **without** auto-init
  /// (i.e. the HTML was generated without baking in the call).
  Future<void> initWithTokenFetch({
    required String uuid,
    required String domain,
    required String theme,
    List<int>? siteIds,
    bool hideTitle = true,
    bool filtersExpanded = false,
    bool urlParamsRefresh = true,
  }) async {
    if (_controller == null) return;
    final siteIdsJs = _toJsSiteIds(siteIds);
    await _eval('''
      SupersetBridge.initWithTokenFetch(
        ${_jsString(uuid)}, ${_jsString(domain)}, ${_jsString(theme)},
        $siteIdsJs,
        ${hideTitle ? 'true' : 'false'},
        ${filtersExpanded ? 'true' : 'false'},
        ${urlParamsRefresh ? 'true' : 'false'}
      );
    ''');
  }

  /// Embed the dashboard with a **pre-fetched [token]** supplied by the caller.
  Future<void> init({
    required String uuid,
    required String domain,
    required String token,
    required String theme,
    List<int>? siteIds,
    bool hideTitle = true,
    bool filtersExpanded = false,
    bool urlParamsRefresh = true,
  }) async {
    if (_controller == null) return;
    final siteIdsJs = _toJsSiteIds(siteIds);
    await _eval('''
      SupersetBridge.init(
        ${_jsString(uuid)}, ${_jsString(domain)}, ${_jsString(token)},
        ${_jsString(theme)}, $siteIdsJs,
        ${hideTitle ? 'true' : 'false'},
        ${filtersExpanded ? 'true' : 'false'},
        ${urlParamsRefresh ? 'true' : 'false'}
      );
    ''');
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<dynamic> _eval(String source) async {
    try {
      return await _controller!.evaluateJavascript(source: source);
    } catch (e) {
      // ignore: avoid_print
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
