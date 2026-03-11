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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      type: json['type'] is int ? json['type'] : int.tryParse(json['type']?.toString() ?? ''),
      openid: json['openid']?.toString(),
      token: json['token']?.toString(),
      rawTokenInfo: json['rawTokenInfo']?.toString(),
      nickname: json['nickname']?.toString(),
      avatar: json['avatar']?.toString(),
      rawUserInfo: json['rawUserInfo']?.toString(),
      code: json['code']?.toString(),
      state: json['state']?.toString(),
      createTime: json['createTime']?.toString(),
      updateTime: json['updateTime']?.toString(),
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