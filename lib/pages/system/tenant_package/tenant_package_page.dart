import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/tenant_package_api.dart';
import '../../../models/system/tenant_package.dart';

/// 租户套餐管理页面
class TenantPackagePage extends ConsumerStatefulWidget {
  const TenantPackagePage({super.key});

  @override
  ConsumerState<TenantPackagePage> createState() => _TenantPackagePageState();
}

class _TenantPackagePageState extends ConsumerState<TenantPackagePage> {
  final _searchController = TextEditingController();
  int? _selectedStatus;
  List<TenantPackage> _dataList = [];
  int _total = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = false;

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
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final api = ref.read(tenantPackageApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_searchController.text.isNotEmpty) 'name': _searchController.text,
        if (_selectedStatus != null) 'status': _selectedStatus,
      };
      final response = await api.getTenantPackagePage(params);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _dataList = response.data!.list;
          _total = response.data!.total;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(TenantPackage item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除租户套餐 "${item.name}" 吗？'),
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

    if (confirmed == true && item.id != null) {
      final api = ref.read(tenantPackageApiProvider);
      final response = await api.deleteTenantPackage(item.id!);
      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除成功')),
          );
          _loadData();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: ${response.msg}')),
          );
        }
      }
    }
  }

  void _showFormDialog([TenantPackage? item]) {
    final isEdit = item != null;
    final nameController = TextEditingController(text: item?.name ?? '');
    final remarkController = TextEditingController(text: item?.remark ?? '');
    int status = item?.status ?? 0;
    List<int> menuIds = item?.menuIds ?? [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? '编辑租户套餐' : '新增租户套餐'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '套餐名称 *',
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
                      DropdownMenuItem(value: 0, child: Text('开启')),
                      DropdownMenuItem(value: 1, child: Text('禁用')),
                    ],
                    onChanged: (value) => setState(() => status = value ?? 0),
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
                  const SizedBox(height: 16),
                  const Text('关联菜单ID（逗号分隔）', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(text: menuIds.join(', ')),
                    decoration: const InputDecoration(
                      hintText: '例如: 1, 2, 3, 100, 101',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      menuIds = value
                          .split(',')
                          .map((e) => int.tryParse(e.trim()))
                          .where((e) => e != null)
                          .cast<int>()
                          .toList();
                    },
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
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请填写套餐名称')),
                  );
                  return;
                }

                final data = TenantPackage(
                  id: item?.id,
                  name: nameController.text,
                  status: status,
                  remark: remarkController.text.isEmpty ? null : remarkController.text,
                  menuIds: menuIds.isEmpty ? null : menuIds,
                );

                final api = ref.read(tenantPackageApiProvider);
                final response = isEdit
                    ? await api.updateTenantPackage(data)
                    : await api.createTenantPackage(data);

                if (response.isSuccess) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEdit ? '更新成功' : '创建成功')),
                    );
                    _loadData();
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('操作失败: ${response.msg}')),
                    );
                  }
                }
              },
              child: const Text('确定'),
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
          _buildSearchBar(context),
          const Divider(height: 1),
          Expanded(child: _buildDataTable(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('新增套餐'),
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
                hintText: '搜索套餐名称',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _loadData(),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 120,
            child: DropdownButtonFormField<int>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: '状态',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('全部')),
                DropdownMenuItem(value: 0, child: Text('开启')),
                DropdownMenuItem(value: 1, child: Text('禁用')),
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
            label: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    if (_isLoading && _dataList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PaginatedDataTable(
        header: const Text('租户套餐列表'),
        rowsPerPage: _pageSize,
        availableRowsPerPage: const [10, 20, 50, 100],
        onPageChanged: (page) {
          setState(() => _currentPage = page ~/ _pageSize + 1);
          _loadData();
        },
        onRowsPerPageChanged: (value) {
          if (value != null) {
            setState(() {
              _pageSize = value;
              _currentPage = 1;
            });
            _loadData();
          }
        },
        columns: const [
          DataColumn(label: Text('套餐名称')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('备注')),
          DataColumn(label: Text('创建时间')),
          DataColumn(label: Text('操作')),
        ],
        source: _TenantPackageDataSource(
          _dataList,
          context,
          onEdit: _showFormDialog,
          onDelete: _delete,
        ),
      ),
    );
  }
}

class _TenantPackageDataSource extends DataTableSource {
  final List<TenantPackage> dataList;
  final BuildContext context;
  final void Function(TenantPackage) onEdit;
  final void Function(TenantPackage) onDelete;

  _TenantPackageDataSource(
    this.dataList,
    this.context, {
    required this.onEdit,
    required this.onDelete,
  });

  @override
  int get rowCount => dataList.length;

  @override
  DataRow getRow(int index) {
    final item = dataList[index];
    return DataRow(
      cells: [
        DataCell(Text(item.name)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.status == 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item.status == 0 ? '开启' : '禁用',
              style: TextStyle(color: item.status == 0 ? Colors.green : Colors.red, fontSize: 12),
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: item.remark ?? '',
            child: SizedBox(
              width: 200,
              child: Text(
                item.remark ?? '-',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(Text(item.createTime ?? '')),
        DataCell(
          Row(
            children: [
              TextButton(
                onPressed: () => onEdit(item),
                child: const Text('编辑'),
              ),
              TextButton(
                onPressed: () => onDelete(item),
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