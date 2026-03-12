import 'dart:convert';
class SupersetBridgeConfig {
  const SupersetBridgeConfig({
    required this.dashboardId,
    required this.domain,
    required this.tokenBaseURL,
    this.theme = 'light',
    this.languageCode,
    this.siteIds,
    this.hideTitle = true,
    this.filtersExpanded = false,
    this.urlParamsRefresh = true,
    this.extraUrlParams = const {},
  });

  final String dashboardId;
  final String domain;
  final String tokenBaseURL;
  final String theme;
  final String? languageCode;
  final List<int>? siteIds;
  final bool hideTitle;
  final bool filtersExpanded;
  final bool urlParamsRefresh;
  final Map<String, dynamic> extraUrlParams;
  factory SupersetBridgeConfig.fromJson(Map<String, dynamic> json) {
    return SupersetBridgeConfig(
      tokenBaseURL: json['tokenBaseURL'] as String? ?? '',
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
  Map<String, dynamic> toJson() => {
        'dashboardId': dashboardId,
        'domain': domain,
        'tokenBaseURL': tokenBaseURL,
        'theme': theme,
        if (languageCode != null) 'languageCode': languageCode,
        if (siteIds != null && siteIds!.isNotEmpty) 'siteIds': siteIds,
        'hideTitle': hideTitle,
        'filtersExpanded': filtersExpanded,
        'urlParamsRefresh': urlParamsRefresh,
        if (extraUrlParams.isNotEmpty) 'extraUrlParams': extraUrlParams,
      };
  SupersetBridgeConfig copyWith({
    String? dashboardId,
    String? domain,
    String? tokenBaseURL,
    String? theme,
    String? languageCode,
    List<int>? siteIds,
    bool? hideTitle,
    bool? filtersExpanded,
    bool? urlParamsRefresh,
    Map<String, dynamic>? extraUrlParams,
  }) {
    return SupersetBridgeConfig(
      tokenBaseURL: tokenBaseURL ?? this.tokenBaseURL,
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
