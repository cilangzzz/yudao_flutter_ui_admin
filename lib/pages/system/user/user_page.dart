import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../api/system/user_api.dart';
import '../../../api/system/dept_api.dart';
import '../../../api/system/role_api.dart';
import '../../../api/system/post_api.dart';
import '../../../core/api_client.dart';
import '../../../models/system/user.dart';
import '../../../models/system/dept.dart';
import '../../../models/system/role.dart';
import '../../../models/system/post.dart';
import '../../../models/common/api_response.dart';
import '../../../i18n/i18n.dart';
import '../../../router/route_registry.dart';

// 导入提取的组件
import 'widgets/dept_tree_widget.dart';
import 'widgets/user_data_table.dart';
import 'dialogs/user_edit_dialog.dart';
import 'dialogs/reset_password_dialog.dart';
import 'dialogs/assign_role_dialog.dart';

/// 用户管理页面
class UserPage extends ConsumerStatefulWidget {
  const UserPage({super.key});

  @override
  ConsumerState<UserPage> createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage> {
  final _searchController = TextEditingController();
  final _mobileController = TextEditingController();
  DateTimeRange? _createTimeRange;
  int? _selectedDeptId;

  List<User> _userList = [];
  List<Dept> _deptTree = [];
  List<Role> _roleList = [];
  List<Post> _postList = [];
  Set<int> _selectedIds = {};
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

  // 部门树展开状态管理
  final Map<int, bool> _deptExpandedMap = {};

  @override
  void initState() {
    super.initState();
    _loadDeptTree();
    _loadRoleList();
    _loadPostList();
    _loadUserList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _loadDeptTree() async {
    try {
      final deptApi = ref.read(deptApiProvider);
      final response = await deptApi.getDeptList();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _deptTree = _buildDeptTree(response.data!);
        });
      }
    } catch (e) {
      debugPrint('加载部门树失败: $e');
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

  Future<void> _loadRoleList() async {
    try {
      final roleApi = ref.read(roleApiProvider);
      final response = await roleApi.getSimpleRoleList();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _roleList = response.data!;
        });
      }
    } catch (e) {
      // 角色列表加载失败不影响用户列表
    }
  }

  Future<void> _loadPostList() async {
    try {
      final postApi = ref.read(postApiProvider);
      final response = await postApi.getSimplePostList();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _postList = response.data!;
        });
      }
    } catch (e) {
      // 岗位列表加载失败不影响用户列表
    }
  }

  Future<void> _loadUserList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userApi = ref.read(userApiProvider);
      final params = UserPageParam(
        pageNum: _currentPage,
        pageSize: _pageSize,
        username: _searchController.text.isNotEmpty ? _searchController.text : null,
        mobile: _mobileController.text.isNotEmpty ? _mobileController.text : null,
        deptId: _selectedDeptId,
        createTime: _createTimeRange?.start,
        createTimeEnd: _createTimeRange?.end,
      );

      final response = await userApi.getUserPage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _userList = response.data!.list;
          _totalCount = response.data!.total;
          _isLoading = false;
          _selectedIds.clear();
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

  void _search() {
    _currentPage = 1;
    _loadUserList();
  }

  void _reset() {
    _searchController.clear();
    _mobileController.clear();
    setState(() {
      _createTimeRange = null;
      _selectedDeptId = null;
    });
    _currentPage = 1;
    _loadUserList();
  }

  void _handleDeptSelect(Dept dept) {
    setState(() {
      _selectedDeptId = dept.id;
    });
    _currentPage = 1;
    _loadUserList();
  }

  void _toggleDeptExpand(int deptId) {
    setState(() {
      _deptExpandedMap[deptId] = !(_deptExpandedMap[deptId] ?? false);
    });
  }

  Future<void> _exportUsers() async {
    try {
      final dio = ref.read(dioProvider);
      final params = <String, dynamic>{};
      if (_searchController.text.isNotEmpty) {
        params['username'] = _searchController.text;
      }
      if (_mobileController.text.isNotEmpty) {
        params['mobile'] = _mobileController.text;
      }
      if (_selectedDeptId != null) {
        params['deptId'] = _selectedDeptId;
      }

      await dio.get<List<int>>(
        '/system/user/export-excel',
        queryParameters: params,
        options: Options(responseType: ResponseType.bytes),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.exportSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.exportFailed}: $e')),
        );
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
        final userApi = ref.read(userApiProvider);
        final response = await userApi.deleteUserList(_selectedIds.toList());

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadUserList();
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

  void _showUserDialog([User? user]) {
    showUserEditDialog(
      context: context,
      user: user,
      deptTree: _deptTree,
      postList: _postList,
      defaultDeptId: _selectedDeptId,
      ref: ref,
      onSuccess: _loadUserList,
    );
  }

  void _editUser(User user) {
    _showUserDialog(user);
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteUser} "${user.nickname}" ?'),
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
        final userApi = ref.read(userApiProvider);
        final response = await userApi.deleteUser(user.id!);

        if (response.isSuccess) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadUserList();
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

  Future<void> _updateStatus(User user) async {
    final newStatus = user.status == 0 ? 1 : 0;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirm),
        content: Text(newStatus == 0 ? S.current.confirmEnableUser : S.current.confirmDisableUser),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.current.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final userApi = ref.read(userApiProvider);
        final response = await userApi.updateUserStatus(user.id!, newStatus);

        if (response.isSuccess) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.operationSuccess)),
            );
            _loadUserList();
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
    }
  }

  void _showResetPasswordDialog(User user) {
    showResetPasswordDialog(
      context: context,
      user: user,
      ref: ref,
      onSuccess: () {}, // 重置密码成功后无需刷新列表
    );
  }

  void _showAssignRoleDialog(User user) {
    showAssignRoleDialog(
      context: context,
      user: user,
      roleList: _roleList,
      ref: ref,
      onSuccess: () {}, // 分配角色成功后无需刷新列表
    );
  }

  void _handleSelectChanged(int userId, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(userId);
      } else {
        _selectedIds.remove(userId);
      }
    });
  }

  void _handleSelectAll(bool selectAll) {
    setState(() {
      if (selectAll) {
        _selectedIds = _userList.where((u) => u.id != null).map((u) => u.id!).toSet();
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _handlePageSizeChanged(int newPageSize) {
    setState(() {
      _pageSize = newPageSize;
      _currentPage = 1;
    });
    _loadUserList();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      body: isMobile
          ? _buildMobileLayout(context)
          : _buildDesktopLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // 左侧部门树
        SizedBox(
          width: 220,
          child: Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    S.current.department,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _deptTree.isEmpty
                      ? Center(child: Text(S.current.noData, style: TextStyle(color: Colors.grey[500])))
                      : DeptTreeWidget(
                          depts: _deptTree,
                          selectedDeptId: _selectedDeptId,
                          expandedMap: _deptExpandedMap,
                          onDeptSelect: _handleDeptSelect,
                          onToggleExpand: _toggleDeptExpand,
                        ),
                ),
              ],
            ),
          ),
        ),
        // 右侧用户列表
        Expanded(
          child: Column(
            children: [
              // 搜索栏
              _buildDesktopSearchBar(context),
              const Divider(height: 1),
              // 工具栏
              _buildToolbar(context),
              const Divider(height: 1),
              // 数据表格
              Expanded(
                child: UserDataTable(
                  userList: _userList,
                  selectedIds: _selectedIds,
                  totalCount: _totalCount,
                  currentPage: _currentPage,
                  pageSize: _pageSize,
                  isLoading: _isLoading,
                  error: _error,
                  onSelectChanged: _handleSelectChanged,
                  onSelectAll: _handleSelectAll,
                  onEdit: _editUser,
                  onDelete: _deleteUser,
                  onResetPassword: _showResetPasswordDialog,
                  onAssignRole: _showAssignRoleDialog,
                  onUpdateStatus: _updateStatus,
                  onRetry: _loadUserList,
                  onPageSizeChanged: _handlePageSizeChanged,
                  onPreviousPage: () {
                    setState(() => _currentPage--);
                    _loadUserList();
                  },
                  onNextPage: () {
                    setState(() => _currentPage++);
                    _loadUserList();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildMobileSearchBar(context),
        const Divider(height: 1),
        // 移动端工具栏
        _buildMobileToolbar(context),
        const Divider(height: 1),
        Expanded(child: _buildMobileList(context)),
      ],
    );
  }

  Widget _buildMobileToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: () => _showUserDialog(),
            icon: const Icon(Icons.add, size: 20),
            label: Text(S.current.addUser),
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

  Widget _buildDesktopSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: S.current.username,
                prefixIcon: const Icon(Icons.search, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          SizedBox(
            width: 180,
            child: TextField(
              controller: _mobileController,
              decoration: InputDecoration(
                hintText: S.current.mobile,
                prefixIcon: const Icon(Icons.phone, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          // 创建时间范围选择
          InkWell(
            onTap: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                initialDateRange: _createTimeRange,
              );
              if (range != null) {
                setState(() {
                  _createTimeRange = range;
                });
              }
            },
            child: Container(
              width: 240,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.date_range, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _createTimeRange != null
                        ? '${_formatDate(_createTimeRange!.start)} - ${_formatDate(_createTimeRange!.end)}'
                        : S.current.createTime,
                    style: TextStyle(
                      color: _createTimeRange != null ? null : Colors.grey[600],
                    ),
                  ),
                ],
              ),
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

  Widget _buildMobileSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: S.current.username,
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
                  controller: _mobileController,
                  decoration: InputDecoration(
                    hintText: S.current.mobile,
                    prefixIcon: const Icon(Icons.phone, size: 20),
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

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showUserDialog(),
            icon: const Icon(Icons.add),
            label: Text(S.current.addUser),
          ),
          ElevatedButton.icon(
            onPressed: _exportUsers,
            icon: const Icon(Icons.download),
            label: Text(S.current.export),
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
            ElevatedButton(onPressed: _loadUserList, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (_userList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadUserList,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _userList.length,
              itemBuilder: (context, index) {
                final user = _userList[index];
                return _buildUserCard(user);
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
                            _loadUserList();
                          }
                        : null,
                  ),
                  Text('$_currentPage / ${(_totalCount / _pageSize).ceil()}'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage * _pageSize < _totalCount
                        ? () {
                            setState(() => _currentPage++);
                            _loadUserList();
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

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    user.nickname.isNotEmpty ? user.nickname[0] : '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.nickname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('@${user.username}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                  value: user.status == 0,
                  onChanged: (_) => _updateStatus(user),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.business, S.current.department, user.deptName ?? '-'),
            _buildInfoRow(Icons.phone, S.current.mobile, user.mobile ?? '-'),
            _buildInfoRow(Icons.access_time, S.current.createTime, user.createTime?.toString().substring(0, 19) ?? '-'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () => _editUser(user),
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(S.current.edit),
                ),
                TextButton.icon(
                  onPressed: () => _showResetPasswordDialog(user),
                  icon: const Icon(Icons.lock_reset, size: 18),
                  label: Text(S.current.resetPassword),
                ),
                TextButton.icon(
                  onPressed: () => _showAssignRoleDialog(user),
                  icon: const Icon(Icons.admin_panel_settings, size: 18),
                  label: Text(S.current.assignRole),
                ),
                TextButton.icon(
                  onPressed: () => _deleteUser(user),
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: Text(S.current.delete, style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
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
}

// ==================== 路由定义 ====================

/// 用户管理页面路由定义
final userPageRoute = PageRouteMeta(
  path: '/system/user',
  name: 'user',
  title: '用户管理',
  icon: 'ant-design:user-outlined',
  permission: 'system:user:list',
  builder: (context) => const UserPage(),
);