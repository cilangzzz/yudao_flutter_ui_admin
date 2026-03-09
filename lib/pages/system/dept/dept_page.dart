import 'package:flutter/material.dart';
import '../../../i18n/i18n.dart';

/// 部门管理页面
class DeptPage extends StatefulWidget {
  const DeptPage({super.key});

  @override
  State<DeptPage> createState() => _DeptPageState();
}

class _DeptPageState extends State<DeptPage> {
  final _searchController = TextEditingController();

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

          // 部门树形表格
          Expanded(
            child: _buildDeptTree(context),
          ),
        ],
      ),

      // 添加部门按钮
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDeptDialog(context),
        icon: const Icon(Icons.add),
        label: Text(S.current.addDept),
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
              decoration: InputDecoration(
                hintText: S.current.searchDeptName,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _refresh(),
            ),
          ),
          const SizedBox(width: 16),

          // 搜索按钮
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: Text(S.current.refresh),
          ),
          const SizedBox(width: 8),

          // 展开全部
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.unfold_more),
            label: Text(S.current.expandAll),
          ),
          const SizedBox(width: 8),

          // 折叠全部
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.unfold_less),
            label: Text(S.current.collapseAll),
          ),
        ],
      ),
    );
  }

  Widget _buildDeptTree(BuildContext context) {
    // 模拟数据
    final depts = [
      _DeptData(
        id: 1,
        name: '科技研发部',
        leader: '张三',
        phone: '13800138000',
        email: 'tech@example.com',
        status: 0,
        sort: 1,
        createTime: '2024-01-01 12:00:00',
        children: [
          _DeptData(
            id: 11,
            name: '前端开发组',
            leader: '李四',
            phone: '13800138001',
            email: 'frontend@example.com',
            status: 0,
            sort: 1,
            createTime: '2024-01-02 12:00:00',
          ),
          _DeptData(
            id: 12,
            name: '后端开发组',
            leader: '王五',
            phone: '13800138002',
            email: 'backend@example.com',
            status: 0,
            sort: 2,
            createTime: '2024-01-02 12:00:00',
          ),
        ],
      ),
      _DeptData(
        id: 2,
        name: '产品运营部',
        leader: '赵六',
        phone: '13800138003',
        email: 'product@example.com',
        status: 0,
        sort: 2,
        createTime: '2024-01-01 12:00:00',
        children: [
          _DeptData(
            id: 21,
            name: '产品设计组',
            leader: '钱七',
            phone: '13800138004',
            email: 'design@example.com',
            status: 0,
            sort: 1,
            createTime: '2024-01-03 12:00:00',
          ),
          _DeptData(
            id: 22,
            name: '市场运营组',
            leader: '孙八',
            phone: '13800138005',
            email: 'marketing@example.com',
            status: 1,
            sort: 2,
            createTime: '2024-01-03 12:00:00',
          ),
        ],
      ),
      _DeptData(
        id: 3,
        name: '人事行政部',
        leader: '周九',
        phone: '13800138006',
        email: 'hr@example.com',
        status: 0,
        sort: 3,
        createTime: '2024-01-01 12:00:00',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PaginatedDataTable(
        header: Text(S.current.deptList),
        rowsPerPage: 10,
        columns: [
          DataColumn(label: Text(S.current.deptName)),
          DataColumn(label: Text(S.current.leader)),
          DataColumn(label: Text(S.current.phone)),
          DataColumn(label: Text(S.current.email)),
          DataColumn(label: Text(S.current.status)),
          DataColumn(label: Text(S.current.sort)),
          DataColumn(label: Text(S.current.createTime)),
          DataColumn(label: Text(S.current.operation)),
        ],
        source: _DeptDataSource(depts, context),
      ),
    );
  }

  void _refresh() {
    setState(() {});
  }

  void _showDeptDialog(BuildContext context, [_DeptData? dept]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dept == null ? S.current.addDept : S.current.editDept),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: S.current.deptName,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: S.current.leader,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: S.current.phone,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: S.current.email,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
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

/// 部门数据
class _DeptData {
  final int id;
  final String name;
  final String leader;
  final String phone;
  final String email;
  final int status;
  final int sort;
  final String createTime;
  final List<_DeptData>? children;

  const _DeptData({
    required this.id,
    required this.name,
    required this.leader,
    required this.phone,
    required this.email,
    required this.status,
    required this.sort,
    required this.createTime,
    this.children,
  });
}

/// 数据源
class _DeptDataSource extends DataTableSource {
  final List<_DeptData> depts;
  final BuildContext context;
  final List<_DeptData> _flattenedDepts;

  _DeptDataSource(this.depts, this.context)
      : _flattenedDepts = _flattenDepts(depts);

  static List<_DeptData> _flattenDepts(List<_DeptData> depts, [int level = 0]) {
    final result = <_DeptData>[];
    for (final dept in depts) {
      result.add(dept);
      if (dept.children != null && dept.children!.isNotEmpty) {
        result.addAll(_flattenDepts(dept.children!, level + 1));
      }
    }
    return result;
  }

  @override
  int get rowCount => _flattenedDepts.length;

  @override
  DataRow getRow(int index) {
    final dept = _flattenedDepts[index];
    final level = _getDeptLevel(_flattenedDepts, index);

    return DataRow(
      cells: [
        DataCell(
          Padding(
            padding: EdgeInsets.only(left: level * 24.0),
            child: Row(
              children: [
                if (dept.children != null && dept.children!.isNotEmpty)
                  const Icon(Icons.folder, size: 20, color: Colors.amber)
                else
                  const Icon(Icons.folder_open, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(dept.name),
              ],
            ),
          ),
        ),
        DataCell(Text(dept.leader)),
        DataCell(Text(dept.phone)),
        DataCell(Text(dept.email)),
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
              dept.status == 0 ? S.current.normal : S.current.stopped,
              style: TextStyle(
                color: dept.status == 0 ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(Text(dept.sort.toString())),
        DataCell(Text(dept.createTime)),
        DataCell(
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: Text(S.current.edit),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(S.current.confirmDelete),
                      content: Text(S.current.confirmDeleteDept),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(S.current.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text(S.current.delete),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(S.current.delete, style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _getDeptLevel(List<_DeptData> depts, int index) {
    // 简化实现：通过名称缩进判断层级
    return 0;
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}