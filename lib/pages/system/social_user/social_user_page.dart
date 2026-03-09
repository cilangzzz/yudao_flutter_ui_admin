import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/social_user_api.dart';
import '../../../models/system/social_user.dart';

/// 社交用户管理页面
class SocialUserPage extends ConsumerStatefulWidget {
  const SocialUserPage({super.key});

  @override
  ConsumerState<SocialUserPage> createState() => _SocialUserPageState();
}

class _SocialUserPageState extends ConsumerState<SocialUserPage> {
  final _searchController = TextEditingController();
  int? _selectedType;
  List<SocialUser> _dataList = [];
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
      final api = ref.read(socialUserApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_searchController.text.isNotEmpty) 'nickname': _searchController.text,
        if (_selectedType != null) 'type': _selectedType,
      };
      final response = await api.getSocialUserPage(params);
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

  void _showDetailDialog(SocialUser item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('社交用户详情'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID', item.id?.toString() ?? ''),
                _buildDetailRow('社交平台', _getSocialTypeText(item.type)),
                _buildDetailRow('OpenID', item.openid ?? ''),
                _buildDetailRow('昵称', item.nickname ?? ''),
                _buildDetailRow('头像', item.avatar ?? ''),
                _buildDetailRow('创建时间', item.createTime ?? ''),
                _buildDetailRow('更新时间', item.updateTime ?? ''),
                const SizedBox(height: 16),
                const Text('原始用户信息', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.rawUserInfo ?? '无',
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getSocialTypeText(int? type) {
    return _socialTypes[type] ?? '未知';
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
                hintText: '搜索昵称',
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
              value: _selectedType,
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
                setState(() => _selectedType = value);
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
        header: const Text('社交用户列表'),
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
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('社交平台')),
          DataColumn(label: Text('OpenID')),
          DataColumn(label: Text('昵称')),
          DataColumn(label: Text('头像')),
          DataColumn(label: Text('创建时间')),
          DataColumn(label: Text('操作')),
        ],
        source: _SocialUserDataSource(
          _dataList,
          context,
          onDetail: _showDetailDialog,
          getSocialTypeText: _getSocialTypeText,
        ),
      ),
    );
  }
}

class _SocialUserDataSource extends DataTableSource {
  final List<SocialUser> dataList;
  final BuildContext context;
  final void Function(SocialUser) onDetail;
  final String Function(int?) getSocialTypeText;

  _SocialUserDataSource(
    this.dataList,
    this.context, {
    required this.onDetail,
    required this.getSocialTypeText,
  });

  String _truncateText(String? text, int maxLength) {
    if (text == null || text.isEmpty) return '-';
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  @override
  int get rowCount => dataList.length;

  @override
  DataRow getRow(int index) {
    final item = dataList[index];
    return DataRow(
      cells: [
        DataCell(Text(item.id?.toString() ?? '')),
        DataCell(Text(getSocialTypeText(item.type))),
        DataCell(
          Tooltip(
            message: item.openid ?? '',
            child: Text(_truncateText(item.openid, 15)),
          ),
        ),
        DataCell(Text(item.nickname ?? '')),
        DataCell(
          item.avatar != null && item.avatar!.isNotEmpty
              ? Image.network(
                  item.avatar!,
                  width: 32,
                  height: 32,
                  errorBuilder: (_, __, ___) => const Icon(Icons.person),
                )
              : const Icon(Icons.person),
        ),
        DataCell(Text(item.createTime ?? '')),
        DataCell(
          TextButton(
            onPressed: () => onDetail(item),
            child: const Text('详情'),
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