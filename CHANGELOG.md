# Changelog

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
