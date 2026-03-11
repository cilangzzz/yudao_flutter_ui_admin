import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../api/system/area_api.dart';
import '../../../models/system/area.dart';
import '../../../i18n/i18n.dart';

/// 地区管理页面
class AreaPage extends ConsumerStatefulWidget {
  const AreaPage({super.key});

  @override
  ConsumerState<AreaPage> createState() => _AreaPageState();
}

class _AreaPageState extends ConsumerState<AreaPage> {
  List<Area> _areaTree = [];
  bool _isLoading = true;
  String? _error;
  bool _isExpanded = false; // 默认折叠所有节点，优化大数据量性能

  // 展开状态记录
  final Map<int, bool> _expandedMap = {};

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
          _areaTree = response.data!;
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

  /// 计算总节点数
  int _countAllAreas(List<Area> areas) {
    int count = 0;
    for (final area in areas) {
      count++;
      if (area.children != null && area.children!.isNotEmpty) {
        count += _countAllAreas(area.children!);
      }
    }
    return count;
  }

  /// 将树形数据扁平化为带层级的列表
  List<_FlatArea> _flattenAreaTree(List<Area> areas, int level) {
    final result = <_FlatArea>[];
    for (final area in areas) {
      final hasChildren = area.children != null && area.children!.isNotEmpty;
      // 默认折叠所有节点，优化大数据量性能
      final isExpanded = _expandedMap[area.id] ?? false;
      result.add(_FlatArea(area: area, level: level, hasChildren: hasChildren));

      if (hasChildren && isExpanded) {
        result.addAll(_flattenAreaTree(area.children!, level + 1));
      }
    }
    return result;
  }

  void _toggleExpand(int areaId) {
    setState(() {
      // 默认折叠，切换时取反
      _expandedMap[areaId] = !(_expandedMap[areaId] ?? false);
    });
  }

  void _toggleAll() {
    setState(() {
      _isExpanded = !_isExpanded;
      _setAllExpanded(_areaTree, _isExpanded);
    });
  }

  void _setAllExpanded(List<Area> areas, bool expanded) {
    for (final area in areas) {
      if (area.id != null) {
        _expandedMap[area.id!] = expanded;
      }
      if (area.children != null && area.children!.isNotEmpty) {
        _setAllExpanded(area.children!, expanded);
      }
    }
  }

  void _showIpQueryDialog() {
    final ipController = TextEditingController();
    String result = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(S.current.ipQuery),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ipController,
                  decoration: InputDecoration(
                    labelText: S.current.ipAddress,
                    hintText: S.current.ipAddressHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.computer),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                if (result.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.current.queryResult,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                result,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
              child: Text(S.current.close),
            ),
            ElevatedButton(
              onPressed: () async {
                if (ipController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.current.pleaseInputIp)),
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
                        SnackBar(content: Text(response.msg ?? S.current.queryFailed)),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${S.current.queryFailed}: $e')),
                    );
                  }
                }
              },
              child: Text(S.current.search),
            ),
          ],
        ),
      ),
    );
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
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _showIpQueryDialog,
            icon: const Icon(Icons.search),
            label: Text(S.current.ipQuery),
          ),
          ElevatedButton.icon(
            onPressed: _loadAreaTree,
            icon: const Icon(Icons.refresh),
            label: Text(S.current.refresh),
          ),
          OutlinedButton.icon(
            onPressed: _toggleAll,
            icon: Icon(_isExpanded ? Icons.unfold_less : Icons.unfold_more),
            label: Text(_isExpanded ? S.current.collapseAll : S.current.expandAll),
          ),
          const SizedBox(width: 16),
          Text(
            '${S.current.total}: ${_countAllAreas(_areaTree)}',
            style: TextStyle(color: Colors.grey[600]),
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
            Text('${S.current.loadFailed}: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAreaTree,
              child: Text(S.current.retry),
            ),
          ],
        ),
      );
    }

    if (_areaTree.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    final flatAreas = _flattenAreaTree(_areaTree, 0);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text(S.current.areaList),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 600,
              smRatio: 0.75,
              lmRatio: 1.5,
              headingRowColor: WidgetStateProperty.resolveWith(
                (states) => Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              headingTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              columns: [
                DataColumn2(
                  label: Text(S.current.areaCode),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.areaName),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.sort),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.status),
                  size: ColumnSize.S,
                ),
              ],
              rows: flatAreas.map((flatArea) {
                final area = flatArea.area;
                final hasChildren = flatArea.hasChildren;
                final isExpanded = _expandedMap[area.id] ?? true;
                final level = flatArea.level;

                return DataRow2(
                  cells: [
                    DataCell(
                      InkWell(
                        onTap: hasChildren ? () => _toggleExpand(area.id!) : null,
                        child: Padding(
                          padding: EdgeInsets.only(left: level * 24.0),
                          child: Row(
                            children: [
                              if (hasChildren)
                                Icon(
                                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                                  size: 20,
                                )
                              else
                                const SizedBox(width: 20),
                              const SizedBox(width: 4),
                              Icon(
                                hasChildren ? Icons.folder : Icons.location_on,
                                size: 20,
                                color: hasChildren ? Colors.amber : Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(area.code),
                            ],
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(area.name)),
                    DataCell(Text(area.sort?.toString() ?? '0')),
                    DataCell(
                      area.status == null
                          ? const Text('-')
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: area.status == 0
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                area.status == 0 ? S.current.enabled : S.current.disabled,
                                style: TextStyle(
                                  color: area.status == 0 ? Colors.green : Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 扁平化的地区数据，用于展示
class _FlatArea {
  final Area area;
  final int level;
  final bool hasChildren;

  const _FlatArea({
    required this.area,
    required this.level,
    required this.hasChildren,
  });
}