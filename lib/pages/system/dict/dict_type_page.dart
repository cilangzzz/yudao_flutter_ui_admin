import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/dict_type_api.dart';
import '../../../models/system/dict_type.dart';
import '../../../models/common/page_param.dart';
import '../../../models/common/page_result.dart';

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
      final response = await api.getDictTypePage(PageParam(
        pageNum: _currentPage,
        pageSize: _pageSize,
      ));

      if (response.isSuccess && response.data != null) {
        setState(() {
          _dictTypes = response.data!.list;
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

  Future<void> _deleteDictType(DictType dictType) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除字典类型 "${dictType.name}" 吗？'),
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
        final api = ref.read(dictTypeApiProvider);
        final response = await api.deleteDictType(dictType.id!);
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

  void _showDictTypeDialog([DictType? dictType]) {
    final nameController = TextEditingController(text: dictType?.name ?? '');
    final typeController = TextEditingController(text: dictType?.type ?? '');
    final remarkController = TextEditingController(text: dictType?.remark ?? '');
    int status = dictType?.status ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dictType == null ? '添加字典类型' : '编辑字典类型'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '字典名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(
                  labelText: '字典类型',
                  border: OutlineInputBorder(),
                ),
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
                maxLines: 3,
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
                  _showSuccess(dictType == null ? '添加成功' : '更新成功');
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
        onPressed: () => _showDictTypeDialog(),
        icon: const Icon(Icons.add),
        label: const Text('添加类型'),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '搜索字典名称/类型',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _loadData(),
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
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('刷新'),
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
        header: const Text('字典类型列表'),
        rowsPerPage: _pageSize,
        availableRowsPerPage: const [10, 20, 50],
        onPageChanged: (page) {
          _currentPage = page + 1;
          _loadData();
        },
        // total: _total,
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('字典名称')),
          DataColumn(label: Text('字典类型')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('备注')),
          DataColumn(label: Text('创建时间')),
          DataColumn(label: Text('操作')),
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
              dictType.status == 0 ? '正常' : '停用',
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
          Row(
            children: [
              TextButton(
                onPressed: () => onEdit?.call(dictType),
                child: const Text('编辑'),
              ),
              TextButton(
                onPressed: () => onDelete?.call(dictType),
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