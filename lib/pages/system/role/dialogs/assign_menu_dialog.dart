import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/system/menu_api.dart';
import 'package:yudao_flutter_ui_admin/api/system/permission_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/role.dart';
import 'package:yudao_flutter_ui_admin/models/system/menu.dart';
import 'package:yudao_flutter_ui_admin/models/system/permission.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 扁平化的菜单数据，用于展示
class _FlatMenuItem {
  final SimpleMenu menu;
  final int level;
  final bool hasChildren;

  const _FlatMenuItem({
    required this.menu,
    required this.level,
    required this.hasChildren,
  });
}

/// 分配菜单权限弹窗
class AssignMenuDialog extends StatefulWidget {
  final Role role;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const AssignMenuDialog({
    super.key,
    required this.role,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<AssignMenuDialog> createState() => _AssignMenuDialogState();
}

class _AssignMenuDialogState extends State<AssignMenuDialog> {
  List<SimpleMenu> _menuList = [];
  List<SimpleMenu> _menuTree = [];
  Set<int> _selectedMenuIds = {};
  bool _isLoading = true;
  bool _isAllExpanded = false;

  // 每个节点的展开状态
  final Map<int, bool> _expandedMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final menuApi = widget.ref.read(menuApiProvider);
      final permissionApi = widget.ref.read(permissionApiProvider);

      // 分别加载菜单列表和角色菜单
      final menuResponse = await menuApi.getSimpleMenusList();
      final menuIdsResponse = await permissionApi.getRoleMenuList(widget.role.id!);

      if (menuResponse.isSuccess && menuResponse.data != null) {
        setState(() {
          _menuList = menuResponse.data!;
          _menuTree = _buildMenuTree(_menuList);
          if (menuIdsResponse.isSuccess && menuIdsResponse.data != null) {
            _selectedMenuIds = menuIdsResponse.data!.toSet();
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 构建菜单树结构
  List<SimpleMenu> _buildMenuTree(List<SimpleMenu> allMenus) {
    final rootMenus = allMenus.where((menu) => menu.parentId == null || menu.parentId == 0).toList();

    List<SimpleMenu> buildChildren(int parentId) {
      return allMenus
          .where((menu) => menu.parentId == parentId)
          .map((menu) => menu.copyWith(children: buildChildren(menu.id)))
          .toList();
    }

    return rootMenus.map((menu) => menu.copyWith(children: buildChildren(menu.id))).toList();
  }

  /// 将树形数据扁平化为带层级的列表（参考menu_page.dart优化）
  List<_FlatMenuItem> _flattenMenuTree(List<SimpleMenu> menus, int level) {
    final result = <_FlatMenuItem>[];
    for (final menu in menus) {
      final hasChildren = menu.children != null && menu.children!.isNotEmpty;
      final isExpanded = _expandedMap[menu.id] ?? false;
      result.add(_FlatMenuItem(menu: menu, level: level, hasChildren: hasChildren));

      if (hasChildren && isExpanded) {
        result.addAll(_flattenMenuTree(menu.children!, level + 1));
      }
    }
    return result;
  }

  /// 切换单个节点展开状态
  void _toggleExpand(int menuId) {
    setState(() {
      _expandedMap[menuId] = !(_expandedMap[menuId] ?? false);
    });
  }

  /// 切换全部展开/折叠
  void _toggleAllExpanded() {
    setState(() {
      _isAllExpanded = !_isAllExpanded;
      for (final menu in _menuList) {
        _expandedMap[menu.id] = _isAllExpanded;
      }
    });
  }

  List<int> _getAllMenuIds() {
    return _menuList.map((m) => m.id).toList();
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedMenuIds.length == _menuList.length) {
        _selectedMenuIds.clear();
      } else {
        _selectedMenuIds = _getAllMenuIds().toSet();
      }
    });
  }

  /// 选择/取消选择菜单（含级联处理）
  void _toggleMenuSelection(SimpleMenu menu, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedMenuIds.add(menu.id);
        // 添加所有子菜单
        _addChildrenMenuIds(menu.id);
        // 添加父菜单
        _addParentMenuIds(menu.parentId);
      } else {
        _selectedMenuIds.remove(menu.id);
        // 移除子菜单
        _removeChildrenMenuIds(menu.id);
      }
    });
  }

  Future<void> _submit() async {
    try {
      final permissionApi = widget.ref.read(permissionApiProvider);
      final response = await permissionApi.assignRoleMenu(
        AssignRoleMenuReq(
          roleId: widget.role.id!,
          menuIds: _selectedMenuIds.toList(),
        ),
      );

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.current.saveSuccess)),
          );
        }
        widget.onSuccess();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.saveFailed), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.current.assignMenuPermission),
      content: SizedBox(
        width: 500,
        height: 500,
        child: Column(
          children: [
            // 角色信息
            Wrap(
              spacing: 24,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${S.current.roleName}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.role.name),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${S.current.roleCode}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.role.code),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            // 工具栏
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  onPressed: _toggleSelectAll,
                  icon: Icon(
                    _selectedMenuIds.length == _menuList.length && _menuList.isNotEmpty
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                  ),
                  label: Text(S.current.selectAll),
                ),
                TextButton.icon(
                  onPressed: _toggleAllExpanded,
                  icon: Icon(_isAllExpanded ? Icons.unfold_less : Icons.unfold_more),
                  label: Text(_isAllExpanded ? S.current.collapseAll : S.current.expandAll),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 菜单树 - 使用ListView.builder优化性能
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildMenuList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.current.cancel),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(S.current.confirm),
        ),
      ],
    );
  }

  /// 构建菜单列表（扁平化渲染，优化大数据量性能）
  Widget _buildMenuList() {
    final flatMenus = _flattenMenuTree(_menuTree, 0);

    if (flatMenus.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return ListView.builder(
      itemCount: flatMenus.length,
      itemBuilder: (context, index) {
        final item = flatMenus[index];
        final menu = item.menu;
        final level = item.level;
        final hasChildren = item.hasChildren;
        final isSelected = _selectedMenuIds.contains(menu.id);
        final isExpanded = _expandedMap[menu.id] ?? false;

        return InkWell(
          onTap: () => _toggleMenuSelection(menu, !isSelected),
          child: Padding(
            padding: EdgeInsets.only(left: level * 20.0, top: 6, bottom: 6),
            child: Row(
              children: [
                // 展开/折叠按钮
                if (hasChildren)
                  InkWell(
                    onTap: () => _toggleExpand(menu.id),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isExpanded ? Icons.expand_more : Icons.chevron_right,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 26),
                // 复选框
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 20,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
                const SizedBox(width: 8),
                // 菜单名称
                Expanded(child: Text(menu.name)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addChildrenMenuIds(int parentId) {
    final children = _menuList.where((m) => m.parentId == parentId);
    for (final child in children) {
      _selectedMenuIds.add(child.id);
      _addChildrenMenuIds(child.id);
    }
  }

  void _removeChildrenMenuIds(int parentId) {
    final children = _menuList.where((m) => m.parentId == parentId);
    for (final child in children) {
      _selectedMenuIds.remove(child.id);
      _removeChildrenMenuIds(child.id);
    }
  }

  void _addParentMenuIds(int? parentId) {
    if (parentId == null || parentId == 0) return;
    _selectedMenuIds.add(parentId);
    final parent = _menuList.firstWhere(
      (m) => m.id == parentId,
      orElse: () => SimpleMenu(id: -1, name: '', parentId: null),
    );
    if (parent.id != -1) {
      _addParentMenuIds(parent.parentId);
    }
  }
}