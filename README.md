# superset_bridge

A Flutter package that embeds Apache Superset dashboards inside a WebView with
automatic dark/light theme support and a flexible configuration API. It uses a
CSS filter hack to apply dark mode on cross-origin iframes and exposes a Dart
controller for easy integration.

The package is published on [pub.dev](https://pub.dev/packages/superset_bridge)
and can be added to any Flutter project that uses a WebView (currently
`flutter_inappwebview`).

## Features

- Generate self-contained HTML string containing Superset embed code using a
  JSON-serialisable configuration object.
- Toggle dark/light mode without reloading the WebView.
- Optional token fetch or manual token injection.
- Specify a top‑level `languageCode` that will be sent as the
  `lang` URL parameter (in addition to or instead of using
  `extraUrlParams`).
- Pass arbitrary extra URL parameters (via `SupersetBridgeConfig.extraUrlParams`)
  so each project can customise the embed request without modifying the package.

## Getting started

1. **Add dependency**

```yaml
dependencies:
  superset_bridge: ^1.3.0
```

2. **Import the package**

```dart
import 'package:superset_bridge/superset_bridge.dart';
```

3. **Create a controller and generate HTML**

```dart
final bridge = SupersetBridgeController();

final config = SupersetBridgeConfig(
  dashboardId: 'your-dashboard-uuid',
  domain: 'https://superset.example.com',
  theme: 'light',
  languageCode: 'en',         // optional first‑class language parameter
  siteIds: [1, 2],           // optional
  extraUrlParams: {
    'orgId': 42,
  },
);

final html = SupersetBridgeHtmlContent.generate(config);
```

4. **Load the HTML into a WebView** (using `flutter_inappwebview`):

```dart
InAppWebView(
  initialData: InAppWebViewInitialData(
    data: html,
    mimeType: 'text/html',
    encoding: 'utf-8',
  ),
  onWebViewCreated: (controller) {
    bridge.attach(controller);
  },
);
```

5. **Update theme or config dynamically**

```dart
// simple theme switch without a full reload:
await bridge.updateUI(theme: 'dark');

// regenerate HTML with new config (e.g. new dashboardId or language):
final newHtml = SupersetBridgeHtmlContent.generate(
  config.copyWith(theme: 'dark', languageCode: 'fr'),
);
await bridge.reload(newHtml);
```

6. **Advanced embedding**

If you already have a guest token from your backend, use the `init` methods:

```dart
await bridge.init(
  config,
  token: 'pre_fetched_token',
);
```

or

```dart
await bridge.initWithTokenFetch(config);
```

Both methods accept a `SupersetBridgeConfig` object.

## Migration from inline code

Previously you might have manually copied the HTML generator and controller
into your project; those files are still present in this repo for reference but
are *not required* anymore. Simply depend on the package and update your code to
use the exported `SupersetBridgeConfig`, `SupersetBridgeHtmlContent`, and
`SupersetBridgeController` classes.

## Publishing to pub.dev

1. **Ensure version and changelog are updated** in `pubspec.yaml` and
   `CHANGELOG.md`.
2. **Run `dart pub publish --dry-run`** to validate the package; fix any issues.
3. **Run `dart pub publish`** and sign in with your Google (pub.dev) account.
4. After successful upload, bump the version in `pubspec.yaml` and commit the
   changes.

Once published you can install the package in any Flutter app by adding the
version constraint as shown above.

## License

The package is released under the [MIT license](LICENSE).

For full examples, see the `example/` directory in the GitHub repository.
