import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../api/system/tenant_package_api.dart';
import '../../../api/system/menu_api.dart';
import '../../../models/system/tenant_package.dart';
import '../../../models/system/menu.dart';
import '../../../i18n/i18n.dart';

/// 租户套餐管理页面
class TenantPackagePage extends ConsumerStatefulWidget {
  const TenantPackagePage({super.key});

  @override
  ConsumerState<TenantPackagePage> createState() => _TenantPackagePageState();
}

class _TenantPackagePageState extends ConsumerState<TenantPackagePage> {
  // 搜索控制器
  final _nameController = TextEditingController();
  int? _selectedStatus;
  DateTimeRange? _createTimeRange;

  // 数据状态
  List<TenantPackage> _dataList = [];
  List<Menu> _menuList = [];
  Set<int> _selectedIds = {};
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// 加载租户套餐数据
  Future<void> _loadData() async {
    if (_isLoading && _dataList.isNotEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(tenantPackageApiProvider);
      final params = <String, dynamic>{
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_nameController.text.isNotEmpty) 'name': _nameController.text,
        if (_selectedStatus != null) 'status': _selectedStatus,
        if (_createTimeRange != null) ...{
          'createTime': [
            _createTimeRange!.start.millisecondsSinceEpoch,
            _createTimeRange!.end.millisecondsSinceEpoch,
          ],
        },
      };

      final response = await api.getTenantPackagePage(params);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _dataList = response.data!.list;
          _totalCount = response.data!.total;
          _selectedIds.clear();
        });
      } else {
        setState(() => _error = response.msg);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 加载菜单列表
  Future<List<Menu>> _loadMenuList() async {
    if (_menuList.isNotEmpty) return _menuList;

    final api = ref.read(menuApiProvider);
    final response = await api.getMenuList();
    if (response.isSuccess && response.data != null) {
      _menuList = response.data!;
      return _menuList;
    }
    return [];
  }

  /// 重置搜索条件
  void _resetSearch() {
    _nameController.clear();
    setState(() {
      _selectedStatus = null;
      _createTimeRange = null;
      _currentPage = 1;
    });
    _loadData();
  }

  /// 删除单个租户套餐
  Future<void> _deleteTenantPackage(TenantPackage pkg) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除租户套餐 "${pkg.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && pkg.id != null) {
      final api = ref.read(tenantPackageApiProvider);
      final response = await api.deleteTenantPackage(pkg.id!);
      if (mounted) {
        if (response.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除成功')),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: ${response.msg}')),
          );
        }
      }
    }
  }

  /// 批量删除租户套餐
  Future<void> _deleteTenantPackageBatch() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择要删除的租户套餐')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认批量删除'),
        content: Text('确定要删除选中的 ${_selectedIds.length} 个租户套餐吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final api = ref.read(tenantPackageApiProvider);
      final response = await api.deleteTenantPackageList(_selectedIds.toList());
      if (mounted) {
        if (response.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('批量删除成功')),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('批量删除失败: ${response.msg}')),
          );
        }
      }
    }
  }

  /// 显示表单弹窗
  void _showFormDialog([TenantPackage? pkg]) async {
    final isEdit = pkg != null;
    final formKey = GlobalKey<FormState>();

    // 表单控制器
    final nameController = TextEditingController(text: pkg?.name ?? '');
    final remarkController = TextEditingController(text: pkg?.remark ?? '');

    // 表单状态
    int status = pkg?.status ?? 0;
    List<int> selectedMenuIds = pkg?.menuIds ?? [];
    Set<int> expandedMenuIds = {};

    // 加载菜单列表
    final menuList = await _loadMenuList();

    // 构建菜单树
    List<TreeNode> buildTree(List<Menu> menus, int? parentId) {
      return menus
          .where((m) => m.parentId == parentId)
          .map((m) => TreeNode(
                id: m.id!,
                name: m.name,
                children: buildTree(menus, m.id),
              ))
          .toList();
    }

    final menuTree = buildTree(menuList, null);

    // 获取所有菜单ID
    List<int> getAllMenuIds(List<TreeNode> nodes) {
      final ids = <int>[];
      for (final node in nodes) {
        ids.add(node.id);
        ids.addAll(getAllMenuIds(node.children));
      }
      return ids;
    }

    final allMenuIds = getAllMenuIds(menuTree);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(isEdit ? '编辑租户套餐' : '新增租户套餐'),
            content: SizedBox(
              width: 600,
              height: 500,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 套餐名称
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '套餐名称 *',
                        hintText: '请输入套餐名称',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入套餐名称';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 状态
                    DropdownButtonFormField<int>(
                      value: status,
                      decoration: const InputDecoration(
                        labelText: '状态',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('开启')),
                        DropdownMenuItem(value: 1, child: Text('禁用')),
                      ],
                      onChanged: (value) {
                        setDialogState(() => status = value ?? 0);
                      },
                    ),
                    const SizedBox(height: 16),

                    // 备注
                    TextFormField(
                      controller: remarkController,
                      decoration: const InputDecoration(
                        labelText: '备注',
                        hintText: '请输入备注',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // 菜单权限树
                    const Text('菜单权限', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // 菜单树操作按钮
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setDialogState(() {
                              if (selectedMenuIds.length == allMenuIds.length) {
                                selectedMenuIds.clear();
                              } else {
                                selectedMenuIds = List.from(allMenuIds);
                              }
                            });
                          },
                          icon: Icon(
                            selectedMenuIds.length == allMenuIds.length
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: 20,
                          ),
                          label: const Text('全选'),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setDialogState(() {
                              if (expandedMenuIds.length == allMenuIds.length) {
                                expandedMenuIds.clear();
                              } else {
                                expandedMenuIds = Set.from(allMenuIds);
                              }
                            });
                          },
                          icon: Icon(
                            expandedMenuIds.length == allMenuIds.length
                                ? Icons.unfold_less
                                : Icons.unfold_more,
                            size: 20,
                          ),
                          label: Text(
                            expandedMenuIds.length == allMenuIds.length
                                ? '收起全部'
                                : '展开全部',
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '已选择 ${selectedMenuIds.length} 项',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 菜单树
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: menuTree.isEmpty
                            ? const Center(child: Text('暂无菜单数据'))
                            : SingleChildScrollView(
                                child: _buildMenuTree(
                                  menuTree,
                                  selectedMenuIds,
                                  expandedMenuIds,
                                  (menuId, isSelected) {
                                    setDialogState(() {
                                      if (isSelected) {
                                        selectedMenuIds.add(menuId);
                                      } else {
                                        selectedMenuIds.remove(menuId);
                                      }
                                    });
                                  },
                                  (menuId, isExpanded) {
                                    setDialogState(() {
                                      if (isExpanded) {
                                        expandedMenuIds.add(menuId);
                                      } else {
                                        expandedMenuIds.remove(menuId);
                                      }
                                    });
                                  },
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final data = TenantPackage(
                    id: pkg?.id,
                    name: nameController.text.trim(),
                    status: status,
                    remark: remarkController.text.trim().isNotEmpty
                        ? remarkController.text.trim()
                        : null,
                    menuIds: selectedMenuIds.isNotEmpty ? selectedMenuIds : null,
                  );

                  final api = ref.read(tenantPackageApiProvider);
                  final response = isEdit
                      ? await api.updateTenantPackage(data)
                      : await api.createTenantPackage(data);

                  if (mounted) {
                    if (response.isSuccess) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEdit ? '更新成功' : '创建成功')),
                      );
                      _loadData();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('操作失败: ${response.msg}')),
                      );
                    }
                  }
                },
                child: const Text('确定'),
              ),
            ],
          ),
        ),
      );
    }
  }

  /// 构建菜单树
  Widget _buildMenuTree(
    List<TreeNode> nodes,
    List<int> selectedIds,
    Set<int> expandedIds,
    void Function(int, bool) onSelect,
    void Function(int, bool) onExpand,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: nodes.map((node) {
        final isSelected = selectedIds.contains(node.id);
        final isExpanded = expandedIds.contains(node.id);
        final hasChildren = node.children.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => onSelect(node.id, !isSelected),
              child: Padding(
                padding: EdgeInsets.only(
                  left: node.depth * 20.0,
                  top: 4,
                  bottom: 4,
                ),
                child: Row(
                  children: [
                    // 展开/收起图标
                    if (hasChildren)
                      IconButton(
                        icon: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_right,
                          size: 20,
                        ),
                        onPressed: () => onExpand(node.id, !isExpanded),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      )
                    else
                      const SizedBox(width: 24),

                    // 复选框
                    Checkbox(
                      value: isSelected,
                      tristate: true,
                      onChanged: (value) => onSelect(node.id, value == true),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),

                    // 菜单名称
                    Expanded(
                      child: Text(
                        node.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 子节点
            if (hasChildren && isExpanded)
              _buildMenuTree(
                node.children,
                selectedIds,
                expandedIds,
                onSelect,
                onExpand,
              ),
          ],
        );
      }).toList(),
    );
  }

  /// 构建状态标签
  Widget _buildStatusBadge(int? status) {
    final isOpen = status == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isOpen ? '开启' : '禁用',
        style: TextStyle(
          color: isOpen ? Colors.green : Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(s),
          const Divider(height: 1),

          // 工具栏
          _buildToolbar(s),

          // 数据表格
          Expanded(child: _buildDataTable()),
        ],
      ),
    );
  }

  Widget _buildSearchBar(S s) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        children: [
          // 套餐名称
          SizedBox(
            width: 200,
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '套餐名称',
                hintText: '请输入套餐名称',
                prefixIcon: Icon(Icons.search, size: 20),
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onSubmitted: (_) => _loadData(),
            ),
          ),

          // 状态
          SizedBox(
            width: 140,
            child: DropdownButtonFormField<int>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: '状态',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('全部')),
                DropdownMenuItem(value: 0, child: Text('开启')),
                DropdownMenuItem(value: 1, child: Text('禁用')),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
              },
            ),
          ),

          // 创建时间
          SizedBox(
            width: 260,
            child: InkWell(
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDateRange: _createTimeRange,
                );
                if (range != null) {
                  setState(() => _createTimeRange = range);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '创建时间',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  suffixIcon: Icon(Icons.calendar_today, size: 20),
                ),
                child: Text(
                  _createTimeRange != null
                      ? '${_createTimeRange!.start.toString().substring(0, 10)} ~ ${_createTimeRange!.end.toString().substring(0, 10)}'
                      : '请选择时间范围',
                  style: TextStyle(
                    fontSize: 14,
                    color: _createTimeRange != null ? null : Colors.grey,
                  ),
                ),
              ),
            ),
          ),

          // 搜索按钮
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.search, size: 20),
            label: Text(s.search),
          ),

          // 重置按钮
          OutlinedButton.icon(
            onPressed: _resetSearch,
            icon: const Icon(Icons.refresh, size: 20),
            label: Text(s.reset),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(S s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 新增按钮
          ElevatedButton.icon(
            onPressed: () => _showFormDialog(),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('新增套餐'),
          ),
          const SizedBox(width: 12),

          // 批量删除按钮
          OutlinedButton.icon(
            onPressed: _selectedIds.isEmpty ? null : _deleteTenantPackageBatch,
            icon: const Icon(Icons.delete_outline, size: 20),
            label: Text('批量删除 (${_selectedIds.length})'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _selectedIds.isEmpty ? null : Colors.red,
            ),
          ),

          const Spacer(),

          // 刷新按钮
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    if (_isLoading && _dataList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('重试')),
          ],
        ),
      );
    }

    return DataTable2(
      columns: [
        DataColumn2(
          label: Checkbox(
            value: _selectedIds.length == _dataList.length && _dataList.isNotEmpty,
            tristate: true,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedIds = _dataList.where((e) => e.id != null).map((e) => e.id!).toSet();
                } else {
                  _selectedIds.clear();
                }
              });
            },
          ),
          size: ColumnSize.S,
        ),
        const DataColumn2(label: Text('套餐编号'), size: ColumnSize.S),
        const DataColumn2(label: Text('套餐名称')),
        const DataColumn2(label: Text('状态'), size: ColumnSize.S),
        const DataColumn2(label: Text('备注')),
        const DataColumn2(label: Text('创建时间')),
        const DataColumn2(label: Text('操作'), fixedWidth: 120),
      ],
      rows: _dataList.map((pkg) {
        return DataRow2(
          selected: pkg.id != null && _selectedIds.contains(pkg.id),
          onSelectChanged: pkg.id != null
              ? (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedIds.add(pkg.id!);
                    } else {
                      _selectedIds.remove(pkg.id!);
                    }
                  });
                }
              : null,
          cells: [
            DataCell(Checkbox(
              value: pkg.id != null && _selectedIds.contains(pkg.id),
              onChanged: pkg.id != null
                  ? (value) {
                      setState(() {
                        if (value == true) {
                          _selectedIds.add(pkg.id!);
                        } else {
                          _selectedIds.remove(pkg.id!);
                        }
                      });
                    }
                  : null,
            )),
            DataCell(Text(pkg.id?.toString() ?? '-')),
            DataCell(Text(pkg.name)),
            DataCell(_buildStatusBadge(pkg.status)),
            DataCell(
              Tooltip(
                message: pkg.remark ?? '',
                child: SizedBox(
                  width: 200,
                  child: Text(
                    pkg.remark ?? '-',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            DataCell(Text(pkg.createTime ?? '-')),
            DataCell(Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => _showFormDialog(pkg),
                  child: const Text('编辑'),
                ),
                TextButton(
                  onPressed: () => _deleteTenantPackage(pkg),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('删除'),
                ),
              ],
            )),
          ],
        );
      }).toList(),
      empty: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('暂无数据', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

/// 树节点辅助类
class TreeNode {
  final int id;
  final String name;
  final List<TreeNode> children;
  int get depth {
    if (children.isEmpty) return 0;
    return 1 + children.map((c) => c.depth).reduce((a, b) => a > b ? a : b);
  }

  TreeNode({
    required this.id,
    required this.name,
    this.children = const [],
  });
}