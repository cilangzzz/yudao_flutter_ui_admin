import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/system/dept_api.dart';
import 'package:yudao_flutter_ui_admin/api/system/user_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/dept.dart';
import 'package:yudao_flutter_ui_admin/models/system/user.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';
import 'widgets/dept_search_form.dart';
import 'widgets/dept_action_buttons.dart';
import 'widgets/dept_tree_table.dart';
import 'dialogs/dept_form_dialog.dart';

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
  bool _isExpanded = false; // 默认折叠所有节点，优化大数据量性能

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

  void _toggleExpand(int deptId) {
    setState(() {
      // 默认折叠，切换时取反
      _expandedMap[deptId] = !(_expandedMap[deptId] ?? false);
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
    showDeptFormDialog(
      context,
      dept: dept,
      parentId: parentId,
      ref: ref,
      deptTree: _deptTree,
      userList: _userList,
      onSuccess: _loadDeptList,
    );
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
        DeptSearchForm(
          searchController: _searchController,
          onSearch: _loadDeptList,
          onReset: _loadDeptList,
        ),
        const Divider(height: 1),
        // 工具栏
        DeptToolbarButtons(
          onAdd: () => _showDeptDialog(),
          onToggleExpand: _toggleAll,
          onDeleteSelected: _deleteSelected,
          isExpanded: _isExpanded,
          hasSelection: _selectedIds.isNotEmpty,
        ),
        const Divider(height: 1),
        // 数据表格
        Expanded(
          child: DeptTreeTable(
            deptList: _deptList,
            deptTree: _deptTree,
            userList: _userList,
            selectedIds: _selectedIds,
            expandedMap: _expandedMap,
            isLoading: _isLoading,
            error: _error,
            onReload: _loadDeptList,
            onToggleExpand: _toggleExpand,
            onSelectionChanged: (ids) {
              setState(() {
                _selectedIds = ids;
              });
            },
            onEdit: (dept) => _showDeptDialog(dept),
            onAddChild: (dept, parentId) => _showDeptDialog(null, parentId),
            onDelete: _deleteDept,
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
                hintText: S.current.searchDeptName,
                prefixIcon: const Icon(Icons.search, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _loadDeptList(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _loadDeptList,
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
            onPressed: () => _showDeptDialog(),
            icon: const Icon(Icons.add, size: 20),
            label: Text(S.current.add),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _toggleAll,
            icon: Icon(_isExpanded ? Icons.unfold_less : Icons.unfold_more, size: 20),
            label: Text(_isExpanded ? S.current.collapseAll : S.current.expandAll),
          ),
          const Spacer(),
          IconButton(
            onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
            icon: const Icon(Icons.delete),
            color: Colors.red,
            tooltip: S.current.deleteBatch,
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
            ElevatedButton(onPressed: _loadDeptList, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (_deptTree.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return RefreshIndicator(
      onRefresh: _loadDeptList,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _deptTree.length,
        itemBuilder: (context, index) {
          return _buildDeptTreeItem(_deptTree[index], 0);
        },
      ),
    );
  }

  Widget _buildDeptTreeItem(Dept dept, int level) {
    final hasChildren = dept.children != null && dept.children!.isNotEmpty;
    final isExpanded = _expandedMap[dept.id] ?? false;
    final isSelected = dept.id != null && _selectedIds.contains(dept.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDeptCard(dept, level, hasChildren, isExpanded, isSelected),
        if (hasChildren && isExpanded)
          ...dept.children!.map((child) => _buildDeptTreeItem(child, level + 1)),
      ],
    );
  }

  Widget _buildDeptCard(Dept dept, int level, bool hasChildren, bool isExpanded, bool isSelected) {
    final leader = _userList.firstWhere(
      (u) => u.id == dept.leaderUserId,
      orElse: () => SimpleUser(id: -1, nickname: '-', username: '-'),
    );

    return Card(
      margin: EdgeInsets.only(bottom: 8, left: level * 16.0),
      child: InkWell(
        onTap: hasChildren ? () => _toggleExpand(dept.id!) : null,
        onLongPress: () {
          if (dept.id != null) {
            setState(() {
              if (isSelected) {
                _selectedIds.remove(dept.id!);
              } else {
                _selectedIds.add(dept.id!);
              }
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (selected) {
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
                  ),
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
                    hasChildren ? Icons.folder : Icons.folder_open,
                    size: 20,
                    color: hasChildren ? Colors.amber : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(dept.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
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
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _buildInfoChip(Icons.person, '${S.current.leader}: ${leader.nickname}'),
                  _buildInfoChip(Icons.phone, dept.phone ?? '-'),
                  _buildInfoChip(Icons.sort, '${S.current.sort}: ${dept.sort ?? 0}'),
                ],
              ),
              const Divider(height: 24),
              Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: () => _showDeptDialog(dept),
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(S.current.edit),
                  ),
                  TextButton.icon(
                    onPressed: () => _showDeptDialog(null, dept.id),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(S.current.addChild),
                  ),
                  TextButton.icon(
                    onPressed: () => _deleteDept(dept),
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

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}