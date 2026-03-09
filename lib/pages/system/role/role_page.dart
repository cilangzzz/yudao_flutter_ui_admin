import 'package:flutter/material.dart';
import '../../../i18n/i18n.dart';

/// 角色管理页面
class RolePage extends StatefulWidget {
  const RolePage({super.key});

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 工具栏
          _buildToolbar(context),
          const Divider(height: 1),

          // 数据表格
          Expanded(
            child: _buildDataTable(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRoleDialog(context),
        icon: const Icon(Icons.add),
        label: Text(S.current.addRole),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            S.current.roleManagement,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
            label: Text(S.current.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    final roles = [
      _RoleData(id: 1, name: '超级管理员', code: 'super_admin', status: 0, sort: 1),
      _RoleData(id: 2, name: '管理员', code: 'admin', status: 0, sort: 2),
      _RoleData(id: 3, name: '普通用户', code: 'user', status: 0, sort: 3),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PaginatedDataTable(
        header: Text(S.current.roleList),
        rowsPerPage: 10,
        columns: [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text(S.current.roleName)),
          DataColumn(label: Text(S.current.roleCode)),
          DataColumn(label: Text(S.current.status)),
          DataColumn(label: Text(S.current.sort)),
          DataColumn(label: Text(S.current.operation)),
        ],
        source: _RoleDataSource(roles, context),
      ),
    );
  }

  void _showRoleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.addRole),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: S.current.roleName,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: S.current.roleCode,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: S.current.sort,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
            onPressed: () => Navigator.pop(context),
            child: Text(S.current.confirm),
          ),
        ],
      ),
    );
  }
}

class _RoleData {
  final int id;
  final String name;
  final String code;
  final int status;
  final int sort;

  const _RoleData({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    required this.sort,
  });
}

class _RoleDataSource extends DataTableSource {
  final List<_RoleData> roles;
  final BuildContext context;

  _RoleDataSource(this.roles, this.context);

  @override
  int get rowCount => roles.length;

  @override
  DataRow getRow(int index) {
    final role = roles[index];
    return DataRow(
      cells: [
        DataCell(Text(role.id.toString())),
        DataCell(Text(role.name)),
        DataCell(Text(role.code)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: role.status == 0
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
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
        ),
        DataCell(Text(role.sort.toString())),
        DataCell(
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: Text(S.current.edit),
              ),
              TextButton(
                onPressed: () {},
                child: Text(S.current.permission),
              ),
              TextButton(
                onPressed: () {},
                child: Text(S.current.delete, style: TextStyle(color: Colors.red)),
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