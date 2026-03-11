import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../api/system/menu_api.dart';
import '../../../models/system/menu.dart';
import '../../../i18n/i18n.dart';

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

/// 菜单管理页面
class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  final _searchController = TextEditingController();

  List<Menu> _menuList = [];
  List<Menu> _menuTree = [];
  Set<int> _selectedIds = {};
  bool _isLoading = true;
  String? _error;
  bool _isExpanded = true;

  // 展开状态记录
  final Map<int, bool> _expandedMap = {};

  @override
  void initState() {
    super.initState();
    _loadMenuList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMenuList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final menuApi = ref.read(menuApiProvider);
      final response = await menuApi.getMenuList();

      if (response.isSuccess && response.data != null) {
        setState(() {
          _menuList = response.data!;
          _menuTree = _buildMenuTree(response.data!);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.msg.isNotEmpty ? response.msg : S.current.loadFailed;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 构建菜单树结构
  List<Menu> _buildMenuTree(List<Menu> allMenus) {
    final rootMenus = allMenus.where((menu) => menu.parentId == null || menu.parentId == 0).toList();

    List<Menu> buildChildren(int parentId) {
      return allMenus
          .where((menu) => menu.parentId == parentId)
          .map((menu) => menu.copyWith(children: buildChildren(menu.id!)))
          .toList();
    }

    return rootMenus.map((menu) => menu.copyWith(children: buildChildren(menu.id!))).toList();
  }

  /// 将树形数据扁平化为带层级的列表
  List<_FlatMenu> _flattenMenuTree(List<Menu> menus, int level) {
    final result = <_FlatMenu>[];
    for (final menu in menus) {
      final hasChildren = menu.children != null && menu.children!.isNotEmpty;
      final isExpanded = _expandedMap[menu.id] ?? true;
      result.add(_FlatMenu(menu: menu, level: level, hasChildren: hasChildren));

      if (hasChildren && isExpanded) {
        result.addAll(_flattenMenuTree(menu.children!, level + 1));
      }
    }
    return result;
  }

  void _toggleExpand(int menuId) {
    setState(() {
      _expandedMap[menuId] = !(_expandedMap[menuId] ?? true);
    });
  }

  void _toggleAll() {
    setState(() {
      _isExpanded = !_isExpanded;
      for (final menu in _menuList) {
        if (menu.id != null) {
          _expandedMap[menu.id!] = _isExpanded;
        }
      }
    });
  }

  void _showMenuDialog([Menu? menu, int? parentId]) {
    final nameController = TextEditingController(text: menu?.name ?? '');
    final pathController = TextEditingController(text: menu?.path ?? '');
    final componentController = TextEditingController(text: menu?.component ?? '');
    final componentNameController = TextEditingController(text: menu?.componentName ?? '');
    final permissionController = TextEditingController(text: menu?.permission ?? '');
    final iconController = TextEditingController(text: menu?.icon ?? '');
    final sortController = TextEditingController(text: (menu?.sort ?? 0).toString());

    int? selectedParentId = menu?.parentId ?? parentId;
    int menuType = menu?.type ?? 1;
    int status = menu?.status ?? 0;
    bool visible = menu?.visible ?? true;
    bool keepAlive = menu?.keepAlive ?? false;
    bool alwaysShow = menu?.alwaysShow ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(menu == null ? S.current.addMenu : S.current.editMenu),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 上级菜单
                  DropdownButtonFormField<int?>(
                    value: selectedParentId,
                    decoration: InputDecoration(
                      labelText: S.current.parentMenu,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(S.current.topMenu),
                      ),
                      ..._buildMenuDropdownItems(_menuTree, 0, menu?.id),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedParentId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // 菜单名称
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '${S.current.menuName} *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 菜单类型
                  Row(
                    children: [
                      Text('${S.current.menuType}: '),
                      Radio<int>(
                        value: 1,
                        groupValue: menuType,
                        onChanged: (value) {
                          setState(() {
                            menuType = value!;
                          });
                        },
                      ),
                      const Text('目录'),
                      Radio<int>(
                        value: 2,
                        groupValue: menuType,
                        onChanged: (value) {
                          setState(() {
                            menuType = value!;
                          });
                        },
                      ),
                      const Text('菜单'),
                      Radio<int>(
                        value: 3,
                        groupValue: menuType,
                        onChanged: (value) {
                          setState(() {
                            menuType = value!;
                          });
                        },
                      ),
                      const Text('按钮'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 路由地址 (目录和菜单显示)
                  if (menuType != 3) ...[
                    TextField(
                      controller: pathController,
                      decoration: InputDecoration(
                        labelText: S.current.routePath,
                        hintText: S.current.routePathHint,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // 组件地址 (菜单显示)
                  if (menuType == 2) ...[
                    TextField(
                      controller: componentController,
                      decoration: InputDecoration(
                        labelText: S.current.componentPath,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: componentNameController,
                      decoration: InputDecoration(
                        labelText: S.current.componentName,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // 权限标识 (菜单和按钮显示)
                  if (menuType != 1) ...[
                    TextField(
                      controller: permissionController,
                      decoration: InputDecoration(
                        labelText: S.current.permission,
                        hintText: S.current.permissionHint,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // 图标 (目录和菜单显示)
                  if (menuType != 3) ...[
                    TextField(
                      controller: iconController,
                      decoration: InputDecoration(
                        labelText: S.current.icon,
                        hintText: S.current.iconHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: iconController.text.isNotEmpty
                            ? Icon(_getIconData(iconController.text))
                            : const Icon(Icons.image),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  // 显示顺序
                  TextField(
                    controller: sortController,
                    decoration: InputDecoration(
                      labelText: '${S.current.sort} *',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // 状态
                  Row(
                    children: [
                      Text('${S.current.status}: '),
                      Radio<int>(
                        value: 0,
                        groupValue: status,
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                      Text(S.current.enabled),
                      Radio<int>(
                        value: 1,
                        groupValue: status,
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                      Text(S.current.disabled),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 显示状态 (目录和菜单显示)
                  if (menuType != 3) ...[
                    Row(
                      children: [
                        Text('${S.current.visible}: '),
                        Radio<bool>(
                          value: true,
                          groupValue: visible,
                          onChanged: (value) {
                            setState(() {
                              visible = value!;
                            });
                          },
                        ),
                        Text(S.current.show),
                        Radio<bool>(
                          value: false,
                          groupValue: visible,
                          onChanged: (value) {
                            setState(() {
                              visible = value!;
                            });
                          },
                        ),
                        Text(S.current.hide),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  // 缓存状态 (菜单显示)
                  if (menuType == 2) ...[
                    Row(
                      children: [
                        Text('${S.current.cache}: '),
                        Radio<bool>(
                          value: true,
                          groupValue: keepAlive,
                          onChanged: (value) {
                            setState(() {
                              keepAlive = value!;
                            });
                          },
                        ),
                        Text(S.current.yes),
                        Radio<bool>(
                          value: false,
                          groupValue: keepAlive,
                          onChanged: (value) {
                            setState(() {
                              keepAlive = value!;
                            });
                          },
                        ),
                        Text(S.current.no),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 总是显示
                    Row(
                      children: [
                        Text('${S.current.alwaysShow}: '),
                        Radio<bool>(
                          value: true,
                          groupValue: alwaysShow,
                          onChanged: (value) {
                            setState(() {
                              alwaysShow = value!;
                            });
                          },
                        ),
                        Text(S.current.yes),
                        Radio<bool>(
                          value: false,
                          groupValue: alwaysShow,
                          onChanged: (value) {
                            setState(() {
                              alwaysShow = value!;
                            });
                          },
                        ),
                        Text(S.current.no),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.current.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.current.pleaseFillRequired)),
                  );
                  return;
                }

                final menuData = Menu(
                  id: menu?.id,
                  name: nameController.text,
                  parentId: selectedParentId,
                  type: menuType,
                  path: pathController.text.isEmpty ? null : pathController.text,
                  component: componentController.text.isEmpty ? null : componentController.text,
                  componentName: componentNameController.text.isEmpty ? null : componentNameController.text,
                  permission: permissionController.text.isEmpty ? null : permissionController.text,
                  icon: iconController.text.isEmpty ? null : iconController.text,
                  sort: int.tryParse(sortController.text) ?? 0,
                  status: status,
                  visible: visible,
                  keepAlive: keepAlive,
                  alwaysShow: alwaysShow,
                );

                try {
                  final menuApi = ref.read(menuApiProvider);
                  final response = menu == null
                      ? await menuApi.createMenu(menuData)
                      : await menuApi.updateMenu(menuData);

                  if (response.isSuccess) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(menu == null ? S.current.addSuccess : S.current.editSuccess)),
                      );
                      _loadMenuList();
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.operationFailed)),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${S.current.operationFailed}: $e')),
                    );
                  }
                }
              },
              child: Text(S.current.confirm),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<int?>> _buildMenuDropdownItems(List<Menu> menus, int level, [int? excludeId]) {
    final items = <DropdownMenuItem<int?>>[];
    for (final menu in menus) {
      if (menu.id == excludeId) continue;

      items.add(DropdownMenuItem(
        value: menu.id,
        child: Padding(
          padding: EdgeInsets.only(left: 16.0 * level),
          child: Row(
            children: [
              if (menu.icon != null && menu.icon!.isNotEmpty)
                Icon(_getIconData(menu.icon), size: 16)
              else
                const Icon(Icons.folder, size: 16),
              const SizedBox(width: 8),
              Text(menu.name),
            ],
          ),
        ),
      ));
      if (menu.children != null && menu.children!.isNotEmpty) {
        items.addAll(_buildMenuDropdownItems(menu.children!, level + 1, excludeId));
      }
    }
    return items;
  }

  IconData _getIconData(String? iconName) {
    if (iconName == null || iconName.isEmpty) return Icons.folder;

    // 常见图标映射
    final iconMap = {
      'settings': Icons.settings,
      'people': Icons.people,
      'admin_panel_settings': Icons.admin_panel_settings,
      'menu': Icons.menu,
      'monitor': Icons.monitor,
      'online_prediction': Icons.online_prediction,
      'history': Icons.history,
      'dashboard': Icons.dashboard,
      'folder': Icons.folder,
      'home': Icons.home,
      'user': Icons.person,
      'role': Icons.admin_panel_settings,
      'dept': Icons.business,
      'post': Icons.work,
      'dict': Icons.book,
      'config': Icons.settings,
      'log': Icons.article,
      'notice': Icons.notifications,
      'file': Icons.insert_drive_file,
      'table': Icons.table_chart,
      'chart': Icons.bar_chart,
      'form': Icons.edit_note,
      'list': Icons.list,
      'tree': Icons.account_tree,
      'search': Icons.search,
      'add': Icons.add,
      'edit': Icons.edit,
      'delete': Icons.delete,
      'refresh': Icons.refresh,
      'export': Icons.download,
      'import': Icons.upload,
    };

    return iconMap[iconName.toLowerCase()] ?? Icons.folder;
  }

  Future<void> _deleteMenu(Menu menu) async {
    // 检查是否有子菜单
    if (menu.children != null && menu.children!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.menuHasChildren)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteMenu} "${menu.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(S.current.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && menu.id != null) {
      try {
        final menuApi = ref.read(menuApiProvider);
        final response = await menuApi.deleteMenu(menu.id!);

        if (response.isSuccess) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadMenuList();
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.deleteFailed)),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${S.current.deleteFailed}: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 工具栏
          _buildToolbar(context),
          const Divider(height: 1),
          // 数据表格
          Expanded(child: _buildDataTable(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMenuDialog(),
        icon: const Icon(Icons.add),
        label: Text(S.current.addMenu),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 搜索框
          SizedBox(
            width: 200,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: S.current.searchMenuName,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _loadMenuList(),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _loadMenuList,
            icon: const Icon(Icons.refresh),
            label: Text(S.current.refresh),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _toggleAll,
            icon: Icon(_isExpanded ? Icons.unfold_less : Icons.unfold_more),
            label: Text(_isExpanded ? S.current.collapseAll : S.current.expandAll),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${S.current.loadFailed}: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadMenuList, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (_menuTree.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    final flatMenus = _flattenMenuTree(_menuTree, 0);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text(S.current.menuList),
              const Spacer(),
              Text('${S.current.total}: ${_menuList.length}'),
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
                final isExpanded = _expandedMap[menu.id] ?? true;
                final level = flatMenu.level;

                return DataRow2(
                  cells: [
                    DataCell(
                      InkWell(
                        onTap: hasChildren ? () => _toggleExpand(menu.id!) : null,
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
                                    : _getIconData(menu.icon),
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
                      Icon(_getIconData(menu.icon), size: 18),
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _showMenuDialog(null, menu.id),
                            child: Text(S.current.addChild),
                          ),
                          TextButton(
                            onPressed: () => _showMenuDialog(menu),
                            child: Text(S.current.edit),
                          ),
                          TextButton(
                            onPressed: () => _deleteMenu(menu),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: Text(S.current.delete),
                          ),
                        ],
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

/// 扁平化的菜单数据，用于展示
class _FlatMenu {
  final Menu menu;
  final int level;
  final bool hasChildren;

  const _FlatMenu({
    required this.menu,
    required this.level,
    required this.hasChildren,
  });
}