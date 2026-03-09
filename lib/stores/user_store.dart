import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/constants/app_constants.dart';

/// 用户信息模型
class UserInfoStore {
  final int id;
  final String username;
  final String nickname;
  final String? avatar;
  final String? email;
  final String? mobile;
  final int? deptId;
  final List<String> roles;
  final List<String> permissions;

  const UserInfoStore({
    required this.id,
    required this.username,
    required this.nickname,
    this.avatar,
    this.email,
    this.mobile,
    this.deptId,
    this.roles = const [],
    this.permissions = const [],
  });

  /// 从芋道后台 get-permission-info 接口响应解析
  factory UserInfoStore.fromJson(Map<String, dynamic> json) {
    // 解析用户基本信息
    final user = json['user'] as Map<String, dynamic>? ?? {};

    // 解析角色列表
    final roles = (json['roles'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // 解析权限列表
    final permissions = (json['permissions'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return UserInfoStore(
      id: user['id'] as int? ?? 0,
      username: user['username'] as String? ?? '',
      nickname: user['nickname'] as String? ?? '',
      avatar: user['avatar'] as String?,
      email: user['email'] as String?,
      mobile: user['mobile'] as String?,
      deptId: user['deptId'] as int?,
      roles: roles,
      permissions: permissions,
    );
  }

  Map<String, dynamic> toJson() => {
        'user': {
          'id': id,
          'username': username,
          'nickname': nickname,
          'avatar': avatar,
          'email': email,
          'mobile': mobile,
          'deptId': deptId,
        },
        'roles': roles,
        'permissions': permissions,
      };
}

/// 用户状态
class UserState {
  final UserInfoStore? userInfo;
  final bool isLoading;

  const UserState({
    this.userInfo,
    this.isLoading = false,
  });

  bool get isLoggedIn => userInfo != null;

  UserState copyWith({
    UserInfoStore? userInfo,
    bool? isLoading,
    bool clearUser = false,
  }) {
    return UserState(
      userInfo: clearUser ? null : (userInfo ?? this.userInfo),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 用户状态管理器
class UserStore extends Notifier<UserState> {
  SharedPreferences? _prefs;

  @override
  UserState build() {
    _loadStoredUser();
    return const UserState();
  }

  /// 加载存储的用户信息
  Future<void> _loadStoredUser() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final userJson = _prefs!.getString(AppConstants.userInfoKey);
      if (userJson != null && userJson.isNotEmpty) {
        final json = jsonDecode(userJson) as Map<String, dynamic>;
        state = state.copyWith(userInfo: UserInfoStore.fromJson(json));
      }
    } catch (e) {
      // 忽略读取错误
    }
  }

  /// 设置用户信息
  Future<void> setUserInfo(UserInfoStore userInfo) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(AppConstants.userInfoKey, jsonEncode(userInfo.toJson()));
    state = state.copyWith(userInfo: userInfo);
  }

  /// 清除用户信息
  Future<void> clearUser() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(AppConstants.userInfoKey);
    state = state.copyWith(clearUser: true);
  }

  /// 设置加载状态
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

/// 用户状态提供者
final userStoreProvider = NotifierProvider<UserStore, UserState>(
  UserStore.new,
);