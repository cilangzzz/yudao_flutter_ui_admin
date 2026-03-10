import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/user_api.dart';
import '../../../api/system/dept_api.dart';
import '../../../models/system/user.dart';
import '../../../models/system/dept.dart';
import '../../../models/common/api_response.dart';
import '../../../i18n/i18n.dart';

/// 用户管理页面
class UserPage extends ConsumerStatefulWidget {
  const UserPage({super.key});

  @override
  ConsumerState<UserPage> createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage> {
  final _searchController = TextEditingController();
  final _mobileController = TextEditingController();
  int? _selectedStatus;
  int? _selectedDeptId;

  List<User> _userList = [];
  List<SimpleDept> _deptList = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDeptList();
    _loadUserList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _loadDeptList() async {
    try {
      final deptApi = ref.read(deptApiProvider);
      final response = await deptApi.getSimpleDeptList();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _deptList = response.data!;
        });
      }
    } catch (e) {
      // 部门列表加载失败不影响用户列表
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
        status: _selectedStatus,
        deptId: _selectedDeptId,
      );

      final response = await userApi.getUserPage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _userList = response.data!.list;
          _totalCount = response.data!.total;
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

  void _search() {
    _currentPage = 1;
    _loadUserList();
  }

  void _reset() {
    _searchController.clear();
    _mobileController.clear();
    setState(() {
      _selectedStatus = null;
      _selectedDeptId = null;
    });
    _currentPage = 1;
    _loadUserList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(context, isMobile),
          const Divider(height: 1),

          // 数据区域
          Expanded(
            child: isMobile
                ? _buildMobileList(context)
                : _buildDataTable(context),
          ),
        ],
      ),

      // 添加用户按钮
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserDialog(context),
        icon: const Icon(Icons.add),
        label: Text(S.current.addUser),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isMobile) {
    if (isMobile) {
      return _buildMobileSearchBar(context);
    }
    return _buildDesktopSearchBar(context);
  }

  Widget _buildDesktopSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 用户名搜索
          SizedBox(
            width: 200,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: S.current.username,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          const SizedBox(width: 16),

          // 手机号搜索
          SizedBox(
            width: 180,
            child: TextField(
              controller: _mobileController,
              decoration: InputDecoration(
                hintText: S.current.mobile,
                prefixIcon: const Icon(Icons.phone),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          const SizedBox(width: 16),

          // 状态筛选
          SizedBox(
            width: 130,
            child: DropdownButtonFormField<int?>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: S.current.status,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(S.current.all)),
                DropdownMenuItem(value: 0, child: Text(S.current.enabled)),
                DropdownMenuItem(value: 1, child: Text(S.current.disabled)),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
          ),
          const SizedBox(width: 16),

          // 部门筛选
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<int?>(
              value: _selectedDeptId,
              decoration: InputDecoration(
                labelText: S.current.department,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(S.current.all)),
                ..._deptList.map((dept) => DropdownMenuItem(
                  value: dept.id,
                  child: Text(dept.name),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDeptId = value;
                });
              },
            ),
          ),
          const SizedBox(width: 16),

          // 搜索按钮
          ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search),
            label: Text(S.current.search),
          ),
          const SizedBox(width: 8),

          // 重置按钮
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
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
          // 第一行：用户名和手机号
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 第二行：状态和部门筛选
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: S.current.status,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: null, child: Text(S.current.all)),
                    DropdownMenuItem(value: 0, child: Text(S.current.enabled)),
                    DropdownMenuItem(value: 1, child: Text(S.current.disabled)),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _selectedDeptId,
                  decoration: InputDecoration(
                    labelText: S.current.department,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: null, child: Text(S.current.all)),
                    ..._deptList.map((dept) => DropdownMenuItem(
                      value: dept.id,
                      child: Text(dept.name, overflow: TextOverflow.ellipsis),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDeptId = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 第三行：搜索和重置按钮
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

  Widget _buildDataTable(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${S.current.loadFailed}: $_error',
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserList,
              child: Text(S.current.retry),
            ),
          ],
        ),
      );
    }

    if (_userList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PaginatedDataTable(
        header: Text(S.current.userList),
        rowsPerPage: _pageSize,
        availableRowsPerPage: const [10, 20, 50, 100],
        onPageChanged: (page) {
          setState(() {
            _currentPage = page ~/ _pageSize + 1;
          });
          _loadUserList();
        },
        onRowsPerPageChanged: (value) {
          if (value != null) {
            setState(() {
              _pageSize = value;
              _currentPage = 1;
            });
            _loadUserList();
          }
        },
        columns: [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text(S.current.username)),
          DataColumn(label: Text(S.current.nickname)),
          DataColumn(label: Text(S.current.department)),
          DataColumn(label: Text(S.current.mobile)),
          DataColumn(label: Text(S.current.email)),
          DataColumn(label: Text(S.current.status)),
          DataColumn(label: Text(S.current.createTime)),
          DataColumn(label: Text(S.current.operation)),
        ],
        source: _UserDataSource(_userList, context, _editUser, _deleteUser, _updateStatus),
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
            Text('${S.current.loadFailed}: $_error',
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserList,
              child: Text(S.current.retry),
            ),
          ],
        ),
      );
    }

    if (_userList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Column(
      children: [
        // 列表
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

        // 分页控件
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
            // 头部：用户名和状态
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
                      Text(
                        user.nickname,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.status == 0
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.status == 0 ? S.current.enabled : S.current.disabled,
                    style: TextStyle(
                      color: user.status == 0 ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // 详情信息
            _buildInfoRow(Icons.business, S.current.department, user.deptName ?? '-'),
            _buildInfoRow(Icons.phone, S.current.mobile, user.mobile ?? '-'),
            _buildInfoRow(Icons.email, S.current.email, user.email ?? '-'),
            _buildInfoRow(Icons.access_time, S.current.createTime,
                user.createTime?.toString().substring(0, 19) ?? '-'),

            const SizedBox(height: 12),

            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _editUser(user),
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(S.current.edit),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _updateStatus(user),
                  icon: Icon(
                    user.status == 0 ? Icons.block : Icons.check_circle,
                    size: 18,
                  ),
                  label: Text(user.status == 0 ? S.current.disable : S.current.enable),
                ),
                const SizedBox(width: 8),
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
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showUserDialog(BuildContext context, [User? user]) {
    final usernameController = TextEditingController(text: user?.username ?? '');
    final nicknameController = TextEditingController(text: user?.nickname ?? '');
    final mobileController = TextEditingController(text: user?.mobile ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    int selectedDeptId = user?.deptId ?? _selectedDeptId ?? 0;
    int status = user?.status ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(user == null ? S.current.addUser : S.current.editUser),
          content: SizedBox(
            width: 400,
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
                  TextField(
                    controller: nicknameController,
                    decoration: InputDecoration(
                      labelText: '${S.current.nickname} *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedDeptId > 0 ? selectedDeptId : null,
                    decoration: InputDecoration(
                      labelText: S.current.department,
                      border: const OutlineInputBorder(),
                    ),
                    items: _deptList.map((dept) => DropdownMenuItem(
                      value: dept.id,
                      child: Text(dept.name),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDeptId = value ?? 0;
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
                if (usernameController.text.isEmpty || nicknameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.current.pleaseFillRequired)),
                  );
                  return;
                }

                final userData = User(
                  id: user?.id,
                  username: usernameController.text,
                  nickname: nicknameController.text,
                  deptId: selectedDeptId > 0 ? selectedDeptId : null,
                  mobile: mobileController.text.isEmpty ? null : mobileController.text,
                  email: emailController.text.isEmpty ? null : emailController.text,
                  status: status,
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

  void _editUser(User user) {
    _showUserDialog(context, user);
  }

  Future<void> _updateStatus(User user) async {
    final newStatus = user.status == 0 ? 1 : 0;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirm),
        content: Text(newStatus == 0
            ? S.current.confirmEnableUser
            : S.current.confirmDisableUser),
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
}

/// 数据源
class _UserDataSource extends DataTableSource {
  final List<User> users;
  final BuildContext context;
  final void Function(User) onEdit;
  final Future<void> Function(User) onDelete;
  final Future<void> Function(User) onUpdateStatus;

  _UserDataSource(this.users, this.context, this.onEdit, this.onDelete, this.onUpdateStatus);

  @override
  int get rowCount => users.length;

  @override
  DataRow getRow(int index) {
    final user = users[index];
    return DataRow(
      cells: [
        DataCell(Text(user.id?.toString() ?? '-')),
        DataCell(Text(user.username)),
        DataCell(Text(user.nickname)),
        DataCell(Text(user.deptName ?? '-')),
        DataCell(Text(user.mobile ?? '-')),
        DataCell(Text(user.email ?? '-')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: user.status == 0
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              user.status == 0 ? S.current.enabled : S.current.disabled,
              style: TextStyle(
                color: user.status == 0 ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(Text(user.createTime?.toString().substring(0, 19) ?? '-')),
        DataCell(
          Row(
            children: [
              TextButton(
                onPressed: () => onEdit(user),
                child: Text(S.current.edit),
              ),
              TextButton(
                onPressed: () => onUpdateStatus(user),
                child: Text(
                  user.status == 0 ? S.current.disable : S.current.enable,
                ),
              ),
              TextButton(
                onPressed: () => onDelete(user),
                child: Text(S.current.delete, style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}