import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/dict_data_api.dart';
import '../../../models/system/dict_data.dart';
import '../../../models/common/page_param.dart';
import '../../../i18n/i18n.dart';

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
      // 服务端过滤：传递 dictType 参数，避免客户端过滤
      final response = await api.getDictDataPage(
        PageParam(
          pageNum: _currentPage,
          pageSize: _pageSize,
        ),
        dictType: widget.dictType,
        status: _selectedStatus != null ? int.tryParse(_selectedStatus!) : null,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          _dictDataList = response.data!.list;
          _total = response.data!.total;
        });
      } else {
        _showError(response.msg ?? S.current.loadFailed);
      }
    } catch (e) {
      _showError('${S.current.loadFailed}: $e');
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
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteDictData} "${dictData.label}" ?'),
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
        final api = ref.read(dictDataApiProvider);
        final response = await api.deleteDictData(dictData.id!);
        if (response.isSuccess) {
          _showSuccess(S.current.deleteSuccess);
          _loadData();
        } else {
          _showError(response.msg ?? S.current.deleteFailed);
        }
      } catch (e) {
        _showError('${S.current.deleteFailed}: $e');
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
      {'value': 'default', 'label': S.current.colorDefault, 'color': Colors.grey},
      {'value': 'primary', 'label': S.current.colorPrimary, 'color': Colors.blue},
      {'value': 'success', 'label': S.current.colorSuccess, 'color': Colors.green},
      {'value': 'warning', 'label': S.current.colorWarning, 'color': Colors.orange},
      {'value': 'danger', 'label': S.current.colorDanger, 'color': Colors.red},
      {'value': 'info', 'label': S.current.colorInfo, 'color': Colors.cyan},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dictData == null ? S.current.addDictData : S.current.editDictData),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelController,
                  decoration: InputDecoration(
                    labelText: S.current.dataLabel,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: S.current.dataValue,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sortController,
                  decoration: InputDecoration(
                    labelText: S.current.sort,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: colorType,
                  decoration: InputDecoration(
                    labelText: S.current.colorType,
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
                  decoration: InputDecoration(
                    labelText: S.current.status,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 0, child: Text(S.current.normal)),
                    DropdownMenuItem(value: 1, child: Text(S.current.stopped)),
                  ],
                  onChanged: (value) => status = value ?? 0,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: remarkController,
                  decoration: InputDecoration(
                    labelText: S.current.remark,
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
            child: Text(S.current.cancel),
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
                  _showSuccess(dictData == null ? S.current.addSuccess : S.current.updateSuccess);
                  _loadData();
                } else {
                  _showError(response.msg ?? S.current.operationFailed);
                }
              } catch (e) {
                _showError('${S.current.operationFailed}: $e');
              }
            },
            child: Text(S.current.confirm),
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
          // 搜索栏
          _buildSearchBar(context),
          const Divider(height: 1),

          // 工具栏
          _buildToolbar(context),
          const Divider(height: 1),

          // 数据表格
          Expanded(child: _buildDataTable(context)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            widget.dictType != null
                ? '${S.current.currentDictType}: ${widget.dictType}'
                : S.current.pleaseSelectDictType,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: S.current.status,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(S.current.all)),
                DropdownMenuItem(value: '0', child: Text(S.current.normal)),
                DropdownMenuItem(value: '1', child: Text(S.current.stopped)),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                _loadData();
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: widget.dictType == null ? null : _loadData,
            icon: const Icon(Icons.refresh),
            label: Text(S.current.refresh),
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
            onPressed: widget.dictType == null ? null : () => _showDictDataDialog(),
            icon: const Icon(Icons.add),
            label: Text(S.current.addData),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    if (widget.dictType == null) {
      return Center(
        child: Text(S.current.pleaseSelectDictTypeLeft),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dictDataList.isEmpty) {
      return Center(
        child: Text(S.current.noData),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PaginatedDataTable(
        header: Row(
          children: [
            Text(S.current.dictDataList),
            const Spacer(),
            Text(
              '${S.current.total}: $_total',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        rowsPerPage: _pageSize,
        availableRowsPerPage: const [10, 20, 50],
        onPageChanged: (page) {
          _currentPage = page + 1;
          _loadData();
        },
        columns: [
          DataColumn(label: Text(S.current.id)),
          DataColumn(label: Text(S.current.dataLabel)),
          DataColumn(label: Text(S.current.dataValue)),
          DataColumn(label: Text(S.current.sort)),
          DataColumn(label: Text(S.current.status)),
          DataColumn(label: Text(S.current.color)),
          DataColumn(label: Text(S.current.remark)),
          DataColumn(label: Text(S.current.createTime)),
          DataColumn(label: Text(S.current.operation)),
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
              dictData.status == 0 ? S.current.normal : S.current.stopped,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => onEdit?.call(dictData),
                child: Text(S.current.edit),
              ),
              PopupMenuButton<String>(
                tooltip: S.current.more,
                itemBuilder: (context) => [
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
                    case 'delete':
                      onDelete?.call(dictData);
                      break;
                  }
                },
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