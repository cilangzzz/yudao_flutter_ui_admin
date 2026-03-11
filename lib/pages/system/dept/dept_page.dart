import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/dept_api.dart';
import '../../../api/system/user_api.dart';
import '../../../models/system/dept.dart';
import '../../../models/system/user.dart';
import '../../../i18n/i18n.dart';
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
      body: Column(
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
      ),
    );
  }
}