import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yudao_flutter_ui_admin/router/router.dart';
import 'package:yudao_flutter_ui_admin/stores/stores.dart';
import 'package:yudao_flutter_ui_admin/api/core/auth_api.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 主布局页面
class BasicLayout extends ConsumerStatefulWidget {
  final Widget child;

  const BasicLayout({super.key, required this.child});

  @override
  ConsumerState<BasicLayout> createState() => _BasicLayoutState();
}

class _BasicLayoutState extends ConsumerState<BasicLayout> {
  bool _extended = true;
  // 移动端抽屉控制器
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 同步当前路由到菜单状态
    final currentPath = GoRouterState.of(context).matchedLocation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(menuProvider.notifier).expandPath(currentPath);
      // 同步 Tab 状态
      _syncTabWithRoute(currentPath);
    });
  }

  /// 同步路由与 Tab 状态
  void _syncTabWithRoute(String path) {
    final meta = routeMetaMap[path];
    if (meta == null) return;

    final tabNotifier = ref.read(tabProvider.notifier);
    final tabItem = TabItem(
      path: path,
      title: meta.title,
      icon: meta.icon,
      affix: meta.affixTab,
      hideInTab: meta.hideInTab,
    );

    tabNotifier.addTab(tabItem);
  }

  void _handleNavigation(String path) {
    ref.read(menuProvider.notifier).setSelectedPath(path);

    final tabState = ref.read(tabProvider);
    final meta = routeMetaMap[path];

    // 如果 Tab 不存在，添加新 Tab
    if (!tabState.hasPath(path)) {
      if (meta != null) {
        final tabItem = TabItem(
          path: path,
          title: meta.title,
          icon: meta.icon,
          affix: meta.affixTab,
          hideInTab: meta.hideInTab,
        );
        ref.read(tabProvider.notifier).addTab(tabItem);
      }
    } else {
      // Tab 已存在，激活它
      ref.read(tabProvider.notifier).activateTab(path);
    }

    // 始终执行导航，确保 widget.child 更新
    context.go(path);
  }

  void _toggleExtended() {
    setState(() {
      _extended = !_extended;
    });
  }

  /// 响应式侧边栏宽度
  double _getSidebarWidth(bool extended, bool isDesktop) {
    if (!extended || !isDesktop) {
      return 72; // 收起状态或平板模式
    }
    return 256; // 展开状态
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = ref.watch(userStoreProvider).userInfo;
    final menuState = ref.watch(menuProvider);
    final width = MediaQuery.of(context).size.width;
    final isMobile = Breakpoints.isMobile(width);
    final isDesktop = Breakpoints.isDesktop(width);
    final isTablet = !isMobile && !isDesktop;

    // 移动端布局
    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(S.current.appName),
          actions: _buildActions(userInfo, isMobile: true),
        ),
        body: widget.child,
        bottomNavigationBar: _buildBottomNavigation(menuState.menuItems),
        drawer: _buildDrawer(menuState.menuItems),
      );
    }

    // 桌面端/平板端布局
    return Scaffold(
      body: Row(
        children: [
          // 侧边栏
          _buildNavigationRail(
            menuItems: menuState.menuItems,
            expandedIds: menuState.expandedIds,
            extended: _extended && isDesktop,
            isTablet: isTablet,
          ),
          // 主内容区
          Expanded(
            child: Column(
              children: [
                _buildTopAppBar(userInfo, isMobile),
                const Divider(height: 1),
                // Tab 栏
                _buildTabBar(isMobile: isMobile),
                const Divider(height: 1),
                // 主内容区（使用 IndexedStack 保持页面状态）
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建 Tab 栏
  Widget _buildTabBar({bool isMobile = false}) {
    final tabState = ref.watch(tabProvider);
    final visibleTabs = tabState.visibleTabs;

    if (visibleTabs.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 40,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width - 100, // 防止溢出
      ),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: visibleTabs.length,
              itemBuilder: (context, index) {
                final tab = visibleTabs[index];
                final isActive = tab.path == tabState.activePath;
                return _buildTabItem(tab, isActive, isMobile: isMobile);
              },
            ),
          ),
          // Tab 操作按钮
          PopupMenuButton<String>(
            icon: const Icon(Icons.close, size: 18),
            tooltip: '关闭标签',
            onSelected: (value) {
              switch (value) {
                case 'closeOther':
                  if (tabState.activePath != null) {
                    ref.read(tabProvider.notifier).closeOtherTabs(tabState.activePath!);
                  }
                  break;
                case 'closeAll':
                  ref.read(tabProvider.notifier).closeAllTabs();
                  // 导航到第一个固定 Tab
                  final newTabState = ref.read(tabProvider);
                  if (newTabState.activePath != null) {
                    context.go(newTabState.activePath!);
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'closeOther',
                child: Row(
                  children: [
                    const Icon(Icons.tab, size: 18),
                    const SizedBox(width: 8),
                    Text(S.current.closeOtherTabs),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'closeAll',
                child: Row(
                  children: [
                    const Icon(Icons.tab, size: 18),
                    const SizedBox(width: 8),
                    Text(S.current.closeAllTabs),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  /// 构建单个 Tab 项
  Widget _buildTabItem(TabItem tab, bool isActive, {bool isMobile = false}) {
    // 移动端使用更紧凑的Tab宽度
    final minWidth = isMobile ? 80.0 : 100.0;
    final maxWidth = isMobile ? 150.0 : 200.0;
    final horizontalPadding = isMobile ? 12.0 : 16.0;

    return InkWell(
      onTap: () => _onTabTap(tab),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          color: isActive
              ? Theme.of(context).colorScheme.surface
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                tab.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
            ),
            if (!tab.affix) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _onTabClose(tab),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Tab 点击事件
  void _onTabTap(TabItem tab) {
    ref.read(tabProvider.notifier).activateTab(tab.path);
    context.go(tab.path);
  }

  /// Tab 关闭事件
  void _onTabClose(TabItem tab) {
    final tabState = ref.read(tabProvider);
    final wasActive = tabState.activePath == tab.path;

    ref.read(tabProvider.notifier).closeTab(tab.path);

    if (wasActive) {
      // 导航到新的激活 Tab
      final newTabState = ref.read(tabProvider);
      if (newTabState.activePath != null) {
        context.go(newTabState.activePath!);
      }
    }
  }

  /// 构建主内容区
  Widget _buildContent() {
    // 直接返回当前页面，不再使用 IndexedStack 缓存
    // 避免 GlobalKey 冲突问题
    return widget.child;
  }

  /// 构建侧边栏导航
  Widget _buildNavigationRail({
    required List<NavigationItem> menuItems,
    required Set<String> expandedIds,
    required bool extended,
    bool isTablet = false,
  }) {
    // 如果菜单为空，显示加载或空状态
    if (menuItems.isEmpty) {
      return _buildEmptyNavigationRail(extended: extended);
    }

    return _buildScrollableNavigationRail(
      menuItems: menuItems,
      expandedIds: expandedIds,
      extended: extended,
      isTablet: isTablet,
    );
  }

  /// 构建可滚动的侧边栏导航
  Widget _buildScrollableNavigationRail({
    required List<NavigationItem> menuItems,
    required Set<String> expandedIds,
    required bool extended,
    bool isTablet = false,
  }) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final sidebarWidth = _getSidebarWidth(extended, !isTablet);

    return Container(
      width: sidebarWidth,
      constraints: BoxConstraints(
        minWidth: 72,
        maxWidth: 256,
      ),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // 顶部：应用名称和切换按钮
          SizedBox(
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (extended)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      S.current.appName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                IconButton(
                  icon: Icon(extended ? Icons.menu_open : Icons.menu),
                  onPressed: _toggleExtended,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 菜单区域：可滚动
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: menuItems.map((item) {
                  final isSelected = item.path == currentPath ||
                      (item.path != '/' && currentPath.startsWith(item.path));

                  return _buildNavigationItem(
                    item: item,
                    isSelected: isSelected,
                    extended: extended,
                    level: 0,
                    expandedIds: expandedIds,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单个导航项（支持多级）
  Widget _buildNavigationItem({
    required NavigationItem item,
    required bool isSelected,
    required bool extended,
    required int level,
    required Set<String> expandedIds,
  }) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final isExpanded = expandedIds.contains(item.id);
    // 防止缩进溢出
    final maxLevel = extended ? 4 : 0;
    final safeLevel = level.clamp(0, maxLevel);
    final indentWidth = extended ? 16.0 + (safeLevel * 12.0) : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 菜单项
        InkWell(
          onTap: () {
            if (item.hasChildren) {
              ref.read(menuProvider.notifier).toggleExpanded(item.id);
            } else {
              _handleNavigation(item.path);
            }
          },
          child: Container(
            height: 48, // 稍微减小高度，更适合缩放
            padding: EdgeInsets.only(
              left: indentWidth,
              right: 12.0,
            ),
            child: Row(
              mainAxisAlignment:
                  extended ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected
                      ? (item.selectedIcon ?? item.icon ?? Icons.folder_outlined)
                      : (item.icon ?? Icons.folder_outlined),
                  size: 20, // 稍微减小图标大小
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                if (extended) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                  ),
                  if (item.hasChildren)
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                    ),
                ],
              ],
            ),
          ),
        ),
        // 子菜单项
        if (item.hasChildren && isExpanded)
          ...item.children.map((child) {
            final childSelected = child.path == currentPath ||
                (child.path != '/' && currentPath.startsWith(child.path));
            return _buildNavigationItem(
              item: child,
              isSelected: childSelected,
              extended: extended,
              level: level + 1,
              expandedIds: expandedIds,
            );
          }),
      ],
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


  /// 构建移动端抽屉菜单
  Widget _buildDrawer(List<NavigationItem> menuItems) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Center(
                child: Text(
                  S.current.appName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              child: _buildDrawerMenuItems(menuItems),
            ),
          ],
        ),
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
    // 防止缩进溢出
    final safeLevel = level.clamp(0, 4);
    final indentWidth = 16.0 + (safeLevel * 12.0);

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
              left: indentWidth,
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
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 14,
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
      actions: _buildActions(userInfo, isMobile: isMobile),
    );
  }

  List<Widget> _buildActions(UserInfoStore? userInfo, {bool isMobile = false}) {
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
              ? Text(
                  userInfo?.nickname?.isNotEmpty == true
                      ? userInfo!.nickname!.substring(0, 1)
                      : 'U',
                  style: const TextStyle(fontSize: 14),
                )
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userInfo?.nickname ?? S.current.notLoggedIn,
                  style: Theme.of(context).textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                if (userInfo?.email != null)
                  Text(
                    userInfo!.email!,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'profile',
            child: Row(
              children: [
                const Icon(Icons.person_outline, size: 20),
                const SizedBox(width: 8),
                Text(S.current.personalCenter),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                const Icon(Icons.settings_outlined, size: 20),
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
                const Icon(Icons.logout, color: Colors.red, size: 20),
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

    // NavigationBar 要求至少 2 个 destinations
    // 如果菜单项不足 2 个，添加占位符
    final destinations = <NavigationDestination>[];
    for (final item in displayItems) {
      destinations.add(NavigationDestination(
        icon: Icon(item.icon ?? Icons.folder_outlined, size: 24),
        selectedIcon: Icon(item.selectedIcon ?? item.icon ?? Icons.folder, size: 24),
        label: item.label,
      ));
    }
    // 如果 destinations 少于 2 个，添加占位符
    while (destinations.length < 2) {
      destinations.add(NavigationDestination(
        icon: const Icon(Icons.more_horiz),
        label: '',
      ));
    }

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
      destinations: destinations,
    );
  }
}