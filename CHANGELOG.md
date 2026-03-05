# Changelog

## 1.7.0

- Fixed theme switch bug: meta color-scheme is now dynamic so dark ↔ light
  transitions work correctly in WebView. Added explanation to docs.

- **Breaking change**: Removed CSS `invert(1) hue-rotate(180deg)` filter hack
  for dark mode. Newer Superset versions natively support dark/light themes via
  `urlParams.theme`. The actual Flutter theme is now passed directly to
  Superset's `embedDashboard()` call. The body CSS class is only used for
  background colour styling.

## 1.4.0

_ Added `languageCode` parameter to `SupersetBridgeConfig` and related APIs;
  and change color dark mode for superset background.

## 1.3.0

- Added `languageCode` parameter to `SupersetBridgeConfig` and related APIs;
  value is sent as the `lang` URL param. Provided convenience handling in
  HTML generator, controller, and JS bridge functions.

## 1.2.0

- Introduced `SupersetBridgeConfig` — a JSON-serialisable config object that
  replaces individual named parameters across all APIs.
- Added `extraUrlParams: Map<String, dynamic>` — any project can now pass
  custom Superset URL params (e.g. `lang`, `orgId`, feature flags) without
  changing the library.
- `SupersetBridgeHtmlContent.generate()` now accepts a single
  `SupersetBridgeConfig` argument.
- `SupersetBridgeController.initWithTokenFetch()` and `init()` now accept
  `SupersetBridgeConfig` instead of individual named parameters.
- `SupersetBridgeConfig` supports `fromJson`, `toJson`, and `copyWith`.

## 1.0.0

- Initial release of superset_bridge Flutter package.
  - HTML/JS bridge for embedding Superset dashboards.
  - Dark/light theme support with CSS filter.
  - Controller and HTML generator.
