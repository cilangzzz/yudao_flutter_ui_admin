import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/oauth2_client_api.dart';
import '../../../models/system/oauth2_client.dart';
import '../../../models/common/page_result.dart';

/// OAuth2 客户端管理页面
class OAuth2ClientPage extends ConsumerStatefulWidget {
  const OAuth2ClientPage({super.key});

  @override
  ConsumerState<OAuth2ClientPage> createState() => _OAuth2ClientPageState();
}

class _OAuth2ClientPageState extends ConsumerState<OAuth2ClientPage> {
  final _searchController = TextEditingController();
  int? _selectedStatus;
  List<OAuth2Client> _dataList = [];
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
      final api = ref.read(oauth2ClientApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_searchController.text.isNotEmpty) 'name': _searchController.text,
        if (_selectedStatus != null) 'status': _selectedStatus,
      };
      final response = await api.getOAuth2ClientPage(params);
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

  Future<void> _delete(OAuth2Client item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除客户端 "${item.name}" 吗？'),
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
      final api = ref.read(oauth2ClientApiProvider);
      final response = await api.deleteOAuth2Client(item.id!);
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

  void _showFormDialog([OAuth2Client? item]) {
    final isEdit = item != null;
    final clientIdController = TextEditingController(text: item?.clientId ?? '');
    final secretController = TextEditingController(text: item?.secret ?? '');
    final nameController = TextEditingController(text: item?.name ?? '');
    final logoController = TextEditingController(text: item?.logo ?? '');
    final descriptionController = TextEditingController(text: item?.description ?? '');
    int status = item?.status ?? 0;
    int accessTokenValidity = item?.accessTokenValiditySeconds ?? 3600;
    int refreshTokenValidity = item?.refreshTokenValiditySeconds ?? 86400;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? '编辑 OAuth2 客户端' : '新增 OAuth2 客户端'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: clientIdController,
                    decoration: const InputDecoration(
                      labelText: '客户端ID *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: secretController,
                    decoration: const InputDecoration(
                      labelText: '客户端密钥',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '应用名称 *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: logoController,
                    decoration: const InputDecoration(
                      labelText: '应用图标',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: '应用描述',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
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
                    controller: TextEditingController(text: accessTokenValidity.toString()),
                    decoration: const InputDecoration(
                      labelText: '访问令牌有效期（秒）',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => accessTokenValidity = int.tryParse(value) ?? 3600,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(text: refreshTokenValidity.toString()),
                    decoration: const InputDecoration(
                      labelText: '刷新令牌有效期（秒）',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => refreshTokenValidity = int.tryParse(value) ?? 86400,
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
                if (clientIdController.text.isEmpty || nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请填写必填项')),
                  );
                  return;
                }

                final data = OAuth2Client(
                  id: item?.id,
                  clientId: clientIdController.text,
                  secret: secretController.text.isEmpty ? null : secretController.text,
                  name: nameController.text,
                  logo: logoController.text.isEmpty ? null : logoController.text,
                  description: descriptionController.text.isEmpty ? null : descriptionController.text,
                  status: status,
                  accessTokenValiditySeconds: accessTokenValidity,
                  refreshTokenValiditySeconds: refreshTokenValidity,
                );

                final api = ref.read(oauth2ClientApiProvider);
                final response = isEdit
                    ? await api.updateOAuth2Client(data)
                    : await api.createOAuth2Client(data);

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
        label: const Text('新增客户端'),
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
                hintText: '搜索客户端名称',
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
        header: const Text('OAuth2 客户端列表'),
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
          DataColumn(label: Text('客户端ID')),
          DataColumn(label: Text('应用名称')),
          DataColumn(label: Text('应用图标')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('访问令牌有效期')),
          DataColumn(label: Text('刷新令牌有效期')),
          DataColumn(label: Text('创建时间')),
          DataColumn(label: Text('操作')),
        ],
        source: _OAuth2ClientDataSource(
          _dataList,
          context,
          onEdit: _showFormDialog,
          onDelete: _delete,
        ),
      ),
    );
  }
}

class _OAuth2ClientDataSource extends DataTableSource {
  final List<OAuth2Client> dataList;
  final BuildContext context;
  final void Function(OAuth2Client) onEdit;
  final void Function(OAuth2Client) onDelete;

  _OAuth2ClientDataSource(this.dataList, this.context, {
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
        DataCell(Text(item.clientId)),
        DataCell(Text(item.name)),
        DataCell(
          item.logo != null && item.logo!.isNotEmpty
              ? Image.network(item.logo!, width: 32, height: 32, errorBuilder: (_, __, ___) => const Icon(Icons.image))
              : const Icon(Icons.image_not_supported),
        ),
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
        DataCell(Text('${item.accessTokenValiditySeconds ?? 0} 秒')),
        DataCell(Text('${item.refreshTokenValiditySeconds ?? 0} 秒')),
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