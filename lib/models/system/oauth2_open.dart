/// OAuth2.0 授权信息响应 - 客户端信息
class OAuth2AuthorizeClient {
  final String? logo;
  final String? name;

  const OAuth2AuthorizeClient({
    this.logo,
    this.name,
  });

  factory OAuth2AuthorizeClient.fromJson(Map<String, dynamic> json) {
    return OAuth2AuthorizeClient(
      logo: json['logo'] as String?,
      name: json['name'] as String?,
    );
  }
}

/// OAuth2.0 授权信息响应 - Scope 信息
class OAuth2AuthorizeScope {
  final String key;
  final bool value;

  const OAuth2AuthorizeScope({
    required this.key,
    required this.value,
  });

  factory OAuth2AuthorizeScope.fromJson(Map<String, dynamic> json) {
    return OAuth2AuthorizeScope(
      key: json['key'] as String? ?? '',
      value: json['value'] as bool? ?? false,
    );
  }
}

/// OAuth2.0 授权信息响应
class OAuth2AuthorizeInfo {
  final OAuth2AuthorizeClient? client;
  final List<OAuth2AuthorizeScope>? scopes;

  const OAuth2AuthorizeInfo({
    this.client,
    this.scopes,
  });

  factory OAuth2AuthorizeInfo.fromJson(Map<String, dynamic> json) {
    return OAuth2AuthorizeInfo(
      client: json['client'] != null
          ? OAuth2AuthorizeClient.fromJson(
              json['client'] as Map<String, dynamic>)
          : null,
      scopes: (json['scopes'] as List<dynamic>?)
          ?.map((e) => OAuth2AuthorizeScope.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}