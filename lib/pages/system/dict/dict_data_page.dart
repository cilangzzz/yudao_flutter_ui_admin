import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/dict_data_api.dart';
import '../../../models/system/dict_data.dart';
import '../../../models/common/page_param.dart';

/// 字典数据管理页面
class DictDataPage extends ConsumerStatefulWidget {
  final String? dictType;

  const DictDataPage({super.key, this.dictType});

  @override
  ConsumerState<DictDataPage> createState() => _DictDataPageState();
}

class _DictDataPageState extends ConsumerState<DictDataPage> {
  final _searchController = TextEditingController();
  String? _selectedStatus;
  List<DictData> _dictDataList = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _total = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    if (widget.dictType != null) {
      _loadData();
    }
  }

  @override
  void didUpdateWidget(DictDataPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dictType != oldWidget.dictType && widget.dictType != null) {
      _currentPage = 1;
      _loadData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.dictType == null || widget.dictType!.isEmpty) {
      setState(() => _dictDataList = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ref.read(dictDataApiProvider);
      final response = await api.getDictDataPage(PageParam(
        pageNum: _currentPage,
        pageSize: _pageSize,
      ));

      if (response.isSuccess && response.data != null) {
        // 过滤当前字典类型的数据
        final filteredList = response.data!.list
            .where((item) => item.dictType == widget.dictType)
            .toList();
        setState(() {
          _dictDataList = filteredList;
          _total = response.data!.total;
        });
      } else {
        _showError(response.msg ?? '加载失败');
      }
    } catch (e) {
      _showError('加载异常: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _deleteDictData(DictData dictData) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除字典数据 "${dictData.label}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final api = ref.read(dictDataApiProvider);
        final response = await api.deleteDictData(dictData.id!);
        if (response.isSuccess) {
          _showSuccess('删除成功');
          _loadData();
        } else {
          _showError(response.msg ?? '删除失败');
        }
      } catch (e) {
        _showError('删除异常: $e');
      }
    }
  }

  void _showDictDataDialog([DictData? dictData]) {
    final labelController = TextEditingController(text: dictData?.label ?? '');
    final valueController = TextEditingController(text: dictData?.value ?? '');
    final sortController = TextEditingController(text: (dictData?.sort ?? 0).toString());
    final remarkController = TextEditingController(text: dictData?.remark ?? '');
    String colorType = dictData?.colorType ?? 'default';
    int status = dictData?.status ?? 0;

    final colorOptions = [
      {'value': 'default', 'label': '默认', 'color': Colors.grey},
      {'value': 'primary', 'label': '主要', 'color': Colors.blue},
      {'value': 'success', 'label': '成功', 'color': Colors.green},
      {'value': 'warning', 'label': '警告', 'color': Colors.orange},
      {'value': 'danger', 'label': '危险', 'color': Colors.red},
      {'value': 'info', 'label': '信息', 'color': Colors.cyan},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dictData == null ? '添加字典数据' : '编辑字典数据'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: '数据标签',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: valueController,
                  decoration: const InputDecoration(
                    labelText: '数据键值',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sortController,
                  decoration: const InputDecoration(
                    labelText: '排序',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: colorType,
                  decoration: const InputDecoration(
                    labelText: '颜色类型',
                    border: OutlineInputBorder(),
                  ),
                  items: colorOptions.map((opt) {
                    return DropdownMenuItem(
                      value: opt['value'] as String,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: opt['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(opt['label'] as String),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => colorType = value ?? 'default',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: '状态',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('正常')),
                    DropdownMenuItem(value: 1, child: Text('停用')),
                  ],
                  onChanged: (value) => status = value ?? 0,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: remarkController,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    border: OutlineInputBorder(),
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
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = DictData(
                id: dictData?.id,
                label: labelController.text,
                value: valueController.text,
                dictType: widget.dictType,
                sort: int.tryParse(sortController.text) ?? 0,
                colorType: colorType,
                status: status,
                remark: remarkController.text.isEmpty ? null : remarkController.text,
              );

              try {
                final api = ref.read(dictDataApiProvider);
                final response = dictData == null
                    ? await api.createDictData(data)
                    : await api.updateDictData(data);

                if (response.isSuccess) {
                  Navigator.pop(context);
                  _showSuccess(dictData == null ? '添加成功' : '更新成功');
                  _loadData();
                } else {
                  _showError(response.msg ?? '操作失败');
                }
              } catch (e) {
                _showError('操作异常: $e');
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(context),
          const Divider(height: 1),
          Expanded(child: _buildDataTable(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.dictType == null ? null : () => _showDictDataDialog(),
        icon: const Icon(Icons.add),
        label: const Text('添加数据'),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.dictType != null
                  ? '当前字典类型: ${widget.dictType}'
                  : '请先选择字典类型',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 16),
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
                DropdownMenuItem(value: '0', child: Text('正常')),
                DropdownMenuItem(value: '1', child: Text('停用')),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                _loadData();
              },
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: widget.dictType == null ? null : _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('刷新'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    if (widget.dictType == null) {
      return const Center(
        child: Text('请在左侧选择字典类型'),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dictDataList.isEmpty) {
      return const Center(
        child: Text('暂无数据'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PaginatedDataTable(
        header: const Text('字典数据列表'),
        rowsPerPage: _pageSize,
        availableRowsPerPage: const [10, 20, 50],
        onPageChanged: (page) {
          _currentPage = page + 1;
          _loadData();
        },
        // total: _total,
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('数据标签')),
          DataColumn(label: Text('数据键值')),
          DataColumn(label: Text('排序')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('颜色')),
          DataColumn(label: Text('备注')),
          DataColumn(label: Text('创建时间')),
          DataColumn(label: Text('操作')),
        ],
        source: _DictDataDataSource(
          _dictDataList,
          context,
          onEdit: _showDictDataDialog,
          onDelete: _deleteDictData,
        ),
      ),
    );
  }
}

/// 字典数据数据源
class _DictDataDataSource extends DataTableSource {
  final List<DictData> dictDataList;
  final BuildContext context;
  final void Function(DictData)? onEdit;
  final void Function(DictData)? onDelete;

  _DictDataDataSource(
    this.dictDataList,
    this.context, {
    this.onEdit,
    this.onDelete,
  });

  Color _getColorByType(String? colorType) {
    switch (colorType) {
      case 'primary':
        return Colors.blue;
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'danger':
        return Colors.red;
      case 'info':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  @override
  int get rowCount => dictDataList.length;

  @override
  DataRow getRow(int index) {
    final dictData = dictDataList[index];
    final color = _getColorByType(dictData.colorType);

    return DataRow(
      cells: [
        DataCell(Text(dictData.id?.toString() ?? '')),
        DataCell(Text(dictData.label)),
        DataCell(Text(dictData.value)),
        DataCell(Text(dictData.sort?.toString() ?? '0')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: dictData.status == 0
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              dictData.status == 0 ? '正常' : '停用',
              style: TextStyle(
                color: dictData.status == 0 ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        DataCell(Text(dictData.remark ?? '-')),
        DataCell(Text(
          dictData.createTime?.toString().substring(0, 19) ?? '-',
        )),
        DataCell(
          Row(
            children: [
              TextButton(
                onPressed: () => onEdit?.call(dictData),
                child: const Text('编辑'),
              ),
              TextButton(
                onPressed: () => onDelete?.call(dictData),
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