import 'package:flutter/material.dart';

/// 页面路由元数据
class PageRouteMeta {
  /// 路由路径，如 /system/user
  final String path;

  /// 路由名称，用于 GoRoute 的 name 参数
  final String name;

  /// 页面标题，用于面包屑和页面标题
  final String title;

  /// 图标标识，用于菜单显示
  final String? icon;

  /// 所需权限标识，如 system:user:list
  final String? permission;

  /// 是否在菜单中隐藏
  final bool hideInMenu;

  /// 是否忽略权限检查
  final bool ignoreAccess;

  /// 路由别名列表
  final List<String> aliases;

  /// 页面构建器
  final WidgetBuilder builder;

  const PageRouteMeta({
    required this.path,
    required this.name,
    required this.title,
    this.icon,
    this.permission,
    this.hideInMenu = false,
    this.ignoreAccess = false,
    this.aliases = const [],
    required this.builder,
  });

  /// 是否为动态路由（包含路径参数，如 /user/:id）
  bool get isDynamic => path.contains(':');
}

/// 路由注册表
///
/// 用于注册和管理所有页面路由元数据。
/// 支持静态路由和动态路由参数匹配。
class RouteRegistry {
  RouteRegistry._();

  /// 已注册的路由映射表
  static final Map<String, PageRouteMeta> _routes = {};

  /// 动态路由列表（包含路径参数的路由）
  static final List<PageRouteMeta> _dynamicRoutes = [];

  /// 注册单个路由
  static void register(PageRouteMeta meta) {
    _routes[meta.path] = meta;
    if (meta.isDynamic) {
      _dynamicRoutes.add(meta);
    }
  }

  /// 批量注册路由
  static void registerAll(List<PageRouteMeta> routes) {
    for (final route in routes) {
      register(route);
    }
  }

  /// 获取指定路径的路由元数据
  static PageRouteMeta? getRoute(String path) => _routes[path];

  /// 获取所有已注册的路由
  static List<PageRouteMeta> getAllRoutes() => _routes.values.toList();

  /// 获取所有静态路由（非动态路由）
  static List<PageRouteMeta> getStaticRoutes() =>
      _routes.values.where((r) => !r.isDynamic).toList();

  /// 获取所有动态路由
  static List<PageRouteMeta> getDynamicRoutes() => List.unmodifiable(_dynamicRoutes);

  /// 匹配动态路由
  ///
  /// 根据实际路径匹配动态路由模板。
  /// 例如：路径 /user/123 可以匹配模板 /user/:id
  static PageRouteMeta? matchDynamicRoute(String path) {
    for (final meta in _dynamicRoutes) {
      if (_matchPath(meta.path, path)) {
        return meta;
      }
    }
    return null;
  }

  /// 获取路由（支持静态和动态路由）
  static PageRouteMeta? getRouteOrMatch(String path) {
    final staticRoute = _routes[path];
    if (staticRoute != null) return staticRoute;
    return matchDynamicRoute(path);
  }

  /// 检查路径是否匹配动态路由模板
  static bool _matchPath(String pattern, String path) {
    final patternParts = pattern.split('/');
    final pathParts = path.split('/');

    if (patternParts.length != pathParts.length) return false;

    for (int i = 0; i < patternParts.length; i++) {
      final patternPart = patternParts[i];
      final pathPart = pathParts[i];

      // 动态参数部分（以 : 开头）可以匹配任意值
      if (!patternPart.startsWith(':') && patternPart != pathPart) {
        return false;
      }
    }

    return true;
  }

  /// 从动态路由模板和实际路径提取路径参数
  ///
  /// 例如：模板 /user/:id，路径 /user/123
  /// 返回：{'id': '123'}
  static Map<String, String> extractPathParameters(String pattern, String path) {
    final params = <String, String>{};
    final patternParts = pattern.split('/');
    final pathParts = path.split('/');

    for (int i = 0; i < patternParts.length && i < pathParts.length; i++) {
      final patternPart = patternParts[i];
      if (patternPart.startsWith(':')) {
        final paramName = patternPart.substring(1);
        params[paramName] = pathParts[i];
      }
    }

    return params;
  }

  /// 清除所有已注册的路由（用于测试或重置）
  static void clear() {
    _routes.clear();
    _dynamicRoutes.clear();
  }

  /// 检查路由是否已注册
  static bool hasRoute(String path) => _routes.containsKey(path);

  /// 获取已注册路由数量
  static int get routeCount => _routes.length;
}