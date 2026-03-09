import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/social_client_api.dart';
import '../../../models/system/social_client.dart';

/// 社交客户端管理页面
class SocialClientPage extends ConsumerStatefulWidget {
  const SocialClientPage({super.key});

  @override
  ConsumerState<SocialClientPage> createState() => _SocialClientPageState();
}

class _SocialClientPageState extends ConsumerState<SocialClientPage> {
  final _searchController = TextEditingController();
  int? _selectedStatus;
  int? _selectedSocialType;
  List<SocialClient> _dataList = [];
  int _total = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = false;

  // 社交平台类型
  static const Map<int, String> _socialTypes = {
    1: '钉钉',
    2: '企业微信',
    3: '微信',
    4: 'QQ',
    5: '微博',
    6: '微信小程序',
    10: '微信开放平台',
    20: 'QQ小程序',
    30: '支付宝小程序',
  };

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
      final api = ref.read(socialClientApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_searchController.text.isNotEmpty) 'name': _searchController.text,
        if (_selectedStatus != null) 'status': _selectedStatus,
        if (_selectedSocialType != null) 'socialType': _selectedSocialType,
      };
      final response = await api.getSocialClientPage(params);
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

  Future<void> _delete(SocialClient item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除社交客户端 "${item.name}" 吗？'),
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
      final api = ref.read(socialClientApiProvider);
      final response = await api.deleteSocialClient(item.id!);
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

  void _showFormDialog([SocialClient? item]) {
    final isEdit = item != null;
    final nameController = TextEditingController(text: item?.name ?? '');
    final clientIdController = TextEditingController(text: item?.clientId ?? '');
    final clientSecretController = TextEditingController(text: item?.clientSecret ?? '');
    final agentIdController = TextEditingController(text: item?.agentId ?? '');
    final publicKeyController = TextEditingController(text: item?.publicKey ?? '');
    int socialType = item?.socialType ?? 1;
    int userType = item?.userType ?? 1;
    int status = item?.status ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? '编辑社交客户端' : '新增社交客户端'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '应用名称 *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: socialType,
                    decoration: const InputDecoration(
                      labelText: '社交平台 *',
                      border: OutlineInputBorder(),
                    ),
                    items: _socialTypes.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (value) => setState(() => socialType = value ?? 1),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: userType,
                    decoration: const InputDecoration(
                      labelText: '用户类型 *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('管理员')),
                      DropdownMenuItem(value: 2, child: Text('会员')),
                    ],
                    onChanged: (value) => setState(() => userType = value ?? 1),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: clientIdController,
                    decoration: const InputDecoration(
                      labelText: '客户端ID *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: clientSecretController,
                    decoration: const InputDecoration(
                      labelText: '客户端密钥',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: agentIdController,
                    decoration: const InputDecoration(
                      labelText: '代理ID (AgentId)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: publicKeyController,
                    decoration: const InputDecoration(
                      labelText: '公钥',
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
                if (nameController.text.isEmpty || clientIdController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请填写必填项')),
                  );
                  return;
                }

                final data = SocialClient(
                  id: item?.id,
                  name: nameController.text,
                  socialType: socialType,
                  userType: userType,
                  clientId: clientIdController.text,
                  clientSecret: clientSecretController.text.isEmpty ? null : clientSecretController.text,
                  agentId: agentIdController.text.isEmpty ? null : agentIdController.text,
                  publicKey: publicKeyController.text.isEmpty ? null : publicKeyController.text,
                  status: status,
                );

                final api = ref.read(socialClientApiProvider);
                final response = isEdit
                    ? await api.updateSocialClient(data)
                    : await api.createSocialClient(data);

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
              value: _selectedSocialType,
              decoration: const InputDecoration(
                labelText: '社交平台',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('全部')),
                ..._socialTypes.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))),
              ],
              onChanged: (value) {
                setState(() => _selectedSocialType = value);
                _loadData();
              },
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
        header: const Text('社交客户端列表'),
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
          DataColumn(label: Text('应用名称')),
          DataColumn(label: Text('社交平台')),
          DataColumn(label: Text('用户类型')),
          DataColumn(label: Text('客户端ID')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('创建时间')),
          DataColumn(label: Text('操作')),
        ],
        source: _SocialClientDataSource(
          _dataList,
          context,
          onEdit: _showFormDialog,
          onDelete: _delete,
        ),
      ),
    );
  }
}

class _SocialClientDataSource extends DataTableSource {
  final List<SocialClient> dataList;
  final BuildContext context;
  final void Function(SocialClient) onEdit;
  final void Function(SocialClient) onDelete;

  _SocialClientDataSource(this.dataList, this.context, {
    required this.onEdit,
    required this.onDelete,
  });

  String _getSocialTypeText(int? socialType) {
    const types = {
      1: '钉钉',
      2: '企业微信',
      3: '微信',
      4: 'QQ',
      5: '微博',
      6: '微信小程序',
      10: '微信开放平台',
      20: 'QQ小程序',
      30: '支付宝小程序',
    };
    return types[socialType] ?? '未知';
  }

  String _getUserTypeText(int? userType) {
    switch (userType) {
      case 1:
        return '管理员';
      case 2:
        return '会员';
      default:
        return '未知';
    }
  }

  @override
  int get rowCount => dataList.length;

  @override
  DataRow getRow(int index) {
    final item = dataList[index];
    return DataRow(
      cells: [
        DataCell(Text(item.name)),
        DataCell(Text(_getSocialTypeText(item.socialType))),
        DataCell(Text(_getUserTypeText(item.userType))),
        DataCell(Text(item.clientId)),
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