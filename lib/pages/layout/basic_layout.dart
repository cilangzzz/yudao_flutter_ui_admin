import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../router/router.dart';
import '../../stores/stores.dart';
import '../../api/auth_api.dart';

/// 响应式断点
class Breakpoints {
  Breakpoints._();

  /// sm: 768
  static const double sm = 768;

  /// lg: 1200
  static const double lg = 1200;

  /// 判断是否为移动端
  static bool isMobile(double width) => width < sm;

  /// 判断是否为平板
  static bool isTablet(double width) => width >= sm && width < lg;

  /// 判断是否为桌面端
  static bool isDesktop(double width) => width >= lg;
}

/// 主布局页面
class BasicLayout extends ConsumerStatefulWidget {
  final Widget child;

  const BasicLayout({super.key, required this.child});

  @override
  ConsumerState<BasicLayout> createState() => _BasicLayoutState();
}

class _BasicLayoutState extends ConsumerState<BasicLayout> {
  int _selectedIndex = 0;
  bool _extended = true;

  final List<_NavigationItem> _navigationItems = const [
    _NavigationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: '仪表板',
      path: Routes.dashboard,
    ),
    _NavigationItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: '用户管理',
      path: Routes.user,
    ),
    _NavigationItem(
      icon: Icons.admin_panel_settings_outlined,
      selectedIcon: Icons.admin_panel_settings,
      label: '角色管理',
      path: Routes.role,
    ),
    _NavigationItem(
      icon: Icons.menu_outlined,
      selectedIcon: Icons.menu,
      label: '菜单管理',
      path: Routes.menu,
    ),
    _NavigationItem(
      icon: Icons.account_tree_outlined,
      selectedIcon: Icons.account_tree,
      label: '部门管理',
      path: Routes.dept,
    ),
  ];

  void _handleNavigation(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_navigationItems[index].path);
  }

  void _toggleExtended() {
    setState(() {
      _extended = !_extended;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = ref.watch(userStoreProvider).userInfo;
    final width = MediaQuery.of(context).size.width;
    final isMobile = Breakpoints.isMobile(width);
    final isDesktop = Breakpoints.isDesktop(width);

    // 移动端布局
    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Yudao Admin'),
          actions: _buildActions(userInfo),
        ),
        body: widget.child,
        bottomNavigationBar: _buildBottomNavigation(),
      );
    }

    // 桌面端布局
    return Scaffold(
      body: Row(
        children: [
          // 侧边栏
          _buildNavigationRail(extended: _extended && isDesktop),
          // 主内容区
          Expanded(
            child: Column(
              children: [
                _buildTopAppBar(userInfo, isMobile),
                const Divider(height: 1),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRail({required bool extended}) {
    return NavigationRail(
      extended: extended,
      selectedIndex: _selectedIndex,
      onDestinationSelected: _handleNavigation,
      leading: Column(
        children: [
          const SizedBox(height: 8),
          if (extended)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Yudao Admin',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          IconButton(
            icon: Icon(extended ? Icons.menu_open : Icons.menu),
            onPressed: _toggleExtended,
          ),
        ],
      ),
      destinations: _navigationItems
          .map((item) => NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: Text(item.label),
              ))
          .toList(),
    );
  }

  PreferredSizeWidget _buildTopAppBar(UserInfo? userInfo, bool isMobile) {
    return AppBar(
      title: isMobile ? const Text('Yudao Admin') : null,
      actions: _buildActions(userInfo),
    );
  }

  List<Widget> _buildActions(UserInfo? userInfo) {
    return [
      // 通知
      IconButton(
        icon: const Icon(Icons.notifications_outlined),
        onPressed: () {},
      ),
      // 用户菜单
      PopupMenuButton<String>(
        icon: CircleAvatar(
          radius: 16,
          backgroundImage: userInfo?.avatar != null
              ? NetworkImage(userInfo!.avatar!)
              : null,
          child: userInfo?.avatar == null
              ? Text(userInfo?.nickname.substring(0, 1) ?? 'U')
              : null,
        ),
        offset: const Offset(0, 40),
        onSelected: (value) async {
          switch (value) {
            case 'profile':
              break;
            case 'settings':
              break;
            case 'logout':
              await ref.read(loginProvider.notifier).logout();
              if (mounted) {
                context.go(Routes.login);
              }
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userInfo?.nickname ?? '未登录',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  userInfo?.email ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'profile',
            child: Row(
              children: [
                Icon(Icons.person_outline),
                SizedBox(width: 8),
                Text('个人中心'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.settings_outlined),
                SizedBox(width: 8),
                Text('系统设置'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, color: Colors.red),
                SizedBox(width: 8),
                Text('退出登录', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(width: 8),
    ];
  }

  Widget _buildBottomNavigation() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _handleNavigation,
      destinations: _navigationItems
          .map((item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ))
          .toList(),
    );
  }
}

/// 导航项数据
class _NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String path;

  const _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.path,
  });
}