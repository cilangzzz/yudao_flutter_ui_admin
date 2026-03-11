import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/../../api/system/dict_type_api.dart';
import '/../../models/system/dict_type.dart';
import '/../../models/common/page_param.dart';
import '/../../models/common/page_result.dart';
import '/../../i18n/i18n.dart';

/// 字典类型管理页面
class DictTypePage extends ConsumerStatefulWidget {
  final void Function(String dictType)? onSelect;

  const DictTypePage({super.key, this.onSelect});

  @override
  ConsumerState<DictTypePage> createState() => _DictTypePageState();
}

class _DictTypePageState extends ConsumerState<DictTypePage> {
  final _searchController = TextEditingController();
  String? _selectedStatus;
  List<DictType> _dictTypes = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _total = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final api = ref.read(dictTypeApiProvider);
      // 服务端过滤：传递搜索参数
      final response = await api.getDictTypePage(
        PageParam(
          pageNum: _currentPage,
          pageSize: _pageSize,
        ),
        name: _searchController.text.isNotEmpty ? _searchController.text : null,
        status: _selectedStatus != null ? int.tryParse(_selectedStatus!) : null,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          _dictTypes = response.data!.list;
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

  Future<void> _deleteDictType(DictType dictType) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteDictType} "${dictType.name}" ?'),
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
        final api = ref.read(dictTypeApiProvider);
        final response = await api.deleteDictType(dictType.id!);
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

  void _showDictTypeDialog([DictType? dictType]) {
    final nameController = TextEditingController(text: dictType?.name ?? '');
    final typeController = TextEditingController(text: dictType?.type ?? '');
    final remarkController = TextEditingController(text: dictType?.remark ?? '');
    int status = dictType?.status ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dictType == null ? S.current.addDictType : S.current.editDictType),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: S.current.dictName,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(
                    labelText: S.current.dictType,
                    border: OutlineInputBorder(),
                  ),
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
                  maxLines: 3,
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
              final data = DictType(
                id: dictType?.id,
                name: nameController.text,
                type: typeController.text,
                status: status,
                remark: remarkController.text.isEmpty ? null : remarkController.text,
              );

              try {
                final api = ref.read(dictTypeApiProvider);
                final response = dictType == null
                    ? await api.createDictType(data)
                    : await api.updateDictType(data);

                if (response.isSuccess) {
                  Navigator.pop(context);
                  _showSuccess(dictType == null ? S.current.addSuccess : S.current.updateSuccess);
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
          _buildSearchBar(context),
          const Divider(height: 1),
          Expanded(child: _buildDataTable(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDictTypeDialog(),
        icon: const Icon(Icons.add),
        label: Text(S.current.addType),
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
          SizedBox(
            width: 250,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: S.current.searchDictNameOrType,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _loadData(),
            ),
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
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: Text(S.current.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PaginatedDataTable(
        header: Row(
          children: [
            Text(S.current.dictTypeList),
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
          DataColumn(label: Text(S.current.dictName)),
          DataColumn(label: Text(S.current.dictType)),
          DataColumn(label: Text(S.current.status)),
          DataColumn(label: Text(S.current.remark)),
          DataColumn(label: Text(S.current.createTime)),
          DataColumn(label: Text(S.current.operation)),
        ],
        source: _DictTypeDataSource(
          _dictTypes,
          context,
          onEdit: _showDictTypeDialog,
          onDelete: _deleteDictType,
          onSelect: widget.onSelect,
        ),
      ),
    );
  }
}

/// 字典类型数据源
class _DictTypeDataSource extends DataTableSource {
  final List<DictType> dictTypes;
  final BuildContext context;
  final void Function(DictType)? onEdit;
  final void Function(DictType)? onDelete;
  final void Function(String)? onSelect;

  _DictTypeDataSource(
    this.dictTypes,
    this.context, {
    this.onEdit,
    this.onDelete,
    this.onSelect,
  });

  @override
  int get rowCount => dictTypes.length;

  @override
  DataRow getRow(int index) {
    final dictType = dictTypes[index];
    return DataRow(
      cells: [
        DataCell(Text(dictType.id?.toString() ?? '')),
        DataCell(
          InkWell(
            onTap: () => onSelect?.call(dictType.type),
            child: Text(
              dictType.name,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        DataCell(Text(dictType.type)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: dictType.status == 0
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              dictType.status == 0 ? S.current.normal : S.current.stopped,
              style: TextStyle(
                color: dictType.status == 0 ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(Text(dictType.remark ?? '-')),
        DataCell(Text(
          dictType.createTime?.toString().substring(0, 19) ?? '-',
        )),
        DataCell(
          Wrap(
            spacing: 0,
            runSpacing: 4,
            children: [
              TextButton(
                onPressed: () => onEdit?.call(dictType),
                child: Text(S.current.edit),
              ),
              TextButton(
                onPressed: () => onDelete?.call(dictType),
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