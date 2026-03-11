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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      accessToken: json['accessToken']?.toString(),
      refreshToken: json['refreshToken']?.toString(),
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? ''),
      userType: json['userType'] is int ? json['userType'] : int.tryParse(json['userType']?.toString() ?? ''),
      clientId: json['clientId']?.toString(),
      createTime: json['createTime']?.toString(),
      expiresTime: json['expiresTime']?.toString(),
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