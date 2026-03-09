import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// 认证状态
class AccessState {
  final String? accessToken;
  final String? refreshToken;
  final Set<String> permissions;
  final List<MenuItem> menus;
  final bool isAuthenticated;

  const AccessState({
    this.accessToken,
    this.refreshToken,
    this.permissions = const {},
    this.menus = const [],
    this.isAuthenticated = false,
  });

  AccessState copyWith({
    String? accessToken,
    String? refreshToken,
    Set<String>? permissions,
    List<MenuItem>? menus,
    bool? isAuthenticated,
    bool clearToken = false,
  }) {
    return AccessState(
      accessToken: clearToken ? null : (accessToken ?? this.accessToken),
      refreshToken: clearToken ? null : (refreshToken ?? this.refreshToken),
      permissions: permissions ?? this.permissions,
      menus: menus ?? this.menus,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  bool hasPermission(String permission) => permissions.contains(permission);
}

/// 菜单项
class MenuItem {
  final String id;
  final String name;
  final String path;
  final String? icon;
  final List<MenuItem> children;

  const MenuItem({
    required this.id,
    required this.name,
    required this.path,
    this.icon,
    this.children = const [],
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final children = json['children'] as List<dynamic>? ?? [];
    return MenuItem(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
      icon: json['icon'] as String?,
      children: children
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'path': path,
        'icon': icon,
        'children': children.map((e) => e.toJson()).toList(),
      };
}

/// 认证状态管理器
class AccessStore extends Notifier<AccessState> {
  late final FlutterSecureStorage _storage;
  SharedPreferences? _prefs;

  @override
  AccessState build() {
    _storage = const FlutterSecureStorage();
    _loadStoredData();
    return const AccessState();
  }

  /// 加载存储的数据（Token 和菜单）
  Future<void> _loadStoredData() async {
    try {
      // 加载 Token
      final accessToken = await _storage.read(key: AppConstants.tokenKey);
      final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);

      // 加载菜单
      _prefs ??= await SharedPreferences.getInstance();
      final menuJson = _prefs!.getString(AppConstants.menuInfoKey);
      List<MenuItem> menus = const [];
      if (menuJson != null && menuJson.isNotEmpty) {
        final menuList = jsonDecode(menuJson) as List<dynamic>;
        menus = menuList
            .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (accessToken != null && accessToken.isNotEmpty) {
        state = state.copyWith(
          accessToken: accessToken,
          refreshToken: refreshToken,
          menus: menus,
          isAuthenticated: true,
        );
      }
    } catch (e) {
      // 忽略读取错误
    }
  }

  /// 设置访问令牌
  Future<void> setAccess({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: AppConstants.tokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
    }

    state = state.copyWith(
      accessToken: accessToken,
      refreshToken: refreshToken,
      isAuthenticated: true,
    );
  }

  /// 设置权限
  void setPermissions(Set<String> permissions) {
    state = state.copyWith(permissions: permissions);
  }

  /// 设置菜单
  Future<void> setMenus(List<MenuItem> menus) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(
      AppConstants.menuInfoKey,
      jsonEncode(menus.map((e) => e.toJson()).toList()),
    );
    state = state.copyWith(menus: menus);
  }

  /// 清除访问状态
  Future<void> clearAccess() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);

    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(AppConstants.menuInfoKey);

    state = const AccessState();
  }

  /// 检查是否有权限
  bool hasPermission(String permission) {
    return state.hasPermission(permission);
  }
}

/// 认证状态提供者
final accessStoreProvider = NotifierProvider<AccessStore, AccessState>(
  AccessStore.new,
);