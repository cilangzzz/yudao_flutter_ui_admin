import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/api/system/mail_log_api.dart';
import 'package:yudao_flutter_ui_admin/api/system/mail_account_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/mail_log.dart';
import 'package:yudao_flutter_ui_admin/models/system/mail_account.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 邮件日志页面
class MailLogPage extends ConsumerStatefulWidget {
  const MailLogPage({super.key});

  @override
  ConsumerState<MailLogPage> createState() => _MailLogPageState();
}

class _MailLogPageState extends ConsumerState<MailLogPage> {
  final _searchUserIdController = TextEditingController();
  final _searchTemplateIdController = TextEditingController();
  int? _selectedSendStatus;
  int? _selectedUserType;
  int? _selectedAccountId;

  List<MailLog> _dataList = [];
  List<MailAccount> _accountList = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAccountList();
    _loadData();
  }

  @override
  void dispose() {
    _searchUserIdController.dispose();
    _searchTemplateIdController.dispose();
    super.dispose();
  }

  Future<void> _loadAccountList() async {
    try {
      final api = ref.read(mailAccountApiProvider);
      final response = await api.getSimpleMailAccountList();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _accountList = response.data!;
        });
      }
    } catch (e) {
      // 忽略错误
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(mailLogApiProvider);
      final response = await api.getMailLogPage({
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_searchUserIdController.text.isNotEmpty) 'userId': _searchUserIdController.text,
        if (_searchTemplateIdController.text.isNotEmpty) 'templateId': _searchTemplateIdController.text,
        if (_selectedSendStatus != null) 'sendStatus': _selectedSendStatus,
        if (_selectedUserType != null) 'userType': _selectedUserType,
        if (_selectedAccountId != null) 'accountId': _selectedAccountId,
      });

      if (response.isSuccess && response.data != null) {
        setState(() {
          _dataList = response.data!.list;
          _totalCount = response.data!.total;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.msg ?? '加载失败';
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
    _searchUserIdController.clear();
    _searchTemplateIdController.clear();
    setState(() {
      _selectedSendStatus = null;
      _selectedUserType = null;
      _selectedAccountId = null;
    });
    _currentPage = 1;
    _loadData();
  }

  void _showDetailDialog(MailLog log) {
    showDialog(
      context: context,
      builder: (context) => _MailLogDetailDialog(log: log),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DeviceUIMode.builder(
        context,
        mobile: (context) => _buildMobileLayout(context),
        desktop: (context) => _buildDesktopLayout(context),
      ),
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
    final searchWidth = DeviceUIMode.select(context, mobile: () => 120.0, desktop: () => 150.0);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: searchWidth,
            child: TextField(
              controller: _searchUserIdController,
              decoration: const InputDecoration(
                hintText: '用户编号',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          SizedBox(
            width: searchWidth,
            child: TextField(
              controller: _searchTemplateIdController,
              decoration: const InputDecoration(
                hintText: '模板编号',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          SizedBox(
            width: searchWidth,
            child: DropdownButtonFormField<int>(
              value: _selectedUserType,
              decoration: const InputDecoration(
                labelText: '用户类型',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('全部')),
                DropdownMenuItem(value: 1, child: Text('管理员')),
                DropdownMenuItem(value: 2, child: Text('会员')),
              ],
              onChanged: (value) {
                setState(() => _selectedUserType = value);
                _search();
              },
            ),
          ),
          SizedBox(
            width: searchWidth,
            child: DropdownButtonFormField<int>(
              value: _selectedSendStatus,
              decoration: const InputDecoration(
                labelText: '发送状态',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('全部')),
                DropdownMenuItem(value: 0, child: Text('发送中')),
                DropdownMenuItem(value: 10, child: Text('发送成功')),
                DropdownMenuItem(value: 20, child: Text('发送失败')),
                DropdownMenuItem(value: 30, child: Text('不发送')),
              ],
              onChanged: (value) {
                setState(() => _selectedSendStatus = value);
                _search();
              },
            ),
          ),
          SizedBox(
            width: DeviceUIMode.select(context, mobile: () => 150.0, desktop: () => 200.0),
            child: DropdownButtonFormField<int>(
              value: _selectedAccountId,
              decoration: const InputDecoration(
                labelText: '邮箱账号',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('全部')),
                ..._accountList.map((a) => DropdownMenuItem(
                      value: a.id,
                      child: Text(a.mail),
                    )),
              ],
              onChanged: (value) {
                setState(() => _selectedAccountId = value);
                _search();
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search),
            label: const Text('搜索'),
          ),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            label: const Text('重置'),
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
                  controller: _searchUserIdController,
                  decoration: const InputDecoration(
                    hintText: '用户编号',
                    prefixIcon: Icon(Icons.person, size: 20),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchTemplateIdController,
                  decoration: const InputDecoration(
                    hintText: '模板编号',
                    prefixIcon: Icon(Icons.description, size: 20),
                    border: OutlineInputBorder(),
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
                child: DropdownButtonFormField<int>(
                  value: _selectedSendStatus,
                  decoration: const InputDecoration(
                    hintText: '发送状态',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('全部')),
                    DropdownMenuItem(value: 0, child: Text('发送中')),
                    DropdownMenuItem(value: 10, child: Text('发送成功')),
                    DropdownMenuItem(value: 20, child: Text('发送失败')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedSendStatus = value);
                    _search();
                  },
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
                  label: const Text('搜索'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('重置'),
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
          Row(
            children: [
              const Text('邮件日志列表'),
              const Spacer(),
              Text('共 $_totalCount 条'),
            ],
          ),
          const SizedBox(height: 8),
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
              columns: const [
                DataColumn2(label: Text('编号'), size: ColumnSize.S),
                DataColumn2(label: Text('发送时间'), size: ColumnSize.L),
                DataColumn2(label: Text('接收用户'), size: ColumnSize.M),
                DataColumn2(label: Text('收件邮箱'), size: ColumnSize.L),
                DataColumn2(label: Text('邮件标题'), size: ColumnSize.M),
                DataColumn2(label: Text('发送邮箱'), size: ColumnSize.M),
                DataColumn2(label: Text('发送状态'), size: ColumnSize.S),
                DataColumn2(label: Text('模板编码'), size: ColumnSize.M),
                DataColumn2(label: Text('操作'), size: ColumnSize.S),
              ],
              rows: _dataList.map((item) {
                return DataRow2(
                  cells: [
                    DataCell(Text(item.id?.toString() ?? '-')),
                    DataCell(Text(item.sendTime ?? '-')),
                    DataCell(
                      item.userType != null && item.userId != null
                          ? Text('${_getUserTypeText(item.userType!)}(${item.userId})')
                          : const Text('-'),
                    ),
                    DataCell(
                      Tooltip(
                        message: item.toMails.isNotEmpty ? item.toMails.join(', ') : '-',
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            item.toMails.isNotEmpty ? item.toMails.join(', ') : '-',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Tooltip(
                        message: item.templateTitle ?? '-',
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: Text(
                            item.templateTitle ?? '-',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(item.fromMail ?? '-')),
                    DataCell(_buildSendStatusTag(item.sendStatus)),
                    DataCell(Text(item.templateCode ?? '-')),
                    DataCell(
                      TextButton(
                        onPressed: () => _showDetailDialog(item),
                        child: const Text('详情'),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
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

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _dataList.length,
        itemBuilder: (context, index) {
          final item = _dataList[index];
          return _buildLogCard(item);
        },
      ),
    );
  }

  Widget _buildLogCard(MailLog item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildSendStatusTag(item.sendStatus),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.templateTitle ?? '邮件',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '收件人: ${item.toMails.isNotEmpty ? item.toMails.join(', ') : '-'}',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              '发送邮箱: ${item.fromMail ?? '-'}',
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  item.sendTime ?? '-',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showDetailDialog(item),
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('详情'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getUserTypeText(int userType) {
    switch (userType) {
      case 1:
        return '管理员';
      case 2:
        return '会员';
      default:
        return '未知';
    }
  }

  Widget _buildSendStatusTag(int? status) {
    String text;
    Color color;

    switch (status) {
      case 0:
        text = '发送中';
        color = Colors.blue;
        break;
      case 10:
        text = '发送成功';
        color = Colors.green;
        break;
      case 20:
        text = '发送失败';
        color = Colors.red;
        break;
      case 30:
        text = '不发送';
        color = Colors.grey;
        break;
      default:
        text = '未知';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
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
                return DropdownMenuItem(value: value, child: Text('$value'));
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

/// 邮件日志详情对话框
class _MailLogDetailDialog extends StatelessWidget {
  final MailLog log;

  const _MailLogDetailDialog({required this.log});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('邮件日志详情'),
      content: SizedBox(
        width: DeviceUIMode.select(context, mobile: () => double.maxFinite, desktop: () => 800.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow('编号', log.id?.toString() ?? '-'),
              _buildRow('创建时间', log.createTime ?? '-'),
              _buildRow('发送邮箱', log.fromMail ?? '-'),
              _buildRow(
                '接收用户',
                log.userType != null && log.userId != null
                    ? '${_getUserTypeText(log.userType!)}(${log.userId})'
                    : '-',
              ),
              _buildRow(
                '收件邮箱',
                log.toMails.isNotEmpty ? log.toMails.join(', ') : '-',
              ),
              _buildRow(
                '抄送邮箱',
                log.ccMails != null && log.ccMails!.isNotEmpty
                    ? log.ccMails!.join(', ')
                    : '-',
              ),
              _buildRow(
                '密送邮箱',
                log.bccMails != null && log.bccMails!.isNotEmpty
                    ? log.bccMails!.join(', ')
                    : '-',
              ),
              _buildRow('模板编号', log.templateId?.toString() ?? '-'),
              _buildRow('模板编码', log.templateCode ?? '-'),
              _buildRow('邮件标题', log.templateTitle ?? '-'),
              const SizedBox(height: 8),
              const Text('邮件内容:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(log.templateContent ?? '-'),
              ),
              const SizedBox(height: 16),
              _buildRow('发送状态', _getSendStatusText(log.sendStatus)),
              _buildRow('发送时间', log.sendTime ?? '-'),
              _buildRow('发送消息编号', log.sendMessageId ?? '-'),
              if (log.sendException != null && log.sendException!.isNotEmpty)
                _buildRow('发送异常', log.sendException!, isError: true),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: isError ? Colors.red : null)),
          ),
        ],
      ),
    );
  }

  String _getUserTypeText(int userType) {
    switch (userType) {
      case 1:
        return '管理员';
      case 2:
        return '会员';
      default:
        return '未知';
    }
  }

  String _getSendStatusText(int? status) {
    switch (status) {
      case 0:
        return '发送中';
      case 10:
        return '发送成功';
      case 20:
        return '发送失败';
      case 30:
        return '不发送';
      default:
        return '未知';
    }
  }
}