import 'dart:convert';

/// Configuration object for embedding a Superset dashboard.
///
/// Can be built directly, copied with [copyWith], or deserialised from a
/// JSON map coming from a remote config endpoint or local settings:
///
/// ```dart
/// // Directly
/// final config = SupersetBridgeConfig(
///   dashboardId: 'my-uuid',
///   domain: 'https://superset.example.com',
///   theme: 'dark',
///   languageCode: 'km',          // new first‑class field
///   extraUrlParams: {'env': 'prod'},
/// );
///
/// // From JSON (e.g. remote config)
/// final config = SupersetBridgeConfig.fromJson(remoteMap);
///
/// // Override one field for a theme change
/// final dark = config.copyWith(theme: 'dark');
/// ```
///
/// All fields have defaults so a partial JSON map is valid.
/// Any project-specific URL parameters that Superset should receive
/// (beyond the fixed ones) go in [extraUrlParams].
class SupersetBridgeConfig {
  const SupersetBridgeConfig({
    required this.dashboardId,
    required this.domain,
    this.theme = 'light',
    this.languageCode,
    this.siteIds,
    this.hideTitle = true,
    this.filtersExpanded = false,
    this.urlParamsRefresh = true,
    this.extraUrlParams = const {},
  });

  /// Superset Dashboard UUID.
  final String dashboardId;

  /// Superset base URL — no trailing slash.
  final String domain;

  /// `'dark'` or `'light'`.  Defaults to `'light'`.
  final String theme;

  /// Optional language code that will be added to the Superset URL params as
  /// `lang`.  Examples: `'en'`, `'fr'`, `'km'`.
  ///
  /// This is separate from [extraUrlParams] so language can be treated as a
  /// first-class property in the configuration object.
  final String? languageCode;

  /// Optional list of site IDs passed as `urlParams.siteId`.
  final List<int>? siteIds;

  /// Hide the Superset dashboard title bar.  Defaults to `true`.
  final bool hideTitle;

  /// Start with the filter panel expanded.  Defaults to `false`.
  final bool filtersExpanded;

  /// Pass `refresh=true` in the embed URL params.  Defaults to `true`.
  final bool urlParamsRefresh;

  /// **Project-specific** key/value pairs injected into the Superset
  /// embed `urlParams` object at runtime.  Values must be JSON-encodable.
  ///
  /// Examples:
  /// ```dart
  /// extraUrlParams: {'lang': 'km', 'orgId': 5, 'flags': ['a', 'b']}
  /// ```
  final Map<String, dynamic> extraUrlParams;

  // ── Factory constructors ──────────────────────────────────────────────────

  /// Build from a plain `Map<String, dynamic>` — unknown keys are silently
  /// ignored, all fields fall back to their defaults.
  factory SupersetBridgeConfig.fromJson(Map<String, dynamic> json) {
    return SupersetBridgeConfig(
      dashboardId: json['dashboardId'] as String? ?? '',
      domain: json['domain'] as String? ?? '',
      theme: json['theme'] as String? ?? 'light',
      languageCode: json['languageCode'] as String?,
      siteIds: (json['siteIds'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      hideTitle: json['hideTitle'] as bool? ?? true,
      filtersExpanded: json['filtersExpanded'] as bool? ?? false,
      urlParamsRefresh: json['urlParamsRefresh'] as bool? ?? true,
      extraUrlParams:
          (json['extraUrlParams'] as Map<String, dynamic>?) ?? const {},
    );
  }

  // ── Serialisation ─────────────────────────────────────────────────────────

  /// Serialise to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'dashboardId': dashboardId,
        'domain': domain,
        'theme': theme,
        if (languageCode != null) 'languageCode': languageCode,
        if (siteIds != null && siteIds!.isNotEmpty) 'siteIds': siteIds,
        'hideTitle': hideTitle,
        'filtersExpanded': filtersExpanded,
        'urlParamsRefresh': urlParamsRefresh,
        if (extraUrlParams.isNotEmpty) 'extraUrlParams': extraUrlParams,
      };

  // ── Mutation helper ───────────────────────────────────────────────────────

  /// Return a new config with selected fields replaced; all other fields are
  /// carried over from the receiver.
  SupersetBridgeConfig copyWith({
    String? dashboardId,
    String? domain,
    String? theme,
    String? languageCode,
    List<int>? siteIds,
    bool? hideTitle,
    bool? filtersExpanded,
    bool? urlParamsRefresh,
    Map<String, dynamic>? extraUrlParams,
  }) {
    return SupersetBridgeConfig(
      dashboardId: dashboardId ?? this.dashboardId,
      domain: domain ?? this.domain,
      theme: theme ?? this.theme,
      languageCode: languageCode ?? this.languageCode,
      siteIds: siteIds ?? this.siteIds,
      hideTitle: hideTitle ?? this.hideTitle,
      filtersExpanded: filtersExpanded ?? this.filtersExpanded,
      urlParamsRefresh: urlParamsRefresh ?? this.urlParamsRefresh,
      extraUrlParams: extraUrlParams ?? this.extraUrlParams,
    );
  }

  @override
  String toString() => 'SupersetBridgeConfig(${jsonEncode(toJson())})';
}
