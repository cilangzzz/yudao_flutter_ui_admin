import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/area_api.dart';
import '../../../models/system/area.dart';

/// 地区管理页面
class AreaPage extends ConsumerStatefulWidget {
  const AreaPage({super.key});

  @override
  ConsumerState<AreaPage> createState() => _AreaPageState();
}

class _AreaPageState extends ConsumerState<AreaPage> {
  List<Area> _areaList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAreaTree();
  }

  Future<void> _loadAreaTree() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final areaApi = ref.read(areaApiProvider);
      final response = await areaApi.getAreaTree();

      if (response.isSuccess && response.data != null) {
        setState(() {
          _areaList = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.msg ?? '加载失败';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 工具栏
          _buildToolbar(context),
          const Divider(height: 1),

          // 地区树形表格
          Expanded(
            child: _buildAreaTree(context),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            '地区管理',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          // IP 查询按钮
          ElevatedButton.icon(
            onPressed: () => _showIpQueryDialog(context),
            icon: const Icon(Icons.search),
            label: const Text('IP 查询'),
          ),
          const SizedBox(width: 8),
          // 刷新按钮
          ElevatedButton.icon(
            onPressed: _loadAreaTree,
            icon: const Icon(Icons.refresh),
            label: const Text('刷新'),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaTree(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAreaTree,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_areaList.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('地区编码')),
            DataColumn(label: Text('地区名称')),
          ],
          rows: _buildAreaRows(_areaList, 0),
        ),
      ),
    );
  }

  List<DataRow> _buildAreaRows(List<Area> areas, int level) {
    final rows = <DataRow>[];
    for (final area in areas) {
      rows.add(DataRow(
        cells: [
          DataCell(
            Padding(
              padding: EdgeInsets.only(left: level * 24.0),
              child: Row(
                children: [
                  if (area.children != null && area.children!.isNotEmpty)
                    const Icon(Icons.folder, size: 20, color: Colors.amber)
                  else
                    const Icon(Icons.location_on, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(area.id?.toString() ?? '-'),
                ],
              ),
            ),
          ),
          DataCell(Text(area.name)),
        ],
      ));
      if (area.children != null && area.children!.isNotEmpty) {
        rows.addAll(_buildAreaRows(area.children!, level + 1));
      }
    }
    return rows;
  }

  void _showIpQueryDialog(BuildContext context) {
    final ipController = TextEditingController();
    String result = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('IP 查询'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ipController,
                  decoration: const InputDecoration(
                    labelText: 'IP 地址',
                    hintText: '请输入 IP 地址',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                if (result.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '查询结果: $result',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (ipController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入 IP 地址')),
                  );
                  return;
                }

                try {
                  final areaApi = ref.read(areaApiProvider);
                  final response = await areaApi.getAreaByIp(ipController.text);

                  if (response.isSuccess && response.data != null) {
                    setState(() {
                      result = response.data!;
                    });
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response.msg ?? '查询失败')),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('查询失败: $e')),
                    );
                  }
                }
              },
              child: const Text('查询'),
            ),
          ],
        ),
      ),
    );
  }
}