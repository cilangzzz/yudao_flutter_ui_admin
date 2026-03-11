import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yudao_flutter_ui_admin/stores/access_store.dart';
import 'package:yudao_flutter_ui_admin/pages/layout/basic_layout.dart';
import 'route_registry.dart';
import 'app_router.dart' show Routes, RouteMeta;

/// 动态路由状态
class DynamicRouterState {
  /// 所有路由列表
  final List<RouteBase> routes;

  /// 路由元数据映射
  final Map<String, RouteMeta> metaMap;

  /// 路由权限映射
  final Map<String, String> permissionMap;

  /// 是否已初始化
  final bool isInitialized;

  const DynamicRouterState({
    this.routes = const [],
    this.metaMap = const {},
    this.permissionMap = const {},
    this.isInitialized = false,
  });

  DynamicRouterState copyWith({
    List<RouteBase>? routes,
    Map<String, RouteMeta>? metaMap,
    Map<String, String>? permissionMap,
    bool? isInitialized,
  }) {
    return DynamicRouterState(
      routes: routes ?? this.routes,
      metaMap: metaMap ?? this.metaMap,
      permissionMap: permissionMap ?? this.permissionMap,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// 动态路由配置器
///
/// 监听菜单数据变化，动态生成路由配置。
/// 结合 RouteRegistry 中的页面注册信息构建完整的路由表。
class DynamicRouterNotifier extends Notifier<DynamicRouterState> {
  @override
  DynamicRouterState build() {
    // 监听菜单变化
    ref.listen<AccessState>(accessStoreProvider, (prev, next) {
      if (prev?.menus != next.menus) {
        _rebuildRoutes(next.menus);
      }
    });

    // 初始构建
    final menus = ref.read(accessStoreProvider).menus;
    return _buildState(menus);
  }

  /// 重建路由
  void _rebuildRoutes(List<MenuItem> menus) {
    state = _buildState(menus);
  }

  /// 构建路由状态
  DynamicRouterState _buildState(List<MenuItem> menus) {
    final routes = <RouteBase>[];
    final metaMap = <String, RouteMeta>{};
    final permissionMap = <String, String>{};

    // 1. 添加核心路由（登录、403等）
    routes.addAll(_buildCoreRoutes());

    // 2. 构建主布局路由（ShellRoute）
    final shellRoute = _buildShellRoute(menus, metaMap, permissionMap);
    routes.add(shellRoute);

    return DynamicRouterState(
      routes: routes,
      metaMap: metaMap,
      permissionMap: permissionMap,
      isInitialized: true,
    );
  }

  /// 构建核心路由（不需要权限的路由）
  List<RouteBase> _buildCoreRoutes() {
    return [
      GoRoute(
        path: Routes.login,
        name: Routes.loginName,
        builder: (context, state) => const _PlaceholderPage(title: '登录页'),
      ),
      GoRoute(
        path: Routes.forbidden,
        name: Routes.forbiddenName,
        builder: (context, state) => const _PlaceholderPage(title: '403 无权访问'),
      ),
    ];
  }

  /// 构建 ShellRoute（主布局）
  ShellRoute _buildShellRoute(
    List<MenuItem> menus,
    Map<String, RouteMeta> metaMap,
    Map<String, String> permissionMap,
  ) {
    final children = <RouteBase>[];

    // 添加仪表板路由
    children.add(GoRoute(
      path: Routes.dashboard,
      name: Routes.dashboardName,
      builder: (context, state) {
        final route = RouteRegistry.getRoute(Routes.dashboard);
        return route?.builder(context) ?? const _PlaceholderPage(title: '仪表板');
      },
    ));

    // 根据菜单构建路由
    for (final menu in menus) {
      _buildRoutesFromMenu(menu, children, metaMap, permissionMap, null);
    }

    return ShellRoute(
      builder: (context, state, child) => _DynamicLayout(child: child),
      routes: children,
    );
  }

  /// 从菜单构建路由
  void _buildRoutesFromMenu(
    MenuItem menu,
    List<RouteBase> routes,
    Map<String, RouteMeta> metaMap,
    Map<String, String> permissionMap,
    String? parentPath,
  ) {
    final fullPath = _buildFullPath(menu.path, parentPath);

    // 查找注册的路由
    final registeredRoute = RouteRegistry.getRoute(fullPath);

    if (menu.children.isNotEmpty) {
      // 有子菜单 - 创建父路由
      final childRoutes = <RouteBase>[];

      for (final child in menu.children) {
        _buildRoutesFromMenu(child, childRoutes, metaMap, permissionMap, fullPath);
      }

      if (registeredRoute != null) {
        // 父菜单有对应页面
        routes.add(GoRoute(
          path: _getRelativePath(fullPath, parentPath),
          name: menu.id,
          builder: (context, state) => registeredRoute.builder(context),
          routes: childRoutes,
        ));
        _addMetaAndPermission(fullPath, menu, registeredRoute, metaMap, permissionMap);
      } else {
        // 父菜单仅作为容器，重定向到第一个子路由
        routes.add(GoRoute(
          path: _getRelativePath(fullPath, parentPath),
          name: menu.id,
          redirect: (context, state) => _getFirstChildPath(fullPath, childRoutes),
          routes: childRoutes,
        ));
      }
    } else {
      // 叶子菜单 - 添加具体页面
      if (registeredRoute != null) {
        routes.add(GoRoute(
          path: _getRelativePath(fullPath, parentPath),
          name: menu.id,
          builder: (context, state) => registeredRoute.builder(context),
        ));
        _addMetaAndPermission(fullPath, menu, registeredRoute, metaMap, permissionMap);
      } else {
        // 尝试匹配动态路由
        final dynamicRoute = RouteRegistry.matchDynamicRoute(fullPath);
        if (dynamicRoute != null) {
          routes.add(GoRoute(
            path: _getRelativePath(fullPath, parentPath),
            name: menu.id,
            builder: (context, state) => dynamicRoute.builder(context),
          ));
          _addMetaAndPermission(fullPath, menu, dynamicRoute, metaMap, permissionMap);
        }
      }
    }
  }

  /// 构建完整路径
  String _buildFullPath(String path, String? parentPath) {
    if (path.startsWith('/')) return path;
    if (parentPath == null) return '/$path';
    return '$parentPath/$path';
  }

  /// 获取相对路径
  String _getRelativePath(String fullPath, String? parentPath) {
    if (parentPath == null) return fullPath;
    return fullPath.replaceFirst('$parentPath/', '');
  }

  /// 获取第一个子路由路径
  String? _getFirstChildPath(String parentPath, List<RouteBase> childRoutes) {
    if (childRoutes.isEmpty) return null;
    final firstChild = childRoutes.first;
    if (firstChild is GoRoute) {
      return '$parentPath/${firstChild.path}';
    }
    return null;
  }

  /// 添加元数据和权限映射
  void _addMetaAndPermission(
    String path,
    MenuItem menu,
    PageRouteMeta registered,
    Map<String, RouteMeta> metaMap,
    Map<String, String> permissionMap,
  ) {
    metaMap[path] = RouteMeta(
      title: menu.name,
      icon: menu.icon,
      hideInMenu: registered.hideInMenu,
      ignoreAccess: registered.ignoreAccess,
    );
    if (registered.permission != null) {
      permissionMap[path] = registered.permission!;
    }
  }

  /// 刷新路由（外部调用）
  void refresh() {
    final menus = ref.read(accessStoreProvider).menus;
    state = _buildState(menus);
  }
}

/// 动态路由状态提供者
final dynamicRouterProvider = NotifierProvider<DynamicRouterNotifier, DynamicRouterState>(
  DynamicRouterNotifier.new,
);

/// 动态布局组件
///
/// 直接使用 BasicLayout 包装子组件。
class _DynamicLayout extends StatelessWidget {
  final Widget child;

  const _DynamicLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return BasicLayout(child: child);
  }
}

/// 占位页面
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            const Text('请注册对应的页面路由'),
          ],
        ),
      ),
    );
  }
}