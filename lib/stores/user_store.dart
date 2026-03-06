import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/constants/app_constants.dart';

/// 用户信息模型
class UserInfo {
  final int id;
  final String username;
  final String nickname;
  final String? avatar;
  final String? email;
  final String? mobile;
  final int? deptId;
  final List<String> roles;

  const UserInfo({
    required this.id,
    required this.username,
    required this.nickname,
    this.avatar,
    this.email,
    this.mobile,
    this.deptId,
    this.roles = const [],
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      avatar: json['avatar'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      deptId: json['deptId'] as int?,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'nickname': nickname,
        'avatar': avatar,
        'email': email,
        'mobile': mobile,
        'deptId': deptId,
        'roles': roles,
      };
}

/// 用户状态
class UserState {
  final UserInfo? userInfo;
  final bool isLoading;

  const UserState({
    this.userInfo,
    this.isLoading = false,
  });

  bool get isLoggedIn => userInfo != null;

  UserState copyWith({
    UserInfo? userInfo,
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
        state = state.copyWith(userInfo: UserInfo.fromJson(json));
      }
    } catch (e) {
      // 忽略读取错误
    }
  }

  /// 设置用户信息
  Future<void> setUserInfo(UserInfo userInfo) async {
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