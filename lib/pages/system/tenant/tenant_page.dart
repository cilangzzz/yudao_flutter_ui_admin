import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/tenant_api.dart';
import '../../../api/system/tenant_package_api.dart';
import '../../../models/system/tenant.dart';
import '../../../models/system/tenant_package.dart';

/// 租户管理页面
class TenantPage extends ConsumerStatefulWidget {
  const TenantPage({super.key});

  @override
  ConsumerState<TenantPage> createState() => _TenantPageState();
}

class _TenantPageState extends ConsumerState<TenantPage> {
  final _searchController = TextEditingController();
  int? _selectedStatus;
  List<Tenant> _dataList = [];
  List<TenantPackage> _packageList = [];
  int _total = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPackages();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPackages() async {
    final api = ref.read(tenantPackageApiProvider);
    final response = await api.getTenantPackageSimpleList();
    if (response.isSuccess && response.data != null) {
      setState(() => _packageList = response.data!);
    }
  }

  Future<void> _loadData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final api = ref.read(tenantApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_searchController.text.isNotEmpty) 'name': _searchController.text,
        if (_selectedStatus != null) 'status': _selectedStatus,
      };
      final response = await api.getTenantPage(params);
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

  Future<void> _delete(Tenant item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除租户 "${item.name}" 吗？'),
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
      final api = ref.read(tenantApiProvider);
      final response = await api.deleteTenant(item.id!);
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

  void _showFormDialog([Tenant? item]) {
    final isEdit = item != null;
    final nameController = TextEditingController(text: item?.name ?? '');
    final contactNameController = TextEditingController(text: item?.contactName ?? '');
    final contactMobileController = TextEditingController(text: item?.contactMobile ?? '');
    final expireTimeController = TextEditingController(text: item?.expireTime ?? '');
    final accountCountController = TextEditingController(text: item?.accountCount?.toString() ?? '');
    final websiteController = TextEditingController(text: item?.websites?.join('\n') ?? '');
    int? packageId = item?.packageId;
    int status = item?.status ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? '编辑租户' : '新增租户'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '租户名称 *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: packageId,
                    decoration: const InputDecoration(
                      labelText: '租户套餐 *',
                      border: OutlineInputBorder(),
                    ),
                    items: _packageList
                        .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                        .toList(),
                    onChanged: (value) => setState(() => packageId = value),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contactNameController,
                    decoration: const InputDecoration(
                      labelText: '联系人',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contactMobileController,
                    decoration: const InputDecoration(
                      labelText: '联系电话',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: expireTimeController,
                    decoration: const InputDecoration(
                      labelText: '过期时间',
                      hintText: '格式: 2024-12-31',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: accountCountController,
                    decoration: const InputDecoration(
                      labelText: '账号限额',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: websiteController,
                    decoration: const InputDecoration(
                      labelText: '绑定域名（每行一个）',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
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
                if (nameController.text.isEmpty || packageId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请填写必填项')),
                  );
                  return;
                }

                final websites = websiteController.text
                    .split('\n')
                    .where((e) => e.trim().isNotEmpty)
                    .toList();

                final data = Tenant(
                  id: item?.id,
                  name: nameController.text,
                  packageId: packageId,
                  contactName: contactNameController.text.isEmpty ? null : contactNameController.text,
                  contactMobile: contactMobileController.text.isEmpty ? null : contactMobileController.text,
                  expireTime: expireTimeController.text.isEmpty ? null : expireTimeController.text,
                  accountCount: int.tryParse(accountCountController.text),
                  websites: websites.isEmpty ? null : websites,
                  status: status,
                );

                final api = ref.read(tenantApiProvider);
                final response = isEdit
                    ? await api.updateTenant(data)
                    : await api.createTenant(data);

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

  String _getPackageName(int? packageId) {
    if (packageId == null) return '-';
    final package = _packageList.where((e) => e.id == packageId).firstOrNull;
    return package?.name ?? '-';
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
        label: const Text('新增租户'),
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
                hintText: '搜索租户名称',
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
        header: const Text('租户列表'),
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
          DataColumn(label: Text('租户名称')),
          DataColumn(label: Text('租户套餐')),
          DataColumn(label: Text('联系人')),
          DataColumn(label: Text('联系电话')),
          DataColumn(label: Text('账号限额')),
          DataColumn(label: Text('过期时间')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('创建时间')),
          DataColumn(label: Text('操作')),
        ],
        source: _TenantDataSource(
          _dataList,
          context,
          onEdit: _showFormDialog,
          onDelete: _delete,
          getPackageName: _getPackageName,
        ),
      ),
    );
  }
}

class _TenantDataSource extends DataTableSource {
  final List<Tenant> dataList;
  final BuildContext context;
  final void Function(Tenant) onEdit;
  final void Function(Tenant) onDelete;
  final String Function(int?) getPackageName;

  _TenantDataSource(
    this.dataList,
    this.context, {
    required this.onEdit,
    required this.onDelete,
    required this.getPackageName,
  });

  @override
  int get rowCount => dataList.length;

  @override
  DataRow getRow(int index) {
    final item = dataList[index];
    return DataRow(
      cells: [
        DataCell(Text(item.name)),
        DataCell(Text(getPackageName(item.packageId))),
        DataCell(Text(item.contactName ?? '-')),
        DataCell(Text(item.contactMobile ?? '-')),
        DataCell(Text(item.accountCount?.toString() ?? '-')),
        DataCell(Text(item.expireTime ?? '-')),
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