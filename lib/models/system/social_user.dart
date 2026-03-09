/// 社交用户模型
class SocialUser {
  final int? id;
  final int? type;
  final String? openid;
  final String? token;
  final String? rawTokenInfo;
  final String? nickname;
  final String? avatar;
  final String? rawUserInfo;
  final String? code;
  final String? state;
  final String? createTime;
  final String? updateTime;

  const SocialUser({
    this.id,
    this.type,
    this.openid,
    this.token,
    this.rawTokenInfo,
    this.nickname,
    this.avatar,
    this.rawUserInfo,
    this.code,
    this.state,
    this.createTime,
    this.updateTime,
  });

  factory SocialUser.fromJson(Map<String, dynamic> json) {
    return SocialUser(
      id: json['id'] as int?,
      type: json['type'] as int?,
      openid: json['openid'] as String?,
      token: json['token'] as String?,
      rawTokenInfo: json['rawTokenInfo'] as String?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      rawUserInfo: json['rawUserInfo'] as String?,
      code: json['code'] as String?,
      state: json['state'] as String?,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (openid != null) 'openid': openid,
      if (token != null) 'token': token,
      if (rawTokenInfo != null) 'rawTokenInfo': rawTokenInfo,
      if (nickname != null) 'nickname': nickname,
      if (avatar != null) 'avatar': avatar,
      if (rawUserInfo != null) 'rawUserInfo': rawUserInfo,
      if (code != null) 'code': code,
      if (state != null) 'state': state,
      if (createTime != null) 'createTime': createTime,
      if (updateTime != null) 'updateTime': updateTime,
    };
  }
}

/// 社交绑定请求
class SocialUserBindReq {
  final int type;
  final String code;
  final String state;

  const SocialUserBindReq({
    required this.type,
    required this.code,
    required this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'code': code,
      'state': state,
    };
  }
}

/// 取消社交绑定请求
class SocialUserUnbindReq {
  final int type;
  final String openid;

  const SocialUserUnbindReq({
    required this.type,
    required this.openid,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'openid': openid,
    };
  }
}