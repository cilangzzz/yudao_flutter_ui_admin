/// 登录接口参数
class LoginParams {
  final String? username;
  final String? password;
  final String? captchaVerification;
  // 绑定社交登录时，需要传递如下参数
  final int? socialType;
  final String? socialCode;
  final String? socialState;

  const LoginParams({
    this.username,
    this.password,
    this.captchaVerification,
    this.socialType,
    this.socialCode,
    this.socialState,
  });

  Map<String, dynamic> toJson() {
    return {
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (captchaVerification != null) 'captchaVerification': captchaVerification,
      if (socialType != null) 'socialType': socialType,
      if (socialCode != null) 'socialCode': socialCode,
      if (socialState != null) 'socialState': socialState,
    };
  }
}

/// 登录接口返回值
class LoginResult {
  final String accessToken;
  final String? refreshToken;
  final int? userId;
  final int? expiresTime;

  const LoginResult({
    required this.accessToken,
    this.refreshToken,
    this.userId,
    this.expiresTime,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
      userId: json['userId'] as int?,
      expiresTime: json['expiresTime'] as int?,
    );
  }
}

/// 租户信息返回值
class TenantResult {
  final int? id;
  final String? name;

  const TenantResult({
    this.id,
    this.name,
  });

  factory TenantResult.fromJson(Map<String, dynamic> json) {
    return TenantResult(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }
}

/// 手机验证码获取接口参数
class SmsCodeParams {
  final String mobile;
  final int scene;

  const SmsCodeParams({
    required this.mobile,
    required this.scene,
  });

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
      'scene': scene,
    };
  }
}

/// 手机验证码登录接口参数
class SmsLoginParams {
  final String mobile;
  final String code;

  const SmsLoginParams({
    required this.mobile,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
      'code': code,
    };
  }
}

/// 注册接口参数
class RegisterParams {
  final String username;
  final String password;
  final String captchaVerification;

  const RegisterParams({
    required this.username,
    required this.password,
    required this.captchaVerification,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'captchaVerification': captchaVerification,
    };
  }
}

/// 重置密码接口参数
class ResetPasswordParams {
  final String password;
  final String mobile;
  final String code;

  const ResetPasswordParams({
    required this.password,
    required this.mobile,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'mobile': mobile,
      'code': code,
    };
  }
}

/// 社交快捷登录接口参数
class SocialLoginParams {
  final int type;
  final String code;
  final String state;

  const SocialLoginParams({
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

/// 权限信息
class AuthPermissionInfo {
  final UserInfo? user;
  final List<RoleInfo>? roles;
  final List<String>? permissions;
  final List<MenuInfo>? menus;

  const AuthPermissionInfo({
    this.user,
    this.roles,
    this.permissions,
    this.menus,
  });

  factory AuthPermissionInfo.fromJson(Map<String, dynamic> json) {
    return AuthPermissionInfo(
      user: json['user'] != null
          ? UserInfo.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      roles: (json['roles'] as List<dynamic>?)
          ?.map((e) => RoleInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      menus: (json['menus'] as List<dynamic>?)
          ?.map((e) => MenuInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 用户信息
class UserInfo {
  final int? id;
  final String? username;
  final String? nickname;
  final String? email;
  final String? mobile;
  final String? avatar;
  final int? sex;
  final int? status;
  final int? deptId;
  final String? deptName;
  final List<int>? postIds;

  const UserInfo({
    this.id,
    this.username,
    this.nickname,
    this.email,
    this.mobile,
    this.avatar,
    this.sex,
    this.status,
    this.deptId,
    this.deptName,
    this.postIds,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int?,
      username: json['username'] as String?,
      nickname: json['nickname'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      avatar: json['avatar'] as String?,
      sex: json['sex'] as int?,
      status: json['status'] as int?,
      deptId: json['deptId'] as int?,
      deptName: json['deptName'] as String?,
      postIds: (json['postIds'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
    );
  }
}

/// 角色信息
class RoleInfo {
  final int? id;
  final String? name;
  final String? code;

  const RoleInfo({
    this.id,
    this.name,
    this.code,
  });

  factory RoleInfo.fromJson(Map<String, dynamic> json) {
    return RoleInfo(
      id: json['id'] as int?,
      name: json['name'] as String?,
      code: json['code'] as String?,
    );
  }
}

/// 菜单信息
class MenuInfo {
  final int? id;
  final String? name;
  final String? path;
  final String? component;
  final String? icon;
  final int? sort;
  final int? parentId;
  final List<MenuInfo>? children;

  const MenuInfo({
    this.id,
    this.name,
    this.path,
    this.component,
    this.icon,
    this.sort,
    this.parentId,
    this.children,
  });

  factory MenuInfo.fromJson(Map<String, dynamic> json) {
    return MenuInfo(
      id: json['id'] as int?,
      name: json['name'] as String?,
      path: json['path'] as String?,
      component: json['component'] as String?,
      icon: json['icon'] as String?,
      sort: json['sort'] as int?,
      parentId: json['parentId'] as int?,
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => MenuInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}