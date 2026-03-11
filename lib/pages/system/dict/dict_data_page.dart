import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/system/dict_data_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/dict_data.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_param.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';
import 'dialogs/dict_data_form_dialog.dart';

/// 字典数据管理页面
class DictDataPage extends ConsumerStatefulWidget {
  final String? dictType;

  const DictDataPage({super.key, this.dictType});

  @override
  ConsumerState<DictDataPage> createState() => _DictDataPageState();
}

class _DictDataPageState extends ConsumerState<DictDataPage> {
  final _searchController = TextEditingController();
  int? _selectedStatus;
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
        status: _selectedStatus,
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

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);

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
          Expanded(
            child: isMobile
                ? _buildMobileDataTable(context)
                : _buildDataTable(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Wrap(
            spacing: isMobile ? 8 : 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (!isMobile)
                Text(
                  widget.dictType != null
                      ? '${S.current.currentDictType}: ${widget.dictType}'
                      : S.current.pleaseSelectDictType,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              SizedBox(
                width: isMobile ? 120 : 150,
                child: DropdownButtonFormField<int?>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: S.current.status,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  isExpanded: isMobile,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(S.current.all, overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 0,
                      child: Text(S.current.normal, overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text(S.current.stopped, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                    _loadData();
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: widget.dictType == null ? null : _loadData,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(S.current.refresh),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: widget.dictType == null
                ? null
                : () => showDictDataFormDialog(
                    context,
                    dictType: widget.dictType,
                    ref: ref,
                    onSuccess: _loadData,
                  ),
            icon: const Icon(Icons.add, size: 18),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
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
                onEdit: (dictData) => showDictDataFormDialog(
                  context,
                  dictData: dictData,
                  dictType: widget.dictType,
                  ref: ref,
                  onSuccess: _loadData,
                ),
                onDelete: _deleteDictData,
              ),
            ),
          ),
        );
      },
    );
  }

  /// 移动端数据表格 - 使用 ListView 卡片布局
  Widget _buildMobileDataTable(BuildContext context) {
    if (widget.dictType == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(S.current.pleaseSelectDictTypeLeft),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dictDataList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Column(
      children: [
        // 总数提示
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Text(
            '${S.current.total}: $_total',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        // 数据列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _dictDataList.length,
            itemBuilder: (context, index) {
              final dictData = _dictDataList[index];
              return _buildMobileDictDataCard(dictData);
            },
          ),
        ),
      ],
    );
  }

  /// 移动端字典数据卡片
  Widget _buildMobileDictDataCard(DictData dictData) {
    final color = _getColorByType(dictData.colorType);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dictData.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: dictData.status == 0
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
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
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${S.current.dataValue}: ${dictData.value}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${S.current.sort}: ${dictData.sort ?? 0}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
            if (dictData.remark != null && dictData.remark!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${S.current.remark}: ${dictData.remark}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => showDictDataFormDialog(
                    context,
                    dictData: dictData,
                    dictType: widget.dictType,
                    ref: ref,
                    onSuccess: _loadData,
                  ),
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(S.current.edit),
                ),
                IconButton(
                  onPressed: () => _deleteDictData(dictData),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: S.current.delete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
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