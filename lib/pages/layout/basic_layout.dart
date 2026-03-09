import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../router/router.dart';
import '../../stores/stores.dart';
import '../../api/core/auth_api.dart';
import '../../i18n/i18n.dart';

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
  bool _extended = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 同步当前路由到菜单状态
    final currentPath = GoRouterState.of(context).matchedLocation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(menuProvider.notifier).expandPath(currentPath);
    });
  }

  void _handleNavigation(String path) {
    ref.read(menuProvider.notifier).setSelectedPath(path);
    context.go(path);
  }

  void _toggleExtended() {
    setState(() {
      _extended = !_extended;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = ref.watch(userStoreProvider).userInfo;
    final menuState = ref.watch(menuProvider);
    final width = MediaQuery.of(context).size.width;
    final isMobile = Breakpoints.isMobile(width);
    final isDesktop = Breakpoints.isDesktop(width);

    // 移动端布局
    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text(S.current.appName),
          actions: _buildActions(userInfo),
        ),
        body: widget.child,
        bottomNavigationBar: _buildBottomNavigation(menuState.menuItems),
        drawer: _buildDrawer(menuState.menuItems),
      );
    }

    // 桌面端布局
    return Scaffold(
      body: Row(
        children: [
          // 侧边栏
          _buildNavigationRail(
            menuItems: menuState.menuItems,
            expandedIds: menuState.expandedIds,
            extended: _extended && isDesktop,
          ),
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

  /// 构建侧边栏导航
  Widget _buildNavigationRail({
    required List<NavigationItem> menuItems,
    required Set<String> expandedIds,
    required bool extended,
  }) {
    // 如果菜单为空，显示加载或空状态
    if (menuItems.isEmpty) {
      return _buildEmptyNavigationRail(extended: extended);
    }

    // 构建菜单项列表（支持多级菜单）
    final destinations = _buildMenuDestinations(
      menuItems: menuItems,
      expandedIds: expandedIds,
      extended: extended,
    );

    return NavigationRail(
      extended: extended,
      selectedIndex: null, // 使用自定义选中逻辑
      leading: Column(
        children: [
          const SizedBox(height: 8),
          if (extended)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                S.current.appName,
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
      destinations: destinations,
    );
  }

  /// 构建空的导航栏（用于菜单加载时）
  Widget _buildEmptyNavigationRail({required bool extended}) {
    return NavigationRail(
      extended: extended,
      selectedIndex: null,
      leading: Column(
        children: [
          const SizedBox(height: 8),
          if (extended)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                S.current.appName,
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
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: const Icon(Icons.dashboard),
          label: Text(S.current.dashboard),
        ),
      ],
    );
  }

  /// 构建菜单目标列表
  List<NavigationRailDestination> _buildMenuDestinations({
    required List<NavigationItem> menuItems,
    required Set<String> expandedIds,
    required bool extended,
  }) {
    final currentPath = GoRouterState.of(context).matchedLocation;

    return menuItems.map((item) {
      final isSelected = item.path == currentPath ||
          (item.path != '/' && currentPath.startsWith(item.path));

      return NavigationRailDestination(
        icon: _buildMenuIcon(item, isSelected: isSelected, showExpandIcon: false),
        selectedIcon: _buildMenuIcon(item, isSelected: true, showExpandIcon: false),
        label: Text(item.label),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      );
    }).toList();
  }

  /// 构建菜单图标
  Widget _buildMenuIcon(
    NavigationItem item, {
    required bool isSelected,
    required bool showExpandIcon,
  }) {
    final icon = isSelected
        ? (item.selectedIcon ?? item.icon ?? Icons.folder_outlined)
        : (item.icon ?? Icons.folder_outlined);

    if (showExpandIcon && item.hasChildren) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 4),
          Icon(
            item.isExpanded ? Icons.expand_less : Icons.expand_more,
            size: 16,
          ),
        ],
      );
    }
    return Icon(icon);
  }

  /// 构建移动端抽屉菜单
  Widget _buildDrawer(List<NavigationItem> menuItems) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Center(
              child: Text(
                S.current.appName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: _buildDrawerMenuItems(menuItems),
          ),
        ],
      ),
    );
  }

  /// 构建抽屉菜单项
  Widget _buildDrawerMenuItems(List<NavigationItem> menuItems) {
    final menuState = ref.watch(menuProvider);
    final currentPath = GoRouterState.of(context).matchedLocation;

    return ListView.builder(
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        final isSelected = item.path == currentPath ||
            (item.path != '/' && currentPath.startsWith(item.path));
        final isExpanded = menuState.expandedIds.contains(item.id);

        return _buildDrawerItem(
          item: item,
          isSelected: isSelected,
          isExpanded: isExpanded,
        );
      },
    );
  }

  /// 构建抽屉单个菜单项
  Widget _buildDrawerItem({
    required NavigationItem item,
    required bool isSelected,
    required bool isExpanded,
    int level = 0,
  }) {
    final menuState = ref.read(menuProvider);
    final currentPath = GoRouterState.of(context).matchedLocation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 主菜单项
        InkWell(
          onTap: () {
            if (item.hasChildren) {
              // 有子菜单时切换展开状态
              ref.read(menuProvider.notifier).toggleExpanded(item.id);
            } else {
              // 没有子菜单时导航
              _handleNavigation(item.path);
              Navigator.of(context).pop(); // 关闭抽屉
            }
          },
          child: Container(
            padding: EdgeInsets.only(
              left: 16.0 + (level * 16.0),
              right: 16.0,
              top: 12.0,
              bottom: 12.0,
            ),
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? (item.selectedIcon ?? item.icon ?? Icons.folder_outlined)
                      : (item.icon ?? Icons.folder_outlined),
                  size: 20,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                ),
                if (item.hasChildren)
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        // 子菜单项
        if (item.hasChildren && isExpanded)
          ...item.children.map((child) {
            final childSelected = child.path == currentPath ||
                (child.path != '/' && currentPath.startsWith(child.path));
            return _buildDrawerItem(
              item: child,
              isSelected: childSelected,
              isExpanded: menuState.expandedIds.contains(child.id),
              level: level + 1,
            );
          }),
      ],
    );
  }

  PreferredSizeWidget _buildTopAppBar(UserInfoStore? userInfo, bool isMobile) {
    return AppBar(
      title: isMobile ? Text(S.current.appName) : null,
      actions: _buildActions(userInfo),
    );
  }

  List<Widget> _buildActions(UserInfoStore? userInfo) {
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
              try {
                await ref.read(authApiProvider).logout('');
              } finally {
                await ref.read(accessStoreProvider.notifier).clearAccess();
                await ref.read(userStoreProvider.notifier).clearUser();
              }
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
                  userInfo?.nickname ?? S.current.notLoggedIn,
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
          PopupMenuItem(
            value: 'profile',
            child: Row(
              children: [
                const Icon(Icons.person_outline),
                const SizedBox(width: 8),
                Text(S.current.personalCenter),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                const Icon(Icons.settings_outlined),
                const SizedBox(width: 8),
                Text(S.current.settings),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                const Icon(Icons.logout, color: Colors.red),
                const SizedBox(width: 8),
                Text(S.current.logout, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(width: 8),
    ];
  }

  /// 构建底部导航栏
  Widget _buildBottomNavigation(List<NavigationItem> menuItems) {
    final currentPath = GoRouterState.of(context).matchedLocation;

    // 只显示前5个菜单项
    final displayItems = menuItems.take(5).toList();

    // 找到当前选中的索引
    int selectedIndex = -1;
    for (int i = 0; i < displayItems.length; i++) {
      if (displayItems[i].path == currentPath ||
          (displayItems[i].path != '/' && currentPath.startsWith(displayItems[i].path))) {
        selectedIndex = i;
        break;
      }
    }

    return NavigationBar(
      selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
      onDestinationSelected: (index) {
        if (index < displayItems.length) {
          _handleNavigation(displayItems[index].path);
        }
      },
      destinations: displayItems
          .map((item) => NavigationDestination(
                icon: Icon(item.icon ?? Icons.folder_outlined),
                selectedIcon: Icon(item.selectedIcon ?? item.icon ?? Icons.folder),
                label: item.label,
              ))
          .toList(),
    );
  }
}