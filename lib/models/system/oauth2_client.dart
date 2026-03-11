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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      clientId: json['clientId']?.toString() ?? '',
      secret: json['secret']?.toString(),
      name: json['name']?.toString() ?? '',
      logo: json['logo']?.toString(),
      description: json['description']?.toString(),
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? ''),
      accessTokenValiditySeconds: json['accessTokenValiditySeconds'] is int ? json['accessTokenValiditySeconds'] : int.tryParse(json['accessTokenValiditySeconds']?.toString() ?? ''),
      refreshTokenValiditySeconds: json['refreshTokenValiditySeconds'] is int ? json['refreshTokenValiditySeconds'] : int.tryParse(json['refreshTokenValiditySeconds']?.toString() ?? ''),
      redirectUris: (json['redirectUris'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      autoApprove: json['autoApprove'] is bool ? json['autoApprove'] : bool.tryParse(json['autoApprove']?.toString() ?? ''),
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
      additionalInformation: json['additionalInformation']?.toString(),
      isAdditionalInformationJson: json['isAdditionalInformationJson'] is bool ? json['isAdditionalInformationJson'] : bool.tryParse(json['isAdditionalInformationJson']?.toString() ?? ''),
      createTime: json['createTime']?.toString(),
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