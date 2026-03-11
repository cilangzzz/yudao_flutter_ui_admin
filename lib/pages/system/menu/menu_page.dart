import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/menu_api.dart';
import '../../../models/system/menu.dart';
import '../../../i18n/i18n.dart';
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
      body: Column(
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
      ),
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