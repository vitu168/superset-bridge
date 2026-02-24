# superset_bridge

A Flutter package that embeds Apache Superset dashboards inside a WebView with
automatic dark/light theme support. It uses a CSS filter hack to apply dark-mode
on cross-origin iframes and provides a simple Dart controller for interaction.

## Features

- Generate self-contained HTML string containing Superset embed code.
- Toggle dark/light mode without reloading the WebView.
- Optional token fetch or manual token injection.

## Usage

```dart
import 'package:superset_bridge/superset_bridge.dart';

// 1. create a controller
final bridge = SupersetBridgeController();

// 2. generate HTML
final html = SupersetBridgeHtmlContent.generate(
  dashboardId: 'your-uuid',
  domain: 'https://superset.example.com',
  theme: 'light',
);

// 3. load HTML into InAppWebView
InAppWebView(
  onWebViewCreated: (c) => bridge.attach(c),
  initialData: InAppWebViewInitialData(
    data: html,
    mimeType: 'text/html',
    encoding: 'utf-8',
  ),
);

// 4. switch theme dynamically
await bridge.updateUI(theme: 'dark');
```

For more details, see the library code and the example in the repository.
