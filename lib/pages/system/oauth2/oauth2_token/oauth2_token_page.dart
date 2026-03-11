import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../../api/system/oauth2_token_api.dart';
import '../../../../models/system/oauth2_token.dart';
import '../../../../models/common/api_response.dart';

/// OAuth2 令牌管理页面
class OAuth2TokenPage extends ConsumerStatefulWidget {
  const OAuth2TokenPage({super.key});

  @override
  ConsumerState<OAuth2TokenPage> createState() => _OAuth2TokenPageState();
}

class _OAuth2TokenPageState extends ConsumerState<OAuth2TokenPage> {
  final _searchController = TextEditingController();
  final _userIdController = TextEditingController();
  int? _selectedUserType;

  List<OAuth2Token> _dataList = [];
  Set<String> _selectedTokens = {};
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

  // 用户类型选项
  static const List<Map<String, dynamic>> _userTypes = [
    {'value': null, 'label': '全部'},
    {'value': 1, 'label': '管理员'},
    {'value': 2, 'label': '会员'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(oauth2TokenApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_searchController.text.isNotEmpty) 'clientId': _searchController.text,
        if (_userIdController.text.isNotEmpty) 'userId': _userIdController.text,
        if (_selectedUserType != null) 'userType': _selectedUserType,
      };
      final response = await api.getOAuth2TokenPage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _dataList = response.data!.list;
          _totalCount = response.data!.total;
          _isLoading = false;
          _selectedTokens.clear();
        });
      } else {
        setState(() {
          _error = response.msg.isNotEmpty ? response.msg : '加载失败';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _search() {
    _currentPage = 1;
    _loadData();
  }

  void _reset() {
    _searchController.clear();
    _userIdController.clear();
    setState(() {
      _selectedUserType = null;
    });
    _currentPage = 1;
    _loadData();
  }

  Future<void> _deleteSelected() async {
    if (_selectedTokens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择要删除的令牌')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 ${_selectedTokens.length} 个令牌吗？删除后用户将需要重新登录。'),
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
        final api = ref.read(oauth2TokenApiProvider);
        int successCount = 0;
        int failCount = 0;

        for (final token in _selectedTokens) {
          final response = await api.deleteOAuth2Token(token);
          if (response.isSuccess) {
            successCount++;
          } else {
            failCount++;
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('成功删除 $successCount 个令牌${failCount > 0 ? '，失败 $failCount 个' : ''}')),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
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
      try {
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
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
    }
  }

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

  Color _getUserTypeColor(int? userType) {
    switch (userType) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(context),
          const Divider(height: 1),
          if (!isMobile) _buildToolbar(context),
          if (!isMobile) const Divider(height: 1),
          Expanded(
            child: isMobile ? _buildMobileList(context) : _buildDataTable(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                hintText: '用户编号',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _search(),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<int>(
              value: _selectedUserType,
              decoration: const InputDecoration(
                labelText: '用户类型',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _userTypes.map((type) {
                return DropdownMenuItem(
                  value: type['value'] as int?,
                  child: Text(type['label'] as String),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedUserType = value);
                _search();
              },
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 200,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '客户端编号',
                prefixIcon: Icon(Icons.apps),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search),
            label: const Text('搜索'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            label: const Text('重置'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: _selectedTokens.isEmpty ? null : _deleteSelected,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete),
            label: const Text('批量删除'),
          ),
          const SizedBox(width: 8),
          Text(
            '提示: 删除令牌后，用户将需要重新登录',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('重试')),
          ],
        ),
      );
    }

    if (_dataList.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 表头
          Row(
            children: [
              Checkbox(
                value: _selectedTokens.length == _dataList.length && _dataList.isNotEmpty,
                tristate: true,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedTokens = _dataList
                          .where((e) => e.accessToken != null)
                          .map((e) => e.accessToken!)
                          .toSet();
                    } else {
                      _selectedTokens.clear();
                    }
                  });
                },
              ),
              const Text('OAuth2 令牌列表'),
              const Spacer(),
              Text('共 $_totalCount 条'),
            ],
          ),
          const SizedBox(height: 8),
          // 表格
          Expanded(
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 1200,
              smRatio: 0.75,
              lmRatio: 1.5,
              headingRowColor: WidgetStateProperty.resolveWith(
                (states) => Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              headingTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              dataRowColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3);
                }
                return null;
              }),
              columns: const [
                DataColumn2(label: Text('访问令牌'), size: ColumnSize.L),
                DataColumn2(label: Text('刷新令牌'), size: ColumnSize.L),
                DataColumn2(label: Text('用户编号'), size: ColumnSize.S),
                DataColumn2(label: Text('用户类型'), size: ColumnSize.S),
                DataColumn2(label: Text('客户端编号'), size: ColumnSize.M),
                DataColumn2(label: Text('创建时间'), size: ColumnSize.L),
                DataColumn2(label: Text('过期时间'), size: ColumnSize.L),
                DataColumn2(label: Text('操作'), size: ColumnSize.S),
              ],
              rows: _dataList.map((item) {
                final isSelected = item.accessToken != null && _selectedTokens.contains(item.accessToken);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    if (item.accessToken != null) {
                      setState(() {
                        if (selected == true) {
                          _selectedTokens.add(item.accessToken!);
                        } else {
                          _selectedTokens.remove(item.accessToken!);
                        }
                      });
                    }
                  },
                  cells: [
                    DataCell(
                      Tooltip(
                        message: item.accessToken ?? '',
                        child: SelectableText(_truncateToken(item.accessToken)),
                      ),
                    ),
                    DataCell(
                      Tooltip(
                        message: item.refreshToken ?? '',
                        child: SelectableText(_truncateToken(item.refreshToken)),
                      ),
                    ),
                    DataCell(Text(item.userId?.toString() ?? '-')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getUserTypeColor(item.userType).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getUserTypeText(item.userType),
                          style: TextStyle(
                            color: _getUserTypeColor(item.userType),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(item.clientId ?? '-')),
                    DataCell(Text(item.createTime ?? '-')),
                    DataCell(Text(item.expiresTime ?? '-')),
                    DataCell(
                      TextButton(
                        onPressed: () => _delete(item),
                        child: const Text('删除', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          // 分页
          const SizedBox(height: 8),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildMobileList(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('重试')),
          ],
        ),
      );
    }

    if (_dataList.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _dataList.length,
              itemBuilder: (context, index) => _buildTokenCard(_dataList[index]),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('共 $_totalCount 条'),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 1
                        ? () {
                            setState(() => _currentPage--);
                            _loadData();
                          }
                        : null,
                  ),
                  Text('$_currentPage / ${(_totalCount / _pageSize).ceil()}'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage * _pageSize < _totalCount
                        ? () {
                            setState(() => _currentPage++);
                            _loadData();
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTokenCard(OAuth2Token item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getUserTypeColor(item.userType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.userType == 1 ? Icons.admin_panel_settings : Icons.person,
                    color: _getUserTypeColor(item.userType),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('用户 ${item.userId ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getUserTypeColor(item.userType).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getUserTypeText(item.userType),
                              style: TextStyle(
                                color: _getUserTypeColor(item.userType),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '客户端: ${item.clientId ?? '-'}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.vpn_key, '访问令牌', _truncateToken(item.accessToken)),
            _buildInfoRow(Icons.refresh, '刷新令牌', _truncateToken(item.refreshToken)),
            _buildInfoRow(Icons.access_time, '创建时间', item.createTime ?? '-'),
            _buildInfoRow(Icons.schedule, '过期时间', item.expiresTime ?? '-'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _delete(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('删除令牌'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            const Text('每页: '),
            DropdownButton<int>(
              value: _pageSize,
              items: [10, 20, 50, 100].map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _pageSize = value;
                    _currentPage = 1;
                  });
                  _loadData();
                }
              },
            ),
          ],
        ),
        const SizedBox(width: 24),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 1
                  ? () {
                      setState(() => _currentPage--);
                      _loadData();
                    }
                  : null,
            ),
            Text('$_currentPage / ${(_totalCount / _pageSize).ceil()}'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _currentPage * _pageSize < _totalCount
                  ? () {
                      setState(() => _currentPage++);
                      _loadData();
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}