import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/models/system/menu.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/menu_icon_helper.dart';
import 'menu_action_buttons.dart';

/// 菜单类型枚举
enum MenuType {
  directory(1),
  menu(2),
  button(3);

  const MenuType(this.value);
  final int value;

  String get label {
    switch (this) {
      case MenuType.directory:
        return '目录';
      case MenuType.menu:
        return '菜单';
      case MenuType.button:
        return '按钮';
    }
  }

  static MenuType fromValue(int value) {
    return MenuType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MenuType.directory,
    );
  }
}

/// 扁平化的菜单数据，用于展示
class FlatMenu {
  final Menu menu;
  final int level;
  final bool hasChildren;

  const FlatMenu({
    required this.menu,
    required this.level,
    required this.hasChildren,
  });
}

/// 菜单树形表格组件
class MenuTreeTable extends StatelessWidget {
  /// 菜单树数据
  final List<Menu> menuTree;

  /// 所有菜单列表（用于显示总数）
  final List<Menu> menuList;

  /// 展开状态映射
  final Map<int, bool> expandedMap;

  /// 切换展开状态回调
  final void Function(int menuId) onToggleExpand;

  /// 编辑菜单回调
  final void Function(Menu menu) onEdit;

  /// 添加子菜单回调
  final void Function(int parentId) onAddChild;

  /// 删除菜单回调
  final void Function(Menu menu) onDelete;

  /// 加载中状态
  final bool isLoading;

  /// 错误信息
  final String? error;

  /// 重试回调
  final VoidCallback? onRetry;

  const MenuTreeTable({
    super.key,
    required this.menuTree,
    required this.menuList,
    required this.expandedMap,
    required this.onToggleExpand,
    required this.onEdit,
    required this.onAddChild,
    required this.onDelete,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  /// 将树形数据扁平化为带层级的列表
  List<FlatMenu> _flattenMenuTree(List<Menu> menus, int level) {
    final result = <FlatMenu>[];
    for (final menu in menus) {
      final hasChildren = menu.children != null && menu.children!.isNotEmpty;
      final isExpanded = expandedMap[menu.id] ?? false;
      result.add(FlatMenu(menu: menu, level: level, hasChildren: hasChildren));

      if (hasChildren && isExpanded) {
        result.addAll(_flattenMenuTree(menu.children!, level + 1));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${S.current.loadFailed}: $error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (menuTree.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    final flatMenus = _flattenMenuTree(menuTree, 0);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text(S.current.menuList),
              const Spacer(),
              Text('${S.current.total}: ${menuList.length}'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 900,
              smRatio: 0.75,
              lmRatio: 1.5,
              headingRowColor: WidgetStateProperty.resolveWith(
                (states) => Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              headingTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              columns: [
                DataColumn2(
                  label: Text(S.current.menuName),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.icon),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.menuType),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.sort),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.permission),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.routePath),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.status),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.operation),
                  size: ColumnSize.M,
                ),
              ],
              rows: flatMenus.map((flatMenu) {
                final menu = flatMenu.menu;
                final hasChildren = flatMenu.hasChildren;
                final isExpanded = expandedMap[menu.id] ?? true;
                final level = flatMenu.level;

                return DataRow2(
                  cells: [
                    DataCell(
                      InkWell(
                        onTap: hasChildren ? () => onToggleExpand(menu.id!) : null,
                        child: Padding(
                          padding: EdgeInsets.only(left: level * 24.0),
                          child: Row(
                            children: [
                              if (hasChildren)
                                Icon(
                                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                                  size: 20,
                                )
                              else
                                const SizedBox(width: 20),
                              const SizedBox(width: 4),
                              Icon(
                                menu.type == 3
                                    ? Icons.crop_square
                                    : MenuIconHelper.getIconData(menu.icon),
                                size: 20,
                                color: menu.type == 3 ? Colors.grey : Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(menu.name)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Icon(MenuIconHelper.getIconData(menu.icon), size: 18),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: menu.type == 1
                              ? Colors.blue.withValues(alpha: 0.1)
                              : menu.type == 2
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          MenuType.fromValue(menu.type ?? 1).label,
                          style: TextStyle(
                            color: menu.type == 1
                                ? Colors.blue
                                : menu.type == 2
                                    ? Colors.green
                                    : Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(menu.sort?.toString() ?? '0')),
                    DataCell(Text(menu.permission ?? '-')),
                    DataCell(Text(menu.path ?? '-')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: menu.status == 0
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          menu.status == 0 ? S.current.enabled : S.current.disabled,
                          style: TextStyle(
                            color: menu.status == 0 ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      MenuActionButtons(
                        menu: menu,
                        onEdit: onEdit,
                        onAddChild: onAddChild,
                        onDelete: onDelete,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}