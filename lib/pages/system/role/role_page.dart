import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/role_api.dart';
import '../../../models/system/role.dart';
import '../../../i18n/i18n.dart';
import 'widgets/role_search_form.dart';
import 'widgets/role_action_buttons.dart';
import 'widgets/role_data_table.dart';
import 'dialogs/role_form_dialog.dart';
import 'dialogs/assign_menu_dialog.dart';
import 'dialogs/assign_data_scope_dialog.dart';

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
              SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.deleteFailed), backgroundColor: Colors.red),
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
              SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.deleteFailed), backgroundColor: Colors.red),
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
          RoleSearchForm(
            nameController: _nameController,
            codeController: _codeController,
            selectedStatus: _selectedStatus,
            onStatusChanged: (value) => setState(() => _selectedStatus = value),
            onSearch: _search,
            onReset: _reset,
          ),
          const Divider(height: 1),

          // 工具栏
          RoleActionButtons(
            onAdd: () => showRoleFormDialog(
              context,
              ref: ref,
              onSuccess: _loadRoleList,
            ),
            onDeleteSelected: _deleteSelected,
            hasSelection: _selectedIds.isNotEmpty,
          ),
          const Divider(height: 1),

          // 数据表格
          Expanded(
            child: RoleDataTable(
              roleList: _roleList,
              selectedIds: _selectedIds,
              totalCount: _totalCount,
              currentPage: _currentPage,
              pageSize: _pageSize,
              isLoading: _isLoading,
              error: _error,
              onReload: _loadRoleList,
              onPageSizeChanged: (value) {
                setState(() {
                  _pageSize = value;
                  _currentPage = 1;
                });
                _loadRoleList();
              },
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                _loadRoleList();
              },
              onSelectionChanged: (ids) {
                setState(() => _selectedIds = ids);
              },
              onEdit: (role) => showRoleFormDialog(
                context,
                role: role,
                ref: ref,
                onSuccess: _loadRoleList,
              ),
              onAssignMenu: (role) => _showAssignMenuDialog(role),
              onAssignDataScope: (role) => _showAssignDataScopeDialog(role),
              onDelete: _deleteRole,
            ),
          ),
        ],
      ),
    );
  }

  /// 分配菜单权限弹窗
  void _showAssignMenuDialog(Role role) {
    showDialog(
      context: context,
      builder: (context) => AssignMenuDialog(
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
      builder: (context) => AssignDataScopeDialog(
        role: role,
        ref: ref,
        onSuccess: _loadRoleList,
      ),
    );
  }
}