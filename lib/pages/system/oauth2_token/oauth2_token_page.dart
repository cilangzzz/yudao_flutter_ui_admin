import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/oauth2_token_api.dart';
import '../../../models/system/oauth2_token.dart';

/// OAuth2 令牌管理页面
class OAuth2TokenPage extends ConsumerStatefulWidget {
  const OAuth2TokenPage({super.key});

  @override
  ConsumerState<OAuth2TokenPage> createState() => _OAuth2TokenPageState();
}

class _OAuth2TokenPageState extends ConsumerState<OAuth2TokenPage> {
  final _searchController = TextEditingController();
  List<OAuth2Token> _dataList = [];
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
      final api = ref.read(oauth2TokenApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_searchController.text.isNotEmpty) 'clientId': _searchController.text,
      };
      final response = await api.getOAuth2TokenPage(params);
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

  Future<void> _delete(OAuth2Token item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除该令牌吗？删除后用户将需要重新登录。'),
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

    if (confirmed == true && item.accessToken != null) {
      final api = ref.read(oauth2TokenApiProvider);
      final response = await api.deleteOAuth2Token(item.accessToken!);
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
                hintText: '搜索客户端ID',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _loadData(),
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
        header: const Text('OAuth2 令牌列表'),
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
          DataColumn(label: Text('访问令牌')),
          DataColumn(label: Text('刷新令牌')),
          DataColumn(label: Text('用户ID')),
          DataColumn(label: Text('用户类型')),
          DataColumn(label: Text('客户端ID')),
          DataColumn(label: Text('创建时间')),
          DataColumn(label: Text('过期时间')),
          DataColumn(label: Text('操作')),
        ],
        source: _OAuth2TokenDataSource(
          _dataList,
          context,
          onDelete: _delete,
        ),
      ),
    );
  }
}

class _OAuth2TokenDataSource extends DataTableSource {
  final List<OAuth2Token> dataList;
  final BuildContext context;
  final void Function(OAuth2Token) onDelete;

  _OAuth2TokenDataSource(this.dataList, this.context, {required this.onDelete});

  String _truncateToken(String? token) {
    if (token == null || token.isEmpty) return '-';
    if (token.length <= 20) return token;
    return '${token.substring(0, 10)}...${token.substring(token.length - 10)}';
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
        DataCell(
          Tooltip(
            message: item.accessToken ?? '',
            child: Text(_truncateToken(item.accessToken)),
          ),
        ),
        DataCell(
          Tooltip(
            message: item.refreshToken ?? '',
            child: Text(_truncateToken(item.refreshToken)),
          ),
        ),
        DataCell(Text(item.userId?.toString() ?? '')),
        DataCell(Text(_getUserTypeText(item.userType))),
        DataCell(Text(item.clientId ?? '')),
        DataCell(Text(item.createTime ?? '')),
        DataCell(Text(item.expiresTime ?? '')),
        DataCell(
          TextButton(
            onPressed: () => onDelete(item),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
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