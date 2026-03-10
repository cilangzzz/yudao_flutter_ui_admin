import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../api/system/dept_api.dart';
import '../../../api/system/user_api.dart';
import '../../../models/system/dept.dart';
import '../../../models/system/user.dart';
import '../../../i18n/i18n.dart';

/// 部门管理页面
class DeptPage extends ConsumerStatefulWidget {
  const DeptPage({super.key});

  @override
  ConsumerState<DeptPage> createState() => _DeptPageState();
}

class _DeptPageState extends ConsumerState<DeptPage> {
  final _searchController = TextEditingController();

  List<Dept> _deptList = [];
  List<Dept> _deptTree = [];
  List<SimpleUser> _userList = [];
  Set<int> _selectedIds = {};
  bool _isLoading = true;
  String? _error;
  bool _isExpanded = true;

  // 展开状态记录
  final Map<int, bool> _expandedMap = {};

  @override
  void initState() {
    super.initState();
    _loadUserList();
    _loadDeptList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserList() async {
    try {
      final userApi = ref.read(userApiProvider);
      final response = await userApi.getSimpleUserList();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _userList = response.data!;
        });
      }
    } catch (e) {
      debugPrint('加载用户列表失败: $e');
    }
  }

  Future<void> _loadDeptList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final deptApi = ref.read(deptApiProvider);
      final response = await deptApi.getDeptList();

      if (response.isSuccess && response.data != null) {
        setState(() {
          _deptList = response.data!;
          _deptTree = _buildDeptTree(response.data!);
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

  /// 构建部门树结构
  List<Dept> _buildDeptTree(List<Dept> allDepts) {
    final rootDepts = allDepts.where((dept) => dept.parentId == null || dept.parentId == 0).toList();

    List<Dept> buildChildren(int parentId) {
      return allDepts
          .where((dept) => dept.parentId == parentId)
          .map((dept) => dept.copyWith(children: buildChildren(dept.id!)))
          .toList();
    }

    return rootDepts.map((dept) => dept.copyWith(children: buildChildren(dept.id!))).toList();
  }

  /// 将树形数据扁平化为带层级的列表
  List<_FlatDept> _flattenDeptTree(List<Dept> depts, int level) {
    final result = <_FlatDept>[];
    for (final dept in depts) {
      final hasChildren = dept.children != null && dept.children!.isNotEmpty;
      final isExpanded = _expandedMap[dept.id] ?? true;
      result.add(_FlatDept(dept: dept, level: level, hasChildren: hasChildren));

      if (hasChildren && isExpanded) {
        result.addAll(_flattenDeptTree(dept.children!, level + 1));
      }
    }
    return result;
  }

  void _toggleExpand(int deptId) {
    setState(() {
      _expandedMap[deptId] = !(_expandedMap[deptId] ?? true);
    });
  }

  void _toggleAll() {
    setState(() {
      _isExpanded = !_isExpanded;
      for (final dept in _deptList) {
        if (dept.id != null) {
          _expandedMap[dept.id!] = _isExpanded;
        }
      }
    });
  }

  void _showDeptDialog([Dept? dept, int? parentId]) {
    final nameController = TextEditingController(text: dept?.name ?? '');
    final phoneController = TextEditingController(text: dept?.phone ?? '');
    final emailController = TextEditingController(text: dept?.email ?? '');
    final sortController = TextEditingController(text: (dept?.sort ?? 0).toString());
    int? selectedParentId = dept?.parentId ?? parentId;
    int? selectedLeaderUserId = dept?.leaderUserId;
    int status = dept?.status ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(dept == null ? S.current.addDept : S.current.editDept),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 上级部门
                  DropdownButtonFormField<int?>(
                    value: selectedParentId,
                    decoration: InputDecoration(
                      labelText: S.current.parentDept,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(S.current.topDept),
                      ),
                      ..._buildDeptDropdownItems(_deptTree, 0, dept?.id),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedParentId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // 部门名称
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '${S.current.deptName} *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 负责人
                  DropdownButtonFormField<int?>(
                    value: selectedLeaderUserId,
                    decoration: InputDecoration(
                      labelText: S.current.leader,
                      border: const OutlineInputBorder(),
                    ),
                    items: _userList.map((user) => DropdownMenuItem(
                      value: user.id,
                      child: Text(user.nickname),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedLeaderUserId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // 联系电话
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: S.current.phone,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  // 邮箱
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: S.current.email,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
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

                final deptData = Dept(
                  id: dept?.id,
                  name: nameController.text,
                  parentId: selectedParentId,
                  leaderUserId: selectedLeaderUserId,
                  phone: phoneController.text.isEmpty ? null : phoneController.text,
                  email: emailController.text.isEmpty ? null : emailController.text,
                  sort: int.tryParse(sortController.text) ?? 0,
                  status: status,
                );

                try {
                  final deptApi = ref.read(deptApiProvider);
                  final response = dept == null
                      ? await deptApi.createDept(deptData)
                      : await deptApi.updateDept(deptData);

                  if (response.isSuccess) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(dept == null ? S.current.addSuccess : S.current.editSuccess)),
                      );
                      _loadDeptList();
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

  List<DropdownMenuItem<int?>> _buildDeptDropdownItems(List<Dept> depts, int level, [int? excludeId]) {
    final items = <DropdownMenuItem<int?>>[];
    for (final dept in depts) {
      // 排除当前编辑的部门及其子部门
      if (dept.id == excludeId) continue;

      items.add(DropdownMenuItem(
        value: dept.id,
        child: Padding(
          padding: EdgeInsets.only(left: 16.0 * level),
          child: Text(dept.name),
        ),
      ));
      if (dept.children != null && dept.children!.isNotEmpty) {
        items.addAll(_buildDeptDropdownItems(dept.children!, level + 1, excludeId));
      }
    }
    return items;
  }

  Future<void> _deleteDept(Dept dept) async {
    // 检查是否有子部门
    if (dept.children != null && dept.children!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.deptHasChildren)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteDept} "${dept.name}" ?'),
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

    if (confirmed == true && dept.id != null) {
      try {
        final deptApi = ref.read(deptApiProvider);
        final response = await deptApi.deleteDept(dept.id!);

        if (response.isSuccess) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadDeptList();
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

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseSelectData)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteSelected} (${_selectedIds.length})?'),
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

    if (confirmed == true) {
      try {
        final deptApi = ref.read(deptApiProvider);
        final response = await deptApi.deleteDeptList(_selectedIds.toList());

        if (response.isSuccess) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _selectedIds.clear();
            _loadDeptList();
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
        onPressed: () => _showDeptDialog(),
        icon: const Icon(Icons.add),
        label: Text(S.current.addDept),
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
                hintText: S.current.searchDeptName,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _loadDeptList(),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _loadDeptList,
            icon: const Icon(Icons.refresh),
            label: Text(S.current.refresh),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _toggleAll,
            icon: Icon(_isExpanded ? Icons.unfold_less : Icons.unfold_more),
            label: Text(_isExpanded ? S.current.collapseAll : S.current.expandAll),
          ),
          const SizedBox(width: 8),
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
            ElevatedButton(onPressed: _loadDeptList, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (_deptTree.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    final flatDepts = _flattenDeptTree(_deptTree, 0);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: _selectedIds.length == _deptList.length && _deptList.isNotEmpty,
                tristate: true,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedIds = _deptList.where((d) => d.id != null).map((d) => d.id!).toSet();
                    } else {
                      _selectedIds.clear();
                    }
                  });
                },
              ),
              Text(S.current.deptList),
              const Spacer(),
              Text('${S.current.total}: ${_deptList.length}'),
            ],
          ),
          const SizedBox(height: 8),
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
                  label: Text(S.current.deptName),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.leader),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.phone),
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
                  size: ColumnSize.M,
                ),
              ],
              rows: flatDepts.map((flatDept) {
                final dept = flatDept.dept;
                final isSelected = dept.id != null && _selectedIds.contains(dept.id);
                final hasChildren = flatDept.hasChildren;
                final isExpanded = _expandedMap[dept.id] ?? true;
                final level = flatDept.level;

                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    if (dept.id != null) {
                      setState(() {
                        if (selected == true) {
                          _selectedIds.add(dept.id!);
                        } else {
                          _selectedIds.remove(dept.id!);
                        }
                      });
                    }
                  },
                  cells: [
                    DataCell(
                      InkWell(
                        onTap: hasChildren ? () => _toggleExpand(dept.id!) : null,
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
                                hasChildren ? Icons.folder : Icons.folder_open,
                                size: 20,
                                color: hasChildren ? Colors.amber : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(dept.name)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(_userList.firstWhere(
                        (u) => u.id == dept.leaderUserId,
                        orElse: () => SimpleUser(id: -1, nickname: '-', username: '-'),
                      ).nickname),
                    ),
                    DataCell(Text(dept.phone ?? '-')),
                    DataCell(Text(dept.sort?.toString() ?? '0')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: dept.status == 0
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          dept.status == 0 ? S.current.enabled : S.current.disabled,
                          style: TextStyle(
                            color: dept.status == 0 ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(dept.createTime?.toString().substring(0, 19) ?? '-')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _showDeptDialog(null, dept.id),
                            child: Text(S.current.addChild),
                          ),
                          TextButton(
                            onPressed: () => _showDeptDialog(dept),
                            child: Text(S.current.edit),
                          ),
                          TextButton(
                            onPressed: () => _deleteDept(dept),
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

/// 扁平化的部门数据，用于展示
class _FlatDept {
  final Dept dept;
  final int level;
  final bool hasChildren;

  const _FlatDept({
    required this.dept,
    required this.level,
    required this.hasChildren,
  });
}