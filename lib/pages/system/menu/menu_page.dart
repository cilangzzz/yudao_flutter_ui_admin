import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/system/menu_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/menu.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';
import 'package:yudao_flutter_ui_admin/utils/menu_icon_helper.dart';
import 'dialogs/menu_form_dialog.dart';
import 'widgets/menu_search_bar.dart';
import 'widgets/menu_tree_table.dart';

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
  bool _isLoading = true;
  String? _error;
  bool _isExpanded = false; // 默认折叠所有节点，优化大数据量性能

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

  void _toggleExpand(int menuId) {
    setState(() {
      // 默认折叠，切换时取反
      _expandedMap[menuId] = !(_expandedMap[menuId] ?? false);
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
    showMenuFormDialog(
      context: context,
      menu: menu,
      parentId: parentId,
      menuTree: _menuTree,
      onCreate: _createMenu,
      onUpdate: _updateMenu,
    );
  }

  Future<bool> _createMenu(Menu menuData) async {
    try {
      final menuApi = ref.read(menuApiProvider);
      final response = await menuApi.createMenu(menuData);

      if (response.isSuccess) {
        _loadMenuList();
        return true;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.operationFailed)),
          );
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.operationFailed}: $e')),
        );
      }
      return false;
    }
  }

  Future<bool> _updateMenu(Menu menuData) async {
    try {
      final menuApi = ref.read(menuApiProvider);
      final response = await menuApi.updateMenu(menuData);

      if (response.isSuccess) {
        _loadMenuList();
        return true;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.operationFailed)),
          );
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.operationFailed}: $e')),
        );
      }
      return false;
    }
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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadMenuList();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.deleteFailed)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
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
      body: DeviceUIMode.layoutBuilder(
        builder: (context, mode) {
          if (mode == UIMode.mobile) {
            return _buildMobileLayout(context);
          }
          return _buildDesktopLayout(context);
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        // 搜索栏
        MenuSearchBar(
          searchController: _searchController,
          onSearch: _loadMenuList,
          onReset: _loadMenuList,
        ),
        const Divider(height: 1),
        // 工具栏
        _buildToolbar(context),
        const Divider(height: 1),
        // 数据表格
        Expanded(
          child: MenuTreeTable(
            menuTree: _menuTree,
            menuList: _menuList,
            expandedMap: _expandedMap,
            onToggleExpand: _toggleExpand,
            onEdit: (menu) => _showMenuDialog(menu),
            onAddChild: (parentId) => _showMenuDialog(null, parentId),
            onDelete: _deleteMenu,
            isLoading: _isLoading,
            error: _error,
            onRetry: _loadMenuList,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // 移动端搜索栏
        _buildMobileSearchBar(context),
        const Divider(height: 1),
        // 移动端工具栏
        _buildMobileToolbar(context),
        const Divider(height: 1),
        // 移动端列表
        Expanded(child: _buildMobileList(context)),
      ],
    );
  }

  Widget _buildMobileSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: S.current.searchMenuName,
                prefixIcon: const Icon(Icons.search, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _loadMenuList(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _loadMenuList,
            icon: const Icon(Icons.search, size: 20),
            label: Text(S.current.search),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: () => _showMenuDialog(),
            icon: const Icon(Icons.add, size: 20),
            label: Text(S.current.add),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _toggleAll,
            icon: Icon(_isExpanded ? Icons.unfold_less : Icons.unfold_more, size: 20),
            label: Text(_isExpanded ? S.current.collapseAll : S.current.expandAll),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(BuildContext context) {
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

    return RefreshIndicator(
      onRefresh: _loadMenuList,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _menuTree.length,
        itemBuilder: (context, index) {
          return _buildMenuTreeItem(_menuTree[index], 0);
        },
      ),
    );
  }

  Widget _buildMenuTreeItem(Menu menu, int level) {
    final hasChildren = menu.children != null && menu.children!.isNotEmpty;
    final isExpanded = _expandedMap[menu.id] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMenuCard(menu, level, hasChildren, isExpanded),
        if (hasChildren && isExpanded)
          ...menu.children!.map((child) => _buildMenuTreeItem(child, level + 1)),
      ],
    );
  }

  Widget _buildMenuCard(Menu menu, int level, bool hasChildren, bool isExpanded) {
    return Card(
      margin: EdgeInsets.only(bottom: 8, left: level * 16.0),
      child: InkWell(
        onTap: hasChildren ? () => _toggleExpand(menu.id!) : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (hasChildren)
                    Icon(
                      isExpanded ? Icons.expand_more : Icons.chevron_right,
                      size: 20,
                      color: Colors.grey[600],
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
                  Expanded(
                    child: Text(menu.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
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
                      _getMenuTypeLabel(menu.type ?? 1),
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
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _buildInfoChip(Icons.sort, '${S.current.sort}: ${menu.sort ?? 0}'),
                  _buildInfoChip(Icons.route, menu.path ?? '-'),
                  _buildInfoChip(
                    menu.status == 0 ? Icons.check_circle : Icons.cancel,
                    menu.status == 0 ? S.current.enabled : S.current.disabled,
                    color: menu.status == 0 ? Colors.green : Colors.red,
                  ),
                ],
              ),
              const Divider(height: 24),
              Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: () => _showMenuDialog(menu),
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(S.current.edit),
                  ),
                  TextButton.icon(
                    onPressed: () => _showMenuDialog(null, menu.id),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(S.current.addChild),
                  ),
                  TextButton.icon(
                    onPressed: () => _deleteMenu(menu),
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    label: Text(S.current.delete, style: const TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMenuTypeLabel(int type) {
    switch (type) {
      case 1:
        return '目录';
      case 2:
        return '菜单';
      case 3:
        return '按钮';
      default:
        return '目录';
    }
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color ?? Colors.grey[600])),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showMenuDialog(),
            icon: const Icon(Icons.add),
            label: Text(S.current.addMenu),
          ),
          OutlinedButton.icon(
            onPressed: _toggleAll,
            icon: Icon(_isExpanded ? Icons.unfold_less : Icons.unfold_more),
            label: Text(_isExpanded ? S.current.collapseAll : S.current.expandAll),
          ),
        ],
      ),
    );
  }
}