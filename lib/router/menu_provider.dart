import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../stores/access_store.dart';

/// 导航项数据模型
class NavigationItem {
  final String id;
  final String label;
  final String path;
  final IconData? icon;
  final IconData? selectedIcon;
  final List<NavigationItem> children;
  final bool isExpanded;

  const NavigationItem({
    required this.id,
    required this.label,
    required this.path,
    this.icon,
    this.selectedIcon,
    this.children = const [],
    this.isExpanded = false,
  });

  /// 是否有子菜单
  bool get hasChildren => children.isNotEmpty;

  /// 复制并修改
  NavigationItem copyWith({
    String? id,
    String? label,
    String? path,
    IconData? icon,
    IconData? selectedIcon,
    List<NavigationItem>? children,
    bool? isExpanded,
  }) {
    return NavigationItem(
      id: id ?? this.id,
      label: label ?? this.label,
      path: path ?? this.path,
      icon: icon ?? this.icon,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

/// 图标映射表
/// 将后端返回的图标名称映射到 Flutter Icons
final Map<String, IconData> _iconMap = {
  // 仪表板
  'dashboard': Icons.dashboard_outlined,
  'dashboard-filled': Icons.dashboard,
  // 用户
  'user': Icons.people_outline,
  'user-filled': Icons.people,
  'people': Icons.people_outline,
  'people-filled': Icons.people,
  // 角色
  'role': Icons.admin_panel_settings_outlined,
  'role-filled': Icons.admin_panel_settings,
  'admin': Icons.admin_panel_settings_outlined,
  'admin-filled': Icons.admin_panel_settings,
  // 菜单
  'menu': Icons.menu_outlined,
  'menu-filled': Icons.menu,
  // 部门
  'dept': Icons.account_tree_outlined,
  'dept-filled': Icons.account_tree,
  'tree': Icons.account_tree_outlined,
  'tree-filled': Icons.account_tree,
  // 字典
  'dict': Icons.book_outlined,
  'dict-filled': Icons.book,
  'book': Icons.book_outlined,
  'book-filled': Icons.book,
  // 通知
  'notify': Icons.notifications_outlined,
  'notify-filled': Icons.notifications,
  'notification': Icons.notifications_outlined,
  'notification-filled': Icons.notifications,
  // 邮件
  'mail': Icons.mail_outlined,
  'mail-filled': Icons.mail,
  'email': Icons.mail_outlined,
  'email-filled': Icons.mail,
  // 短信
  'sms': Icons.sms_outlined,
  'sms-filled': Icons.sms,
  'message': Icons.sms_outlined,
  'message-filled': Icons.sms,
  // 日志
  'log': Icons.description_outlined,
  'log-filled': Icons.description,
  'document': Icons.description_outlined,
  'document-filled': Icons.description,
  // 设置
  'settings': Icons.settings_outlined,
  'settings-filled': Icons.settings,
  // 租户
  'tenant': Icons.business_outlined,
  'tenant-filled': Icons.business,
  // 操作
  'operation': Icons.settings_suggest_outlined,
  'operation-filled': Icons.settings_suggest,
  // 登录日志
  'login': Icons.login_outlined,
  'login-filled': Icons.login,
  // 区域
  'area': Icons.map_outlined,
  'area-filled': Icons.map,
  // 岗位
  'post': Icons.work_outline,
  'post-filled': Icons.work,
  // 公告
  'notice': Icons.campaign_outlined,
  'notice-filled': Icons.campaign,
  // OAuth2
  'oauth': Icons.key_outlined,
  'oauth-filled': Icons.key,
  'key': Icons.key_outlined,
  'key-filled': Icons.key,
  // 社交
  'social': Icons.share_outlined,
  'social-filled': Icons.share,
  // 系统
  'system': Icons.settings_applications_outlined,
  'system-filled': Icons.settings_applications,
  // 工具
  'tool': Icons.build_outlined,
  'tool-filled': Icons.build,
  // 监控
  'monitor': Icons.monitor_heart_outlined,
  'monitor-filled': Icons.monitor_heart,
  // 基础设施
  'infra': Icons.domain_outlined,
  'infra-filled': Icons.domain,
  // 默认图标
  'default': Icons.folder_outlined,
  'default-filled': Icons.folder,
};

/// 获取图标
IconData? _getIcon(String? iconName, {bool selected = false}) {
  if (iconName == null || iconName.isEmpty) return null;

  final key = selected ? '$iconName-filled' : iconName;
  return _iconMap[key] ?? _iconMap[iconName] ?? _iconMap['default'];
}

/// 将 MenuItem 转换为 NavigationItem
NavigationItem _convertMenuItem(MenuItem menu) {
  return NavigationItem(
    id: menu.id,
    label: menu.name,
    path: menu.path,
    icon: _getIcon(menu.icon, selected: false),
    selectedIcon: _getIcon(menu.icon, selected: true),
    children: menu.children.map(_convertMenuItem).toList(),
  );
}

/// 菜单状态
class MenuState {
  final List<NavigationItem> menuItems;
  final Set<String> expandedIds;
  final String? selectedPath;

  const MenuState({
    this.menuItems = const [],
    this.expandedIds = const {},
    this.selectedPath,
  });

  MenuState copyWith({
    List<NavigationItem>? menuItems,
    Set<String>? expandedIds,
    String? selectedPath,
  }) {
    return MenuState(
      menuItems: menuItems ?? this.menuItems,
      expandedIds: expandedIds ?? this.expandedIds,
      selectedPath: selectedPath ?? this.selectedPath,
    );
  }
}

/// 菜单状态管理器
class MenuNotifier extends Notifier<MenuState> {
  @override
  MenuState build() {
    // 监听 accessStore 的变化，自动更新菜单
    final accessState = ref.watch(accessStoreProvider);
    final menuItems = _buildNavigationItems(accessState.menus);

    return MenuState(
      menuItems: menuItems,
      expandedIds: const {},
      selectedPath: null,
    );
  }

  /// 构建导航项列表
  List<NavigationItem> _buildNavigationItems(List<MenuItem> menus) {
    return menus.map(_convertMenuItem).toList();
  }

  /// 切换菜单展开状态
  void toggleExpanded(String id) {
    final newExpandedIds = Set<String>.from(state.expandedIds);
    if (newExpandedIds.contains(id)) {
      newExpandedIds.remove(id);
    } else {
      newExpandedIds.add(id);
    }
    state = state.copyWith(expandedIds: newExpandedIds);
  }

  /// 设置选中的路径
  void setSelectedPath(String path) {
    state = state.copyWith(selectedPath: path);
  }

  /// 根据路径找到并展开父菜单
  void expandPath(String path) {
    final expandedIds = _findParentIds(state.menuItems, path);
    state = state.copyWith(
      expandedIds: {...state.expandedIds, ...expandedIds},
      selectedPath: path,
    );
  }

  /// 查找路径的所有父级 ID
  Set<String> _findParentIds(List<NavigationItem> items, String path, [Set<String>? parentIds]) {
    parentIds ??= {};
    for (final item in items) {
      if (item.path == path) {
        return parentIds;
      }
      if (item.hasChildren) {
        final result = _findParentIds(item.children, path, {...parentIds, item.id});
        if (result.isNotEmpty) {
          return result;
        }
      }
    }
    return {};
  }
}

/// 菜单 Provider
final menuProvider = NotifierProvider<MenuNotifier, MenuState>(
  MenuNotifier.new,
);

/// 扁平化菜单项 Provider
/// 用于简单的单层菜单显示
final flatMenuItemsProvider = Provider<List<NavigationItem>>((ref) {
  final menuState = ref.watch(menuProvider);
  // 过滤出顶级菜单项
  return menuState.menuItems;
});

/// 检查当前路径是否匹配
final isCurrentPathProvider = Provider<bool Function(String path)>((ref) {
  final menuState = ref.watch(menuProvider);
  return (String path) => menuState.selectedPath == path;
});