/// Superset Bridge — Flutter package for embedding Apache Superset dashboards
/// with automatic dark/light theme support.
///
/// ## Usage
///
/// ```dart
/// import 'package:superset_bridge/superset_bridge.dart';
///
/// // 1. Create a controller
/// final controller = SupersetBridgeController();
///
/// // 2. Generate the HTML (bakes in theme, domain, dashboard ID)
/// final html = SupersetBridgeHtmlContent.generate(
///   dashboardId: 'your-uuid',
///   domain: 'https://superset.example.com',
///   theme: 'dark',   // or 'light'
///   siteIds: [1, 2], // optional
/// );
///
/// // 3. Load the HTML into your WebView and attach the controller
/// InAppWebView(
///   onWebViewCreated: (c) => controller.attach(c),
/// )
///
/// // 4. When the app theme changes, reload with the new theme:
/// await controller.reload(
///   SupersetBridgeHtmlContent.generate(
///     dashboardId: 'your-uuid',
///     domain: 'https://superset.example.com',
///     theme: 'light',
///   ),
/// );
/// ```
library superset_bridge;

export 'src/superset_bridge_controller.dart';
export 'src/superset_bridge_html_content.dart';
