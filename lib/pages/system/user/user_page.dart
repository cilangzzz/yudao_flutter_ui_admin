import 'package:flutter/material.dart';

/// 用户管理页面
class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedDept;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(context),
          const Divider(height: 1),

          // 数据表格
          Expanded(
            child: _buildDataTable(context),
          ),
        ],
      ),

      // 添加用户按钮
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('添加用户'),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 搜索输入框
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '搜索用户名/昵称',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _refresh(),
            ),
          ),
          const SizedBox(width: 16),

          // 状态筛选
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: '状态',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('全部')),
                DropdownMenuItem(value: '0', child: Text('启用')),
                DropdownMenuItem(value: '1', child: Text('禁用')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
                _refresh();
              },
            ),
          ),
          const SizedBox(width: 16),

          // 部门筛选
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: _selectedDept,
              decoration: const InputDecoration(
                labelText: '部门',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('全部')),
                DropdownMenuItem(value: '1', child: Text('技术部')),
                DropdownMenuItem(value: '2', child: Text('产品部')),
                DropdownMenuItem(value: '3', child: Text('运营部')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDept = value;
                });
                _refresh();
              },
            ),
          ),
          const SizedBox(width: 16),

          // 搜索按钮
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('刷新'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    // 模拟数据
    final users = [
      _UserData(
        id: 1,
        username: 'admin',
        nickname: '管理员',
        deptName: '技术部',
        mobile: '13800138000',
        email: 'admin@example.com',
        status: 0,
        createTime: '2024-01-01 12:00:00',
      ),
      _UserData(
        id: 2,
        username: 'zhangsan',
        nickname: '张三',
        deptName: '产品部',
        mobile: '13800138001',
        email: 'zhangsan@example.com',
        status: 0,
        createTime: '2024-01-02 12:00:00',
      ),
      _UserData(
        id: 3,
        username: 'lisi',
        nickname: '李四',
        deptName: '运营部',
        mobile: '13800138002',
        email: 'lisi@example.com',
        status: 1,
        createTime: '2024-01-03 12:00:00',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PaginatedDataTable(
        header: const Text('用户列表'),
        rowsPerPage: 10,
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('用户名')),
          DataColumn(label: Text('昵称')),
          DataColumn(label: Text('部门')),
          DataColumn(label: Text('手机号')),
          DataColumn(label: Text('邮箱')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('创建时间')),
          DataColumn(label: Text('操作')),
        ],
        source: _UserDataSource(users, context),
      ),
    );
  }

  void _refresh() {
    setState(() {});
  }

  void _showUserDialog(BuildContext context, [_UserData? user]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user == null ? '添加用户' : '编辑用户'),
        content: const SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: '用户名',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: '昵称',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: '手机号',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: '邮箱',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// 用户数据
class _UserData {
  final int id;
  final String username;
  final String nickname;
  final String deptName;
  final String mobile;
  final String email;
  final int status;
  final String createTime;

  const _UserData({
    required this.id,
    required this.username,
    required this.nickname,
    required this.deptName,
    required this.mobile,
    required this.email,
    required this.status,
    required this.createTime,
  });
}

/// 数据源
class _UserDataSource extends DataTableSource {
  final List<_UserData> users;
  final BuildContext context;

  _UserDataSource(this.users, this.context);

  @override
  int get rowCount => users.length;

  @override
  DataRow getRow(int index) {
    final user = users[index];
    return DataRow(
      cells: [
        DataCell(Text(user.id.toString())),
        DataCell(Text(user.username)),
        DataCell(Text(user.nickname)),
        DataCell(Text(user.deptName)),
        DataCell(Text(user.mobile)),
        DataCell(Text(user.email)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: user.status == 0
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              user.status == 0 ? '启用' : '禁用',
              style: TextStyle(
                color: user.status == 0 ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(Text(user.createTime)),
        DataCell(
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('编辑'),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('确认删除'),
                      content: Text('确定要删除用户 "${user.nickname}" 吗？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('取消'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('删除'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('删除', style: TextStyle(color: Colors.red)),
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