import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/system/role_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/role.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
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
              const SizedBox(width: 8),
              Expanded(
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
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
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
                  onChanged: (value) => setState(() => _selectedStatus = value),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _search,
                  icon: const Icon(Icons.search, size: 20),
                  label: Text(S.current.search),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: Text(S.current.reset),
                ),
              ),
            ],
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
            onPressed: () => showRoleFormDialog(
              context,
              ref: ref,
              onSuccess: _loadRoleList,
            ),
            icon: const Icon(Icons.add, size: 20),
            label: Text(S.current.add),
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
            ElevatedButton(onPressed: _loadRoleList, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (_roleList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadRoleList,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _roleList.length,
              itemBuilder: (context, index) {
                final role = _roleList[index];
                return _buildRoleCard(role);
              },
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${S.current.total}: $_totalCount'),
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
        ),
      ],
    );
  }

  Widget _buildRoleCard(Role role) {
    final isSelected = role.id != null && _selectedIds.contains(role.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (role.id != null) {
            setState(() {
              if (isSelected) {
                _selectedIds.remove(role.id!);
              } else {
                _selectedIds.add(role.id!);
              }
            });
          }
        },
        onLongPress: () => showRoleFormDialog(
          context,
          role: role,
          ref: ref,
          onSuccess: _loadRoleList,
        ),
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
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(role.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('@${role.code}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
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
                ],
              ),
              const Divider(height: 24),
              _buildInfoRow(Icons.sort, S.current.sort, role.sort?.toString() ?? '0'),
              _buildInfoRow(Icons.access_time, S.current.createTime, role.createTime?.toString().substring(0, 19) ?? '-'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: () => showRoleFormDialog(
                      context,
                      role: role,
                      ref: ref,
                      onSuccess: _loadRoleList,
                    ),
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(S.current.edit),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAssignMenuDialog(role),
                    icon: const Icon(Icons.menu, size: 18),
                    label: Text(S.current.menuPermission),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAssignDataScopeDialog(role),
                    icon: const Icon(Icons.data_usage, size: 18),
                    label: Text(S.current.dataPermission),
                  ),
                  TextButton.icon(
                    onPressed: () => _deleteRole(role),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
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