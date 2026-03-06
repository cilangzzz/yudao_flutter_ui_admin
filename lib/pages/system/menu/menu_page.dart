import 'package:flutter/material.dart';

/// 菜单管理页面
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 工具栏
          _buildToolbar(context),
          const Divider(height: 1),

          // 树形表格
          Expanded(
            child: _buildTreeTable(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMenuDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('添加菜单'),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            '菜单管理',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
            label: const Text('刷新'),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeTable(BuildContext context) {
    final menus = [
      _MenuData(id: 1, name: '系统管理', icon: 'settings', sort: 1, status: 0, children: [
        _MenuData(id: 2, name: '用户管理', icon: 'people', sort: 1, status: 0),
        _MenuData(id: 3, name: '角色管理', icon: 'admin_panel_settings', sort: 2, status: 0),
        _MenuData(id: 4, name: '菜单管理', icon: 'menu', sort: 3, status: 0),
      ]),
      _MenuData(id: 5, name: '监控中心', icon: 'monitor', sort: 2, status: 0, children: [
        _MenuData(id: 6, name: '在线用户', icon: 'online_prediction', sort: 1, status: 0),
        _MenuData(id: 7, name: '操作日志', icon: 'history', sort: 2, status: 0),
      ]),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('菜单名称')),
            DataColumn(label: Text('图标')),
            DataColumn(label: Text('排序')),
            DataColumn(label: Text('状态')),
            DataColumn(label: Text('操作')),
          ],
          rows: _buildMenuRows(menus, 0),
        ),
      ),
    );
  }

  List<DataRow> _buildMenuRows(List<_MenuData> menus, int level) {
    final rows = <DataRow>[];
    for (final menu in menus) {
      rows.add(DataRow(
        cells: [
          DataCell(
            Padding(
              padding: EdgeInsets.only(left: level * 24.0),
              child: Row(
                children: [
                  if (menu.children.isNotEmpty)
                    const Icon(Icons.arrow_right, size: 16)
                  else
                    const SizedBox(width: 16),
                  Text(menu.name),
                ],
              ),
            ),
          ),
          DataCell(Icon(_getIcon(menu.icon))),
          DataCell(Text(menu.sort.toString())),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: menu.status == 0
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                menu.status == 0 ? '启用' : '禁用',
                style: TextStyle(
                  color: menu.status == 0 ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          DataCell(
            Row(
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('编辑'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('删除', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ],
      ));
      if (menu.children.isNotEmpty) {
        rows.addAll(_buildMenuRows(menu.children, level + 1));
      }
    }
    return rows;
  }

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'settings':
        return Icons.settings;
      case 'people':
        return Icons.people;
      case 'admin_panel_settings':
        return Icons.admin_panel_settings;
      case 'menu':
        return Icons.menu;
      case 'monitor':
        return Icons.monitor;
      case 'online_prediction':
        return Icons.online_prediction;
      case 'history':
        return Icons.history;
      default:
        return Icons.folder;
    }
  }

  void _showMenuDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加菜单'),
        content: const SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: '菜单名称',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: '路由路径',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: '图标',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: '排序',
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

class _MenuData {
  final int id;
  final String name;
  final String? icon;
  final int sort;
  final int status;
  final List<_MenuData> children;

  const _MenuData({
    required this.id,
    required this.name,
    this.icon,
    required this.sort,
    required this.status,
    this.children = const [],
  });
}