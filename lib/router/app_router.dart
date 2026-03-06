import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../stores/access_store.dart';
import '../pages/auth/login_page.dart';
import '../pages/layout/basic_layout.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../pages/system/user/user_page.dart';
import '../pages/system/role/role_page.dart';
import '../pages/system/menu/menu_page.dart';
import '../pages/system/dept/dept_page.dart';

/// 路由路径常量
class Routes {
  Routes._();

  static const String login = '/login';
  static const String dashboard = '/';
  static const String system = '/system';
  static const String user = '/system/user';
  static const String role = '/system/role';
  static const String menu = '/system/menu';
  static const String dept = '/system/dept';
}

/// 路由配置提供者
final routerProvider = Provider<GoRouter>((ref) {
  final accessState = ref.watch(accessStoreProvider);

  return GoRouter(
    initialLocation: Routes.dashboard,
    redirect: (context, state) {
      final isAuthenticated = accessState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == Routes.login;

      // 未登录且不在登录页，重定向到登录页
      if (!isAuthenticated && !isLoginRoute) {
        return Routes.login;
      }

      // 已登录且在登录页，重定向到首页
      if (isAuthenticated && isLoginRoute) {
        return Routes.dashboard;
      }

      return null;
    },
    routes: [
      // 登录页
      GoRoute(
        path: Routes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // 主布局路由（需要登录）
      ShellRoute(
        builder: (context, state, child) => BasicLayout(child: child),
        routes: [
          // 仪表板
          GoRoute(
            path: Routes.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),

          // 系统管理 - 用户管理
          GoRoute(
            path: Routes.user,
            name: 'user',
            builder: (context, state) => const UserPage(),
          ),

          // 系统管理 - 角色管理
          GoRoute(
            path: Routes.role,
            name: 'role',
            builder: (context, state) => const RolePage(),
          ),

          // 系统管理 - 菜单管理
          GoRoute(
            path: Routes.menu,
            name: 'menu',
            builder: (context, state) => const MenuPage(),
          ),

          // 系统管理 - 部门管理
          GoRoute(
            path: Routes.dept,
            name: 'dept',
            builder: (context, state) => const DeptPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => ScaffoldErrorPage(error: state.error),
  );
});

/// 错误页面
class ScaffoldErrorPage extends StatelessWidget {
  final Exception? error;

  const ScaffoldErrorPage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('错误')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('页面未找到: ${error.toString()}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(Routes.dashboard),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}