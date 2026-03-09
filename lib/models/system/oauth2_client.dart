/// OAuth2.0 客户端模型
class OAuth2Client {
  final int? id;
  final String clientId;
  final String? secret;
  final String name;
  final String? logo;
  final String? description;
  final int? status;
  final int? accessTokenValiditySeconds;
  final int? refreshTokenValiditySeconds;
  final List<String>? redirectUris;
  final bool? autoApprove;
  final List<String>? authorizedGrantTypes;
  final List<String>? scopes;
  final List<String>? authorities;
  final List<String>? resourceIds;
  final String? additionalInformation;
  final bool? isAdditionalInformationJson;
  final String? createTime;

  const OAuth2Client({
    this.id,
    required this.clientId,
    this.secret,
    required this.name,
    this.logo,
    this.description,
    this.status,
    this.accessTokenValiditySeconds,
    this.refreshTokenValiditySeconds,
    this.redirectUris,
    this.autoApprove,
    this.authorizedGrantTypes,
    this.scopes,
    this.authorities,
    this.resourceIds,
    this.additionalInformation,
    this.isAdditionalInformationJson,
    this.createTime,
  });

  factory OAuth2Client.fromJson(Map<String, dynamic> json) {
    return OAuth2Client(
      id: json['id'] as int?,
      clientId: json['clientId'] as String? ?? '',
      secret: json['secret'] as String?,
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
      description: json['description'] as String?,
      status: json['status'] as int?,
      accessTokenValiditySeconds: json['accessTokenValiditySeconds'] as int?,
      refreshTokenValiditySeconds: json['refreshTokenValiditySeconds'] as int?,
      redirectUris: (json['redirectUris'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      autoApprove: json['autoApprove'] as bool?,
      authorizedGrantTypes: (json['authorizedGrantTypes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      scopes: (json['scopes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      authorities: (json['authorities'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      resourceIds: (json['resourceIds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      additionalInformation: json['additionalInformation'] as String?,
      isAdditionalInformationJson: json['isAdditionalInformationJson'] as bool?,
      createTime: json['createTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'clientId': clientId,
      if (secret != null) 'secret': secret,
      'name': name,
      if (logo != null) 'logo': logo,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (accessTokenValiditySeconds != null)
        'accessTokenValiditySeconds': accessTokenValiditySeconds,
      if (refreshTokenValiditySeconds != null)
        'refreshTokenValiditySeconds': refreshTokenValiditySeconds,
      if (redirectUris != null) 'redirectUris': redirectUris,
      if (autoApprove != null) 'autoApprove': autoApprove,
      if (authorizedGrantTypes != null)
        'authorizedGrantTypes': authorizedGrantTypes,
      if (scopes != null) 'scopes': scopes,
      if (authorities != null) 'authorities': authorities,
      if (resourceIds != null) 'resourceIds': resourceIds,
      if (additionalInformation != null)
        'additionalInformation': additionalInformation,
      if (isAdditionalInformationJson != null)
        'isAdditionalInformationJson': isAdditionalInformationJson,
    };
  }
}