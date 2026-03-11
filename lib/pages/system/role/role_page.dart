import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../api/system/role_api.dart';
import '../../../api/system/menu_api.dart';
import '../../../api/system/dept_api.dart';
import '../../../api/system/permission_api.dart';
import '../../../models/system/role.dart';
import '../../../models/system/menu.dart';
import '../../../models/system/dept.dart';
import '../../../models/system/permission.dart';
import '../../../i18n/i18n.dart';

/// 角色管理页面
class RolePage extends ConsumerStatefulWidget {
  const RolePage({super.key});

  @override
  ConsumerState<RolePage> createState() => _RolePageState();
}

class _RolePageState extends ConsumerState<RolePage> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  int? _selectedStatus;

  List<Role> _roleList = [];
  Set<int> _selectedIds = {};
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRoleList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadRoleList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final roleApi = ref.read(roleApiProvider);
      final params = RolePageParam(
        pageNum: _currentPage,
        pageSize: _pageSize,
        name: _nameController.text.isNotEmpty ? _nameController.text : null,
        code: _codeController.text.isNotEmpty ? _codeController.text : null,
        status: _selectedStatus,
      );

      final response = await roleApi.getRolePage(params);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _roleList = response.data!.list;
          _totalCount = response.data!.total;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.msg;
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

  void _search() {
    setState(() => _currentPage = 1);
    _loadRoleList();
  }

  void _reset() {
    _nameController.clear();
    _codeController.clear();
    setState(() {
      _selectedStatus = null;
      _currentPage = 1;
    });
    _loadRoleList();
  }

  Future<void> _deleteRole(Role role) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDelete} ${role.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(S.current.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final roleApi = ref.read(roleApiProvider);
        final response = await roleApi.deleteRole(role.id!);
        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
          }
          _loadRoleList();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg ?? S.current.deleteFailed), backgroundColor: Colors.red),
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
  }

  Future<void> _deleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text(S.current.confirmDeleteSelected),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(S.current.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && _selectedIds.isNotEmpty) {
      try {
        final roleApi = ref.read(roleApiProvider);
        final response = await roleApi.deleteRoleList(_selectedIds.toList());
        if (response.isSuccess) {
          setState(() => _selectedIds.clear());
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
          }
          _loadRoleList();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg ?? S.current.deleteFailed), backgroundColor: Colors.red),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(context),
          const Divider(height: 1),

          // 工具栏
          _buildToolbar(context),
          const Divider(height: 1),

          // 数据表格
          Expanded(
            child: _buildDataTable(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 220,
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: S.current.roleName,
                prefixIcon: const Icon(Icons.search, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          SizedBox(
            width: 220,
            child: TextField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: S.current.roleCode,
                prefixIcon: const Icon(Icons.code, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          SizedBox(
            width: 160,
            child: DropdownButtonFormField<int>(
              value: _selectedStatus,
              decoration: InputDecoration(
                hintText: S.current.status,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(S.current.all)),
                DropdownMenuItem(value: 0, child: Text(S.current.enabled)),
                DropdownMenuItem(value: 1, child: Text(S.current.disabled)),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search, size: 20),
            label: Text(S.current.search),
          ),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh, size: 20),
            label: Text(S.current.reset),
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
            onPressed: () => _showRoleDialog(context),
            icon: const Icon(Icons.add),
            label: Text(S.current.addRole),
          ),
          ElevatedButton.icon(
            onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete),
            label: Text(S.current.deleteBatch),
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
            ElevatedButton(onPressed: _loadRoleList, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (_roleList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 表头工具栏
          Row(
            children: [
              Checkbox(
                value: _selectedIds.length == _roleList.length && _roleList.isNotEmpty,
                tristate: true,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedIds = _roleList.where((r) => r.id != null).map((r) => r.id!).toSet();
                    } else {
                      _selectedIds.clear();
                    }
                  });
                },
              ),
              Text(S.current.roleList),
              const Spacer(),
              Text('${S.current.total}: $_totalCount'),
            ],
          ),
          const SizedBox(height: 8),
          // 表格
          Expanded(
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 800,
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
                  label: Text('ID'),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.roleName),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.roleCode),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.sort),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.status),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.createTime),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.operation),
                  size: ColumnSize.L,
                  numeric: true,
                ),
              ],
              rows: _roleList.map((role) {
                final isSelected = role.id != null && _selectedIds.contains(role.id);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    if (role.id != null) {
                      setState(() {
                        if (selected == true) {
                          _selectedIds.add(role.id!);
                        } else {
                          _selectedIds.remove(role.id!);
                        }
                      });
                    }
                  },
                  cells: [
                    DataCell(Text(role.id?.toString() ?? '-')),
                    DataCell(Text(role.name)),
                    DataCell(Text(role.code)),
                    DataCell(Text(role.sort?.toString() ?? '-')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: role.status == 0
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          role.status == 0 ? S.current.enabled : S.current.disabled,
                          style: TextStyle(
                            color: role.status == 0 ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(role.createTime?.toString().substring(0, 19) ?? '-')),
                    DataCell(_buildActionButtons(role)),
                  ],
                );
              }).toList(),
            ),
          ),
          // 分页控件
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text('${S.current.pageSize}: '),
                  DropdownButton<int>(
                    value: _pageSize,
                    items: [10, 20, 50, 100].map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text('$value'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _pageSize = value;
                          _currentPage = 1;
                        });
                        _loadRoleList();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 1
                        ? () {
                            setState(() => _currentPage--);
                            _loadRoleList();
                          }
                        : null,
                  ),
                  Text('$_currentPage / ${(_totalCount / _pageSize).ceil()}'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage * _pageSize < _totalCount
                        ? () {
                            setState(() => _currentPage++);
                            _loadRoleList();
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Role role) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => _showRoleDialog(context, role),
          child: Text(S.current.edit),
        ),
        PopupMenuButton<String>(
          tooltip: S.current.more,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'menu',
              child: Row(
                children: [
                  const Icon(Icons.menu, size: 18),
                  const SizedBox(width: 8),
                  Text(S.current.menuPermission),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'data',
              child: Row(
                children: [
                  const Icon(Icons.data_usage, size: 18),
                  const SizedBox(width: 8),
                  Text(S.current.dataPermission),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(S.current.delete, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'menu':
                _showAssignMenuDialog(role);
                break;
              case 'data':
                _showAssignDataScopeDialog(role);
                break;
              case 'delete':
                _deleteRole(role);
                break;
            }
          },
        ),
      ],
    );
  }

  void _showRoleDialog(BuildContext context, [Role? role]) {
    final nameController = TextEditingController(text: role?.name ?? '');
    final codeController = TextEditingController(text: role?.code ?? '');
    final sortController = TextEditingController(text: role?.sort?.toString() ?? '0');
    int status = role?.status ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(role == null ? S.current.addRole : S.current.editRole),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '${S.current.roleName} *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: '${S.current.roleCode} *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: sortController,
                    decoration: InputDecoration(
                      labelText: S.current.sort,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: status,
                    decoration: InputDecoration(
                      labelText: S.current.status,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 0, child: Text(S.current.enabled)),
                      DropdownMenuItem(value: 1, child: Text(S.current.disabled)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => status = value);
                      }
                    },
                  ),
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
                if (nameController.text.isEmpty || codeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.current.requiredField)),
                  );
                  return;
                }

                Navigator.pop(context);

                final roleData = Role(
                  id: role?.id,
                  name: nameController.text,
                  code: codeController.text,
                  sort: int.tryParse(sortController.text) ?? 0,
                  status: status,
                );

                try {
                  final roleApi = ref.read(roleApiProvider);
                  final response = role == null
                      ? await roleApi.createRole(roleData)
                      : await roleApi.updateRole(roleData);

                  if (response.isSuccess) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.current.saveSuccess)),
                      );
                    }
                    _loadRoleList();
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response.msg ?? S.current.saveFailed), backgroundColor: Colors.red),
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
              },
              child: Text(S.current.confirm),
            ),
          ],
        ),
      ),
    );
  }

  /// 分配菜单权限弹窗
  void _showAssignMenuDialog(Role role) {
    showDialog(
      context: context,
      builder: (context) => _AssignMenuDialog(
        role: role,
        ref: ref,
        onSuccess: _loadRoleList,
      ),
    );
  }

  /// 分配数据权限弹窗
  void _showAssignDataScopeDialog(Role role) {
    showDialog(
      context: context,
      builder: (context) => _AssignDataScopeDialog(
        role: role,
        ref: ref,
        onSuccess: _loadRoleList,
      ),
    );
  }
}

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
class _AssignMenuDialog extends StatefulWidget {
  final Role role;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const _AssignMenuDialog({
    required this.role,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<_AssignMenuDialog> createState() => _AssignMenuDialogState();
}

class _AssignMenuDialogState extends State<_AssignMenuDialog> {
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
            SnackBar(content: Text(response.msg ?? S.current.saveFailed), backgroundColor: Colors.red),
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

/// 扁平化的部门数据，用于展示
class _FlatDeptItem {
  final SimpleDept dept;
  final int level;
  final bool hasChildren;

  const _FlatDeptItem({
    required this.dept,
    required this.level,
    required this.hasChildren,
  });
}

/// 分配数据权限弹窗
class _AssignDataScopeDialog extends StatefulWidget {
  final Role role;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const _AssignDataScopeDialog({
    required this.role,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<_AssignDataScopeDialog> createState() => _AssignDataScopeDialogState();
}

class _AssignDataScopeDialogState extends State<_AssignDataScopeDialog> {
  List<SimpleDept> _deptList = [];
  List<SimpleDept> _deptTree = [];
  Set<int> _selectedDeptIds = {};
  int _dataScope = 1; // 默认全部数据权限
  bool _isLoading = true;
  bool _isAllExpanded = false;

  // 每个节点的展开状态
  final Map<int, bool> _expandedMap = {};

  // 数据权限范围选项
  List<String> get _dataScopeLabels => [
    S.current.dataScopeAll,
    S.current.dataScopeCustom,
    S.current.dataScopeDeptOnly,
    S.current.dataScopeDeptBelow,
    S.current.dataScopeSelfOnly,
  ];

  @override
  void initState() {
    super.initState();
    _dataScope = widget.role.dataScope ?? 1;
    _selectedDeptIds = (widget.role.dataScopeDeptIds ?? []).toSet();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final deptApi = widget.ref.read(deptApiProvider);
      final response = await deptApi.getSimpleDeptList();

      if (response.isSuccess && response.data != null) {
        setState(() {
          _deptList = response.data!;
          _deptTree = _buildDeptTree(_deptList);
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

  /// 构建部门树结构
  List<SimpleDept> _buildDeptTree(List<SimpleDept> allDepts) {
    final rootDepts = allDepts.where((dept) => dept.parentId == null || dept.parentId == 0).toList();

    List<SimpleDept> buildChildren(int parentId) {
      return allDepts
          .where((dept) => dept.parentId == parentId)
          .map((dept) => dept.copyWith(children: buildChildren(dept.id)))
          .toList();
    }

    return rootDepts.map((dept) => dept.copyWith(children: buildChildren(dept.id))).toList();
  }

  /// 将树形数据扁平化为带层级的列表（参考menu_page.dart优化）
  List<_FlatDeptItem> _flattenDeptTree(List<SimpleDept> depts, int level) {
    final result = <_FlatDeptItem>[];
    for (final dept in depts) {
      final hasChildren = dept.children != null && dept.children!.isNotEmpty;
      final isExpanded = _expandedMap[dept.id] ?? false;
      result.add(_FlatDeptItem(dept: dept, level: level, hasChildren: hasChildren));

      if (hasChildren && isExpanded) {
        result.addAll(_flattenDeptTree(dept.children!, level + 1));
      }
    }
    return result;
  }

  /// 切换单个节点展开状态
  void _toggleExpand(int deptId) {
    setState(() {
      _expandedMap[deptId] = !(_expandedMap[deptId] ?? false);
    });
  }

  /// 切换全部展开/折叠
  void _toggleAllExpanded() {
    setState(() {
      _isAllExpanded = !_isAllExpanded;
      for (final dept in _deptList) {
        _expandedMap[dept.id] = _isAllExpanded;
      }
    });
  }

  List<int> _getAllDeptIds() {
    return _deptList.map((d) => d.id).toList();
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedDeptIds.length == _deptList.length) {
        _selectedDeptIds.clear();
      } else {
        _selectedDeptIds = _getAllDeptIds().toSet();
      }
    });
  }

  /// 选择/取消选择部门（含级联处理）
  void _toggleDeptSelection(SimpleDept dept, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedDeptIds.add(dept.id);
        // 添加父部门
        _addParentDeptIds(dept.parentId);
      } else {
        _selectedDeptIds.remove(dept.id);
        // 移除子部门
        _removeChildrenDeptIds(dept.id);
      }
    });
  }

  Future<void> _submit() async {
    try {
      final permissionApi = widget.ref.read(permissionApiProvider);
      final response = await permissionApi.assignRoleDataScope(
        AssignRoleDataScopeReq(
          roleId: widget.role.id!,
          dataScope: _dataScope,
          dataScopeDeptIds: _dataScope == 2 ? _selectedDeptIds.toList() : [],
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
            SnackBar(content: Text(response.msg ?? S.current.saveFailed), backgroundColor: Colors.red),
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
      title: Text(S.current.assignDataPermission),
      content: SizedBox(
        width: 500,
        height: 550,
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
            // 数据权限范围选择
            DropdownButtonFormField<int>(
              value: _dataScope,
              decoration: InputDecoration(
                labelText: S.current.dataScope,
                border: const OutlineInputBorder(),
              ),
              items: List.generate(5, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text(_dataScopeLabels[index]),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _dataScope = value);
                }
              },
            ),
            const SizedBox(height: 16),
            // 部门选择树（仅自定义部门时显示）
            if (_dataScope == 2) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: _toggleSelectAll,
                    icon: Icon(
                      _selectedDeptIds.length == _deptList.length && _deptList.isNotEmpty
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
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildDeptList(),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Text(
                    S.current.customDeptHint,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ],
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

  /// 构建部门列表（扁平化渲染，优化大数据量性能）
  Widget _buildDeptList() {
    final flatDepts = _flattenDeptTree(_deptTree, 0);

    if (flatDepts.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return ListView.builder(
      itemCount: flatDepts.length,
      itemBuilder: (context, index) {
        final item = flatDepts[index];
        final dept = item.dept;
        final level = item.level;
        final hasChildren = item.hasChildren;
        final isSelected = _selectedDeptIds.contains(dept.id);
        final isExpanded = _expandedMap[dept.id] ?? false;

        return InkWell(
          onTap: () => _toggleDeptSelection(dept, !isSelected),
          child: Padding(
            padding: EdgeInsets.only(left: level * 20.0, top: 6, bottom: 6),
            child: Row(
              children: [
                // 展开/折叠按钮
                if (hasChildren)
                  InkWell(
                    onTap: () => _toggleExpand(dept.id),
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
                // 部门名称
                Expanded(child: Text(dept.name)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeChildrenDeptIds(int parentId) {
    final children = _deptList.where((d) => d.parentId == parentId);
    for (final child in children) {
      _selectedDeptIds.remove(child.id);
      _removeChildrenDeptIds(child.id);
    }
  }

  void _addParentDeptIds(int? parentId) {
    if (parentId == null || parentId == 0) return;
    _selectedDeptIds.add(parentId);
    final parent = _deptList.firstWhere(
      (d) => d.id == parentId,
      orElse: () => SimpleDept(id: -1, name: '', parentId: null),
    );
    if (parent.id != -1) {
      _addParentDeptIds(parent.parentId);
    }
  }
}