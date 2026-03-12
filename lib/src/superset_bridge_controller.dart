import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'superset_bridge_config.dart';
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
  Future<void> updateUI({required String theme}) async {
    if (_controller == null) return;
    await _eval("SupersetBridge.updateUI(${_jsString(theme)})");
  }

  Future<void> initWithTokenFetch(SupersetBridgeConfig config) async {
    if (_controller == null) return;
    final siteIdsJs = _toJsSiteIds(config.siteIds);
    final langJs = config.languageCode != null
        ? _jsString(config.languageCode!)
        : 'null';
    await _eval('''
      SupersetBridge.initWithTokenFetch(
        ${_jsString(config.dashboardId)}, ${_jsString(config.domain)},
        ${_jsString(config.tokenBaseURL.isNotEmpty ? config.tokenBaseURL : config.domain)},
        ${_jsString(config.theme)}, $langJs, $siteIdsJs,
        ${config.hideTitle ? 'true' : 'false'},
        ${config.filtersExpanded ? 'true' : 'false'},
        ${config.urlParamsRefresh ? 'true' : 'false'}
      );
    ''');
  }

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

  Future<dynamic> _eval(String source) async {
    try {
      return await _controller!.evaluateJavascript(source: source);
    } catch (e) {
      return null;
    }
  }

  String _jsString(String value) => "'${value.replaceAll("'", "\\'")}'";

  String _toJsSiteIds(List<int>? ids) {
    if (ids == null || ids.isEmpty) return 'null';
    return '[${ids.join(', ')}]';
  }
}
