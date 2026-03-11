import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../api/system/notify_message_api.dart';
import '../../../models/system/notify_message.dart';
import '../../../i18n/i18n.dart';

/// 站内信消息管理页面 - 管理员视角
class NotifyMessagePage extends ConsumerStatefulWidget {
  const NotifyMessagePage({super.key});

  @override
  ConsumerState<NotifyMessagePage> createState() => _NotifyMessagePageState();
}

class _NotifyMessagePageState extends ConsumerState<NotifyMessagePage> {
  final _userIdController = TextEditingController();
  final _templateCodeController = TextEditingController();
  DateTimeRange? _createTimeRange;
  int? _selectedUserType;
  int? _selectedTemplateType;

  List<NotifyMessage> _messageList = [];
  Set<int> _selectedIds = {};
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMessageList();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _templateCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadMessageList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(notifyMessageApiProvider);
      final params = <String, dynamic>{
        'pageNo': _currentPage,
        'pageSize': _pageSize,
      };

      if (_userIdController.text.isNotEmpty) {
        params['userId'] = int.tryParse(_userIdController.text);
      }
      if (_selectedUserType != null) {
        params['userType'] = _selectedUserType;
      }
      if (_templateCodeController.text.isNotEmpty) {
        params['templateCode'] = _templateCodeController.text;
      }
      if (_selectedTemplateType != null) {
        params['templateType'] = _selectedTemplateType;
      }
      if (_createTimeRange != null) {
        params['createTime'] = _formatDate(_createTimeRange!.start);
        params['createTimeEnd'] = _formatDate(_createTimeRange!.end);
      }

      final response = await api.getNotifyMessagePage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _messageList = response.data!.list;
          _totalCount = response.data!.total;
          _isLoading = false;
          _selectedIds.clear();
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
    _loadMessageList();
  }

  void _reset() {
    _userIdController.clear();
    _templateCodeController.clear();
    setState(() {
      _createTimeRange = null;
      _selectedUserType = null;
      _selectedTemplateType = null;
    });
    _currentPage = 1;
    _loadMessageList();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getUserTypeText(int? type) {
    switch (type) {
      case 1:
        return '管理员';
      case 2:
        return '会员';
      default:
        return '-';
    }
  }

  String _getTemplateTypeText(int? type) {
    switch (type) {
      case 1:
        return '站内信';
      case 2:
        return '邮件';
      case 3:
        return '短信';
      default:
        return '-';
    }
  }

  void _showDetailDialog(NotifyMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.message, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('站内信详情'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('编号', message.id?.toString() ?? '-'),
                _buildDetailItem('用户类型', _getUserTypeText(message.userType)),
                _buildDetailItem('用户编号', message.userId?.toString() ?? '-'),
                _buildDetailItem('模板编号', message.templateId?.toString() ?? '-'),
                _buildDetailItem('模板编码', message.templateCode ?? '-'),
                _buildDetailItem('发送人名称', message.templateNickname ?? '-'),
                const Divider(),
                _buildDetailItem('模板内容', message.templateContent ?? '-', maxLines: 10),
                const Divider(),
                _buildDetailItem('模板参数', message.templateParams ?? '-'),
                _buildDetailItem('模板类型', _getTemplateTypeText(message.templateType)),
                _buildDetailItem('是否已读', message.readStatus == true ? '已读' : '未读'),
                if (message.readTime != null)
                  _buildDetailItem('阅读时间', message.readTime ?? '-'),
                _buildDetailItem('创建时间', message.createTime ?? '-'),
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

  Widget _buildDetailItem(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      body: isMobile
          ? _buildMobileLayout(context)
          : _buildDesktopLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        _buildDesktopSearchBar(context),
        const Divider(height: 1),
        Expanded(child: _buildDataTable(context)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildMobileSearchBar(context),
        const Divider(height: 1),
        Expanded(child: _buildMobileList(context)),
      ],
    );
  }

  Widget _buildDesktopSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 150,
            child: TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                hintText: '用户编号',
                prefixIcon: const Icon(Icons.person, size: 18),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _search(),
            ),
          ),
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<int?>(
              value: _selectedUserType,
              decoration: const InputDecoration(
                hintText: '用户类型',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('全部')),
                DropdownMenuItem(value: 1, child: Text('管理员')),
                DropdownMenuItem(value: 2, child: Text('会员')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedUserType = value;
                });
              },
            ),
          ),
          SizedBox(
            width: 180,
            child: TextField(
              controller: _templateCodeController,
              decoration: InputDecoration(
                hintText: '模板编码',
                prefixIcon: const Icon(Icons.code, size: 18),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<int?>(
              value: _selectedTemplateType,
              decoration: const InputDecoration(
                hintText: '模版类型',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('全部')),
                DropdownMenuItem(value: 1, child: Text('站内信')),
                DropdownMenuItem(value: 2, child: Text('邮件')),
                DropdownMenuItem(value: 3, child: Text('短信')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTemplateType = value;
                });
              },
            ),
          ),
          // 创建时间范围选择
          InkWell(
            onTap: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                initialDateRange: _createTimeRange,
              );
              if (range != null) {
                setState(() {
                  _createTimeRange = range;
                });
              }
            },
            child: Container(
              width: 240,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.date_range, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _createTimeRange != null
                        ? '${_formatDate(_createTimeRange!.start)} - ${_formatDate(_createTimeRange!.end)}'
                        : S.current.createTime,
                    style: TextStyle(
                      color: _createTimeRange != null ? null : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search),
            label: Text(S.current.search),
          ),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            label: Text(S.current.reset),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _userIdController,
                  decoration: InputDecoration(
                    hintText: '用户编号',
                    prefixIcon: const Icon(Icons.person, size: 20),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _templateCodeController,
                  decoration: InputDecoration(
                    hintText: '模板编码',
                    prefixIcon: const Icon(Icons.code, size: 20),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _search,
                  icon: const Icon(Icons.search, size: 20),
                  label: Text(S.current.search),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: Text(S.current.reset),
                ),
              ),
            ],
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
            ElevatedButton(onPressed: _loadMessageList, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (_messageList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 表头工具栏
          Row(
            children: [
              Checkbox(
                value: _selectedIds.length == _messageList.length && _messageList.isNotEmpty,
                tristate: true,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedIds = _messageList.where((m) => m.id != null).map((m) => m.id!).toSet();
                    } else {
                      _selectedIds.clear();
                    }
                  });
                },
              ),
              const Text('站内信列表'),
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
              minWidth: 1100,
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
              columns: [
                DataColumn2(
                  label: Text('编号'),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text('用户类型'),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text('用户编号'),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text('模板编码'),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text('发送人名称'),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text('模版内容'),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text('模版类型'),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text('是否已读'),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text('创建时间'),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.operation),
                  size: ColumnSize.S,
                  fixedWidth: 80,
                ),
              ],
              rows: _messageList.map((message) {
                final isSelected = message.id != null && _selectedIds.contains(message.id);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    if (message.id != null) {
                      setState(() {
                        if (selected == true) {
                          _selectedIds.add(message.id!);
                        } else {
                          _selectedIds.remove(message.id!);
                        }
                      });
                    }
                  },
                  cells: [
                    DataCell(Text(message.id?.toString() ?? '-')),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: message.userType == 1
                            ? Colors.blue.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getUserTypeText(message.userType),
                        style: TextStyle(
                          color: message.userType == 1 ? Colors.blue : Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    )),
                    DataCell(Text(message.userId?.toString() ?? '-')),
                    DataCell(Text(message.templateCode ?? '-')),
                    DataCell(Text(message.templateNickname ?? '-')),
                    DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Text(
                        message.templateContent ?? '-',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    )),
                    DataCell(Text(_getTemplateTypeText(message.templateType))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: message.readStatus == true
                            ? Colors.grey.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        message.readStatus == true ? '已读' : '未读',
                        style: TextStyle(
                          color: message.readStatus == true ? Colors.grey : Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    )),
                    DataCell(Text(message.createTime ?? '-')),
                    DataCell(
                      TextButton(
                        onPressed: () => _showDetailDialog(message),
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
                        _loadMessageList();
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
                            _loadMessageList();
                          }
                        : null,
                  ),
                  Text('$_currentPage / ${(_totalCount / _pageSize).ceil()}'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage * _pageSize < _totalCount
                        ? () {
                            setState(() => _currentPage++);
                            _loadMessageList();
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

  Widget _buildMobileList(BuildContext context) {
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
            ElevatedButton(onPressed: _loadMessageList, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (_messageList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadMessageList,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messageList.length,
              itemBuilder: (context, index) {
                final message = _messageList[index];
                return _buildMessageCard(message);
              },
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
              Text('${S.current.total}: $_totalCount'),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 1
                        ? () {
                            setState(() => _currentPage--);
                            _loadMessageList();
                          }
                        : null,
                  ),
                  Text('$_currentPage / ${(_totalCount / _pageSize).ceil()}'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage * _pageSize < _totalCount
                        ? () {
                            setState(() => _currentPage++);
                            _loadMessageList();
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

  Widget _buildMessageCard(NotifyMessage message) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: message.readStatus == true
                        ? Colors.grey.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    message.readStatus == true ? '已读' : '未读',
                    style: TextStyle(
                      color: message.readStatus == true ? Colors.grey : Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message.templateNickname ?? '站内信',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: message.userType == 1
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getUserTypeText(message.userType),
                    style: TextStyle(
                      color: message.userType == 1 ? Colors.blue : Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              message.templateContent ?? '-',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.code, '模板编码', message.templateCode ?? '-'),
            _buildInfoRow(Icons.category, '模板类型', _getTemplateTypeText(message.templateType)),
            _buildInfoRow(Icons.access_time, S.current.createTime, message.createTime ?? '-'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showDetailDialog(message),
                icon: const Icon(Icons.visibility, size: 18),
                label: Text(S.current.detail),
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
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}