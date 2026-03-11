import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tab 项数据模型
class TabItem {
  final String path;
  final String title;
  final String? icon;
  final bool affix;
  final bool hideInTab;

  const TabItem({
    required this.path,
    required this.title,
    this.icon,
    this.affix = false,
    this.hideInTab = false,
  });

  TabItem copyWith({
    String? path,
    String? title,
    String? icon,
    bool? affix,
    bool? hideInTab,
  }) {
    return TabItem(
      path: path ?? this.path,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      affix: affix ?? this.affix,
      hideInTab: hideInTab ?? this.hideInTab,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabItem &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}

/// Tab 状态
class TabState {
  final List<TabItem> tabs;
  final String? activePath;

  const TabState({
    this.tabs = const [],
    this.activePath,
  });

  /// 获取可见的 Tab（排除 hideInTab）
  List<TabItem> get visibleTabs => tabs.where((t) => !t.hideInTab).toList();

  /// 获取当前激活的 Tab
  TabItem? get activeTab {
    if (activePath == null) return null;
    try {
      return tabs.firstWhere((t) => t.path == activePath);
    } catch (_) {
      return null;
    }
  }

  /// 检查路径是否已打开
  bool hasPath(String path) => tabs.any((t) => t.path == path);

  TabState copyWith({
    List<TabItem>? tabs,
    String? activePath,
    bool clearActivePath = false,
  }) {
    return TabState(
      tabs: tabs ?? this.tabs,
      activePath:
          clearActivePath ? null : (activePath ?? this.activePath),
    );
  }

  /// 转换为 JSON 列表（用于持久化）
  List<Map<String, dynamic>> toJsonList() {
    return tabs
        .map((t) => {
              'path': t.path,
              'title': t.title,
              'icon': t.icon,
              'affix': t.affix,
              'hideInTab': t.hideInTab,
            })
        .toList();
  }

  /// 从 JSON 列表创建 TabState
  static TabState fromJsonList(List<dynamic> jsonList, String? activePath) {
    final tabs = jsonList.map((json) {
      final map = json as Map<String, dynamic>;
      return TabItem(
        path: map['path'] as String,
        title: map['title'] as String,
        icon: map['icon'] as String?,
        affix: map['affix'] as bool? ?? false,
        hideInTab: map['hideInTab'] as bool? ?? false,
      );
    }).toList();
    return TabState(tabs: tabs, activePath: activePath);
  }
}

/// Tab 状态管理器
class TabNotifier extends Notifier<TabState> {
  @override
  TabState build() {
    // 初始化时带有固定的仪表板 Tab
    return const TabState(
      tabs: [
        TabItem(
          path: '/',
          title: '仪表板',
          icon: 'lucide:layout-dashboard',
          affix: true,
        ),
      ],
      activePath: '/',
    );
  }

  /// 添加或激活 Tab
  void addTab(TabItem tab) {
    final existingIndex = state.tabs.indexWhere((t) => t.path == tab.path);

    if (existingIndex >= 0) {
      // Tab 已存在，仅激活它
      state = state.copyWith(activePath: tab.path);
    } else {
      // 添加新 Tab
      state = state.copyWith(
        tabs: [...state.tabs, tab],
        activePath: tab.path,
      );
    }
  }

  /// 关闭 Tab
  void closeTab(String path) {
    final tabIndex = state.tabs.indexWhere((t) => t.path == path);
    if (tabIndex < 0) return;

    final tab = state.tabs[tabIndex];
    if (tab.affix) return; // 固定 Tab 不能关闭

    final newTabs = state.tabs.where((t) => t.path != path).toList();

    // 如果关闭的是当前激活的 Tab，激活前一个或后一个 Tab
    String? newActivePath = state.activePath;
    if (state.activePath == path) {
      if (newTabs.isNotEmpty) {
        final newIndex = tabIndex.clamp(0, newTabs.length - 1);
        newActivePath = newTabs[newIndex].path;
      } else {
        newActivePath = null;
      }
    }

    state = state.copyWith(
      tabs: newTabs,
      activePath: newActivePath,
    );
  }

  /// 关闭其他 Tab（保留当前和固定的）
  void closeOtherTabs(String currentPath) {
    final newTabs =
        state.tabs.where((t) => t.path == currentPath || t.affix).toList();

    state = state.copyWith(
      tabs: newTabs,
      activePath: currentPath,
    );
  }

  /// 关闭所有非固定 Tab
  void closeAllTabs() {
    final newTabs = state.tabs.where((t) => t.affix).toList();

    state = state.copyWith(
      tabs: newTabs,
      activePath: newTabs.isNotEmpty ? newTabs.first.path : null,
    );
  }

  /// 激活指定 Tab
  void activateTab(String path) {
    if (state.hasPath(path)) {
      state = state.copyWith(activePath: path);
    }
  }

  /// 更新 Tab 标题
  void updateTabTitle(String path, String title) {
    final newTabs = state.tabs.map((t) {
      if (t.path == path) {
        return t.copyWith(title: title);
      }
      return t;
    }).toList();

    state = state.copyWith(tabs: newTabs);
  }

  /// 从持久化数据恢复状态
  void restoreFromJson(List<dynamic>? jsonList, String? activePath) {
    if (jsonList == null || jsonList.isEmpty) return;

    final restoredState = TabState.fromJsonList(jsonList, activePath);
    state = restoredState;
  }
}

/// Tab Provider
final tabProvider = NotifierProvider<TabNotifier, TabState>(
  TabNotifier.new,
);