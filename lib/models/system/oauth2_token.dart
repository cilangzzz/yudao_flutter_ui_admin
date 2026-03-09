/// OAuth2.0 令牌模型
class OAuth2Token {
  final int? id;
  final String? accessToken;
  final String? refreshToken;
  final int? userId;
  final int? userType;
  final String? clientId;
  final String? createTime;
  final String? expiresTime;

  const OAuth2Token({
    this.id,
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.userType,
    this.clientId,
    this.createTime,
    this.expiresTime,
  });

  factory OAuth2Token.fromJson(Map<String, dynamic> json) {
    return OAuth2Token(
      id: json['id'] as int?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      userId: json['userId'] as int?,
      userType: json['userType'] as int?,
      clientId: json['clientId'] as String?,
      createTime: json['createTime'] as String?,
      expiresTime: json['expiresTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (accessToken != null) 'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
      if (userId != null) 'userId': userId,
      if (userType != null) 'userType': userType,
      if (clientId != null) 'clientId': clientId,
      if (createTime != null) 'createTime': createTime,
      if (expiresTime != null) 'expiresTime': expiresTime,
    };
  }
}