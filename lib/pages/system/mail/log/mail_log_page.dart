import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/../../api/system/mail_log_api.dart';
import '/../../models/system/mail_log.dart';

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

  List<MailLog> _dataList = [];
  int _totalCount = 0;
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
    _searchUserIdController.dispose();
    _searchTemplateIdController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final api = ref.read(mailLogApiProvider);
      final response = await api.getMailLogPage({
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_searchUserIdController.text.isNotEmpty)
          'userId': _searchUserIdController.text,
        if (_searchTemplateIdController.text.isNotEmpty)
          'templateId': _searchTemplateIdController.text,
        if (_selectedSendStatus != null) 'sendStatus': _selectedSendStatus,
        if (_selectedUserType != null) 'userType': _selectedUserType,
      });

      if (response.isSuccess && response.data != null) {
        setState(() {
          _dataList = response.data!.list;
          _totalCount = response.data!.total;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg ?? '加载失败')),
          );
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refresh() {
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
      body: Column(
        children: [
          _buildSearchBar(context),
          const Divider(height: 1),
          Expanded(
            child: _buildDataTable(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: TextField(
              controller: _searchUserIdController,
              decoration: const InputDecoration(
                hintText: '用户编号',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _refresh(),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 150,
            child: TextField(
              controller: _searchTemplateIdController,
              decoration: const InputDecoration(
                hintText: '模板编号',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _refresh(),
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
              items: const [
                DropdownMenuItem(value: null, child: Text('全部')),
                DropdownMenuItem(value: 1, child: Text('管理员')),
                DropdownMenuItem(value: 2, child: Text('会员')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedUserType = value;
                });
                _refresh();
              },
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 150,
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
                setState(() {
                  _selectedSendStatus = value;
                });
                _refresh();
              },
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.search),
            label: const Text('搜索'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {
              _searchUserIdController.clear();
              _searchTemplateIdController.clear();
              setState(() {
                _selectedSendStatus = null;
                _selectedUserType = null;
              });
              _refresh();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('重置'),
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
        header: const Text('邮件日志列表'),
        rowsPerPage: _pageSize,
        availableRowsPerPage: const [10, 20, 50, 100],
        onPageChanged: (page) {
          _currentPage = page ~/ _pageSize + 1;
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
          DataColumn(label: Text('编号')),
          DataColumn(label: Text('发送时间')),
          DataColumn(label: Text('接收用户')),
          DataColumn(label: Text('收件邮箱')),
          DataColumn(label: Text('邮件标题')),
          DataColumn(label: Text('发送邮箱')),
          DataColumn(label: Text('发送状态')),
          DataColumn(label: Text('模板编码')),
          DataColumn(label: Text('操作')),
        ],
        source: _MailLogDataSource(
          _dataList,
          context,
          onDetail: _showDetailDialog,
        ),
      ),
    );
  }
}

/// 数据源
class _MailLogDataSource extends DataTableSource {
  final List<MailLog> dataList;
  final BuildContext context;
  final void Function(MailLog) onDetail;

  _MailLogDataSource(
    this.dataList,
    this.context, {
    required this.onDetail,
  });

  @override
  int get rowCount => dataList.length;

  @override
  DataRow getRow(int index) {
    final item = dataList[index];
    return DataRow(
      cells: [
        DataCell(Text(item.id?.toString() ?? '-')),
        DataCell(Text(item.sendTime ?? '-')),
        DataCell(
          item.userType != null && item.userId != null
              ? Text('${_getUserTypeText(item.userType!)}(${item.userId})')
              : const Text('-'),
        ),
        DataCell(
          SizedBox(
            width: 200,
            child: Text(
              item.toMails.isNotEmpty ? item.toMails.join(', ') : '-',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 150,
            child: Text(
              item.templateTitle ?? '-',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text(item.fromMail ?? '-')),
        DataCell(_buildSendStatusTag(item.sendStatus)),
        DataCell(Text(item.templateCode ?? '-')),
        DataCell(
          TextButton(
            onPressed: () => onDetail(item),
            child: const Text('详情'),
          ),
        ),
      ],
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
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
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
        width: 800,
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
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isError ? Colors.red : null,
              ),
            ),
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