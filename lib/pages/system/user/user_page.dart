import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../api/system/user_api.dart';
import '../../../api/system/dept_api.dart';
import '../../../api/system/role_api.dart';
import '../../../api/system/post_api.dart';
import '../../../api/system/permission_api.dart';
import '../../../core/api_client.dart';
import '../../../models/system/user.dart';
import '../../../models/system/dept.dart';
import '../../../models/system/role.dart';
import '../../../models/system/post.dart';
import '../../../models/system/permission.dart';
import '../../../models/common/api_response.dart';
import '../../../i18n/i18n.dart';
import '../../../router/route_registry.dart';

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
      // 部门列表加载失败不影响用户列表
      debugPrint('加载部门树失败: $e');
    }
  }

  /// 构建部门树结构
  List<Dept> _buildDeptTree(List<Dept> allDepts) {
    // 找出根节点（parentId 为 0 或 null 的部门）
    final rootDepts = allDepts.where((dept) => dept.parentId == null || dept.parentId == 0).toList();

    List<Dept> buildChildren(int parentId) {
      return allDepts
          .where((dept) => dept.parentId == parentId)
          .map((dept) => dept.copyWith(
                children: buildChildren(dept.id!),
              ))
          .toList();
    }

    return rootDepts.map((dept) => dept.copyWith(
      children: buildChildren(dept.id!),
    )).toList();
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

  /// 切换部门树节点展开/折叠状态
  void _toggleDeptExpand(int deptId) {
    setState(() {
      // 默认折叠，切换时取反
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

      // ignore: unused_local_variable
      final response = await dio.get<List<int>>(
        '/system/user/export-excel',
        queryParameters: params,
        options: Options(responseType: ResponseType.bytes),
      );

      // 这里应该调用文件保存功能，简化处理
      // response.data 包含导出的 Excel 文件字节数据
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
                      : _buildDeptTreeWidget(context, _deptTree),
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
              Expanded(child: _buildDataTable(context)),
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
            onPressed: () => _showUserDialog(context),
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

  Widget _buildDeptTreeWidget(BuildContext context, List<Dept> depts) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: depts.length,
      itemBuilder: (context, index) {
        final dept = depts[index];
        return _buildDeptTile(context, dept, 0);
      },
    );
  }

  Widget _buildDeptTile(BuildContext context, Dept dept, int level) {
    final hasChildren = dept.children != null && dept.children!.isNotEmpty;
    final isSelected = _selectedDeptId == dept.id;
    // 默认折叠所有节点
    final isExpanded = _deptExpandedMap[dept.id] ?? false;

    return Column(
      children: [
        InkWell(
          onTap: () => _handleDeptSelect(dept),
          child: Padding(
            padding: EdgeInsets.only(left: 16.0 * level, top: 8, bottom: 8),
            child: Row(
              children: [
                // 展开/折叠图标
                if (hasChildren)
                  GestureDetector(
                    onTap: () => _toggleDeptExpand(dept.id!),
                    child: Icon(
                      isExpanded ? Icons.expand_more : Icons.chevron_right,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  )
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 4),
                Icon(
                  hasChildren ? Icons.folder : Icons.folder_open,
                  size: 18,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dept.name,
                    style: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 只在展开时渲染子节点
        if (hasChildren && isExpanded)
          ...dept.children!.map((child) => _buildDeptTile(context, child, level + 1)),
      ],
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
            onPressed: () => _showUserDialog(context),
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
            ElevatedButton(onPressed: _loadUserList, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (_userList.isEmpty) {
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
                value: _selectedIds.length == _userList.length && _userList.isNotEmpty,
                tristate: true,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedIds = _userList.where((u) => u.id != null).map((u) => u.id!).toSet();
                    } else {
                      _selectedIds.clear();
                    }
                  });
                },
              ),
              Text(S.current.userList),
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
              minWidth: 900,
              smRatio: 0.75,
              lmRatio: 1.5,
              headingRowColor: WidgetStateProperty.resolveWith(
                (states) => Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              headingTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              dataRowColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3);
                }
                return null;
              }),
              columns: [
                DataColumn2(
                  label: Text('ID'),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.username),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.nickname),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.department),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.mobile),
                  size: ColumnSize.M,
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
              rows: _userList.map((user) {
                final isSelected = user.id != null && _selectedIds.contains(user.id);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    if (user.id != null) {
                      setState(() {
                        if (selected == true) {
                          _selectedIds.add(user.id!);
                        } else {
                          _selectedIds.remove(user.id!);
                        }
                      });
                    }
                  },
                  cells: [
                    DataCell(Text(user.id?.toString() ?? '-')),
                    DataCell(Text(user.username)),
                    DataCell(Text(user.nickname)),
                    DataCell(Text(user.deptName ?? '-')),
                    DataCell(Text(user.mobile ?? '-')),
                    DataCell(
                      _StatusSwitch(
                        isEnabled: user.status == 0,
                        onChanged: () => _updateStatus(user),
                      ),
                    ),
                    DataCell(Text(user.createTime?.toString().substring(0, 19) ?? '-')),
                    DataCell(
                      _ActionButtons(
                        user: user,
                        onEdit: _editUser,
                        onDelete: _deleteUser,
                        onResetPassword: _showResetPasswordDialog,
                        onAssignRole: _showAssignRoleDialog,
                      ),
                    ),
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
              // 每页行数选择
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
                        _loadUserList();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // 分页导航
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showUserDialog(BuildContext context, [User? user]) {
    final usernameController = TextEditingController(text: user?.username ?? '');
    final nicknameController = TextEditingController(text: user?.nickname ?? '');
    final mobileController = TextEditingController(text: user?.mobile ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final passwordController = TextEditingController();
    final remarkController = TextEditingController(text: user?.remark ?? '');
    int? selectedDeptId = user?.deptId ?? _selectedDeptId;
    List<int> selectedPostIds = user?.postIds ?? [];
    int sex = user?.sex ?? 1;
    int status = user?.status ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(user == null ? S.current.addUser : S.current.editUser),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: '${S.current.username} *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (user == null)
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: '${S.current.password} *',
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                  if (user == null) const SizedBox(height: 16),
                  TextField(
                    controller: nicknameController,
                    decoration: InputDecoration(
                      labelText: '${S.current.nickname} *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 部门选择
                  DropdownButtonFormField<int?>(
                    value: selectedDeptId,
                    decoration: InputDecoration(
                      labelText: S.current.department,
                      border: const OutlineInputBorder(),
                    ),
                    items: _buildDeptDropdownItems(_deptTree, 0),
                    onChanged: (value) {
                      setState(() {
                        selectedDeptId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // 岗位选择
                  DropdownButtonFormField<int>(
                    value: selectedPostIds.isNotEmpty ? selectedPostIds.first : null,
                    decoration: InputDecoration(
                      labelText: S.current.post,
                      border: const OutlineInputBorder(),
                    ),
                    items: _postList.map((post) => DropdownMenuItem(
                      value: post.id,
                      child: Text(post.name),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPostIds = value != null ? [value] : [];
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: mobileController,
                    decoration: InputDecoration(
                      labelText: S.current.mobile,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: S.current.email,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  // 性别
                  Row(
                    children: [
                      Text('${S.current.sex}: '),
                      Radio<int>(
                        value: 1,
                        groupValue: sex,
                        onChanged: (value) {
                          setState(() {
                            sex = value!;
                          });
                        },
                      ),
                      Text(S.current.male),
                      Radio<int>(
                        value: 2,
                        groupValue: sex,
                        onChanged: (value) {
                          setState(() {
                            sex = value!;
                          });
                        },
                      ),
                      Text(S.current.female),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: remarkController,
                    decoration: InputDecoration(
                      labelText: S.current.remark,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
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
                if (usernameController.text.isEmpty || nicknameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.current.pleaseFillRequired)),
                  );
                  return;
                }

                if (user == null && passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.current.passwordRequired)),
                  );
                  return;
                }

                final userData = User(
                  id: user?.id,
                  username: usernameController.text,
                  nickname: nicknameController.text,
                  deptId: selectedDeptId,
                  postIds: selectedPostIds,
                  mobile: mobileController.text.isEmpty ? null : mobileController.text,
                  email: emailController.text.isEmpty ? null : emailController.text,
                  sex: sex,
                  status: status,
                  remark: remarkController.text.isEmpty ? null : remarkController.text,
                );

                try {
                  final userApi = ref.read(userApiProvider);
                  ApiResponse<void> response;

                  if (user == null) {
                    response = await userApi.createUser(userData);
                  } else {
                    response = await userApi.updateUser(userData);
                  }

                  if (response.isSuccess) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(user == null ? S.current.addSuccess : S.current.editSuccess)),
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
              },
              child: Text(S.current.confirm),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<int?>> _buildDeptDropdownItems(List<Dept> depts, int level) {
    final items = <DropdownMenuItem<int?>>[];
    for (final dept in depts) {
      items.add(DropdownMenuItem(
        value: dept.id,
        child: Padding(
          padding: EdgeInsets.only(left: 16.0 * level),
          child: Text(dept.name),
        ),
      ));
      if (dept.children != null && dept.children!.isNotEmpty) {
        items.addAll(_buildDeptDropdownItems(dept.children!, level + 1));
      }
    }
    return items;
  }

  void _editUser(User user) {
    _showUserDialog(context, user);
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

  void _showResetPasswordDialog(User user) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.resetPassword),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${S.current.username}: ${user.username}'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: '${S.current.newPassword} *',
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
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
            onPressed: () async {
              if (passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(S.current.passwordRequired)),
                );
                return;
              }

              try {
                final userApi = ref.read(userApiProvider);
                final response = await userApi.resetUserPassword(user.id!, passwordController.text);

                if (response.isSuccess) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(S.current.operationSuccess)),
                    );
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
    );
  }

  void _showAssignRoleDialog(User user) {
    List<int> selectedRoleIds = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(S.current.assignRole),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${S.current.username}: ${user.username}'),
                const SizedBox(height: 8),
                Text('${S.current.nickname}: ${user.nickname}'),
                const SizedBox(height: 16),
                Text(S.current.role, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _roleList.map((role) {
                    final isSelected = selectedRoleIds.contains(role.id);
                    return FilterChip(
                      label: Text(role.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedRoleIds.add(role.id!);
                          } else {
                            selectedRoleIds.remove(role.id);
                          }
                        });
                      },
                    );
                  }).toList(),
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
              onPressed: () async {
                try {
                  final permissionApi = ref.read(permissionApiProvider);
                  final response = await permissionApi.assignUserRole(
                    AssignUserRoleReq(userId: user.id!, roleIds: selectedRoleIds),
                  );

                  if (response.isSuccess) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.current.operationSuccess)),
                      );
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
}

/// 状态开关组件 - 使用 StatelessWidget 避免不必要的重建
class _StatusSwitch extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onChanged;

  const _StatusSwitch({
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isEnabled,
      onChanged: (_) => onChanged(),
    );
  }
}

/// 操作按钮组件 - 使用 StatelessWidget 避免不必要的重建
class _ActionButtons extends StatelessWidget {
  final User user;
  final void Function(User) onEdit;
  final Future<void> Function(User) onDelete;
  final void Function(User) onResetPassword;
  final void Function(User) onAssignRole;

  const _ActionButtons({
    required this.user,
    required this.onEdit,
    required this.onDelete,
    required this.onResetPassword,
    required this.onAssignRole,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => onEdit(user),
          child: Text(S.current.edit),
        ),
        PopupMenuButton<String>(
          tooltip: S.current.more,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'resetPassword',
              child: Row(
                children: [
                  const Icon(Icons.lock_reset, size: 18),
                  const SizedBox(width: 8),
                  Text(S.current.resetPassword),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'assignRole',
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings, size: 18),
                  const SizedBox(width: 8),
                  Text(S.current.assignRole),
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
              case 'resetPassword':
                onResetPassword(user);
                break;
              case 'assignRole':
                onAssignRole(user);
                break;
              case 'delete':
                onDelete(user);
                break;
            }
          },
        ),
      ],
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