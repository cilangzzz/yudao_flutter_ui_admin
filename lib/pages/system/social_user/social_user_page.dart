import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../api/system/social_user_api.dart';
import '../../../models/system/social_user.dart';
import '../../../i18n/i18n.dart';

/// 社交用户管理页面
class SocialUserPage extends ConsumerStatefulWidget {
  const SocialUserPage({super.key});

  @override
  ConsumerState<SocialUserPage> createState() => _SocialUserPageState();
}

class _SocialUserPageState extends ConsumerState<SocialUserPage> {
  final _nicknameController = TextEditingController();
  final _openidController = TextEditingController();
  int? _selectedType;

  List<SocialUser> _dataList = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

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
    40: '抖音',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _openidController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(socialUserApiProvider);
      final params = <String, dynamic>{
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_nicknameController.text.isNotEmpty) 'nickname': _nicknameController.text,
        if (_openidController.text.isNotEmpty) 'openid': _openidController.text,
        if (_selectedType != null) 'type': _selectedType,
      };
      final response = await api.getSocialUserPage(params);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _dataList = response.data!.list;
          _totalCount = response.data!.total;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.msg.isNotEmpty ? response.msg : S.current.loadFailed;
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
    _nicknameController.clear();
    _openidController.clear();
    setState(() {
      _selectedType = null;
    });
    _currentPage = 1;
    _loadData();
  }

  void _showDetailDialog(SocialUser item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.socialUserDetail),
        content: SizedBox(
          width: 600,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem(S.current.id, item.id?.toString() ?? '-'),
                _buildDetailItem(S.current.socialPlatform, _socialTypes[item.type] ?? '-'),
                _buildDetailItem('OpenID', item.openid ?? '-'),
                _buildDetailItem(S.current.nickname, item.nickname ?? '-'),
                _buildDetailItem(S.current.avatar, '', avatarUrl: item.avatar),
                _buildDetailItem(S.current.createTime, item.createTime ?? '-'),
                _buildDetailItem(S.current.updateTime, item.updateTime ?? '-'),
                const Divider(height: 24),
                _buildJsonSection(S.current.socialToken, item.token),
                _buildJsonSection(S.current.rawTokenInfo, item.rawTokenInfo),
                _buildJsonSection(S.current.rawUserInfo, item.rawUserInfo),
                const SizedBox(height: 16),
                _buildDetailItem(S.current.lastAuthCode, item.code ?? '-'),
                _buildDetailItem(S.current.lastAuthState, item.state ?? '-'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.current.close),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {String? avatarUrl}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: avatarUrl != null && avatarUrl.isNotEmpty
                ? CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(avatarUrl),
                    onBackgroundImageError: (_, __) {},
                    child: avatarUrl.isEmpty ? const Icon(Icons.person) : null,
                  )
                : SelectableText(value),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonSection(String label, String? jsonData) {
    if (jsonData == null || jsonData.isEmpty) {
      return const SizedBox.shrink();
    }

    String displayText = jsonData;
    try {
      // 尝试格式化JSON
      final decoded = _parseJson(jsonData);
      if (decoded != null) {
        displayText = _formatJson(decoded);
      }
    } catch (_) {
      // 保持原始文本
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: SelectableText(
            displayText,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }

  dynamic _parseJson(String text) {
    try {
      // 尝试直接解析
      if (text.startsWith('{') || text.startsWith('[')) {
        return text;
      }
      return text;
    } catch (_) {
      return null;
    }
  }

  String _formatJson(String json) {
    // 简单的JSON格式化
    int indent = 0;
    final buffer = StringBuffer();
    bool inString = false;

    for (int i = 0; i < json.length; i++) {
      final char = json[i];

      if (char == '"' && (i == 0 || json[i - 1] != '\\')) {
        inString = !inString;
      }

      if (!inString) {
        if (char == '{' || char == '[') {
          buffer.write(char);
          buffer.write('\n');
          indent++;
          buffer.write('  ' * indent);
        } else if (char == '}' || char == ']') {
          buffer.write('\n');
          indent--;
          buffer.write('  ' * indent);
          buffer.write(char);
        } else if (char == ',') {
          buffer.write(char);
          buffer.write('\n');
          buffer.write('  ' * indent);
        } else if (char == ':') {
          buffer.write(char);
          buffer.write(' ');
        } else if (char != ' ' && char != '\n' && char != '\r' && char != '\t') {
          buffer.write(char);
        }
      } else {
        buffer.write(char);
      }
    }

    return buffer.toString();
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                hintText: S.current.nickname,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 200,
            child: TextField(
              controller: _openidController,
              decoration: InputDecoration(
                hintText: 'OpenID',
                prefixIcon: const Icon(Icons.vpn_key),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<int>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: S.current.socialPlatform,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(S.current.all)),
                ..._socialTypes.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))),
              ],
              onChanged: (value) {
                setState(() => _selectedType = value);
              },
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search),
            label: Text(S.current.search),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            label: Text(S.current.reset),
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
            Text('${S.current.loadFailed}: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (_dataList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 表头
          Row(
            children: [
              Text(S.current.socialUserList),
              const Spacer(),
              Text('${S.current.total}: $_totalCount'),
            ],
          ),
          const SizedBox(height: 8),
          // 表格
          Expanded(
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 800,
              smRatio: 0.75,
              lmRatio: 1.5,
              headingRowColor: WidgetStateProperty.resolveWith(
                (states) => Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              headingTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              columns: [
                DataColumn2(
                  label: Text('ID'),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.socialPlatform),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text('OpenID'),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.nickname),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.avatar),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.createTime),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.updateTime),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.operation),
                  size: ColumnSize.S,
                ),
              ],
              rows: _dataList.map((item) {
                return DataRow2(
                  cells: [
                    DataCell(Text(item.id?.toString() ?? '-')),
                    DataCell(Text(_socialTypes[item.type] ?? '-')),
                    DataCell(
                      Tooltip(
                        message: item.openid ?? '',
                        child: Text(
                          _truncateText(item.openid, 20),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text(item.nickname ?? '-')),
                    DataCell(
                      item.avatar != null && item.avatar!.isNotEmpty
                          ? CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(item.avatar!),
                              onBackgroundImageError: (_, __) {},
                              child: const Icon(Icons.person, size: 16),
                            )
                          : const CircleAvatar(
                              radius: 16,
                              child: Icon(Icons.person, size: 16),
                            ),
                    ),
                    DataCell(Text(item.createTime?.toString().substring(0, 19) ?? '-')),
                    DataCell(Text(item.updateTime?.toString().substring(0, 19) ?? '-')),
                    DataCell(
                      TextButton(
                        onPressed: () => _showDetailDialog(item),
                        child: Text(S.current.detail),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          // 分页控件
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text('${S.current.pageSize}: '),
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
          ),
        ],
      ),
    );
  }

  String _truncateText(String? text, int maxLength) {
    if (text == null || text.isEmpty) return '-';
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}