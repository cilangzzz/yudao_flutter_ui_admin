import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/notify_message_api.dart';
import '../../../models/system/notify_message.dart';

/// 通知消息管理页面
class NotifyMessagePage extends ConsumerStatefulWidget {
  const NotifyMessagePage({super.key});

  @override
  ConsumerState<NotifyMessagePage> createState() => _NotifyMessagePageState();
}

class _NotifyMessagePageState extends ConsumerState<NotifyMessagePage> {
  List<NotifyMessage> _messages = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _total = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final api = ref.read(notifyMessageApiProvider);
      final response = await api.getNotifyMessagePage({
        'pageNo': _currentPage,
        'pageSize': _pageSize,
      });

      if (response.isSuccess && response.data != null) {
        setState(() {
          _messages = response.data!.list;
          _total = response.data!.total;
        });
      } else {
        _showError(response.msg ?? '加载失败');
      }
    } catch (e) {
      _showError('加载异常: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showMessageDetail(NotifyMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message.templateNickname ?? '通知消息',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('消息ID', message.id?.toString() ?? '-'),
              _buildDetailRow('模板编码', message.templateCode ?? '-'),
              _buildDetailRow('模板名称', message.templateNickname ?? '-'),
              const Divider(),
              _buildDetailRow('消息内容', message.templateContent ?? '-', maxLines: 10),
              const Divider(),
              _buildDetailRow('模板类型', _getTemplateTypeText(message.templateType)),
              _buildDetailRow('阅读状态', message.readStatus == true ? '已读' : '未读'),
              if (message.readTime != null)
                _buildDetailRow('阅读时间', message.readTime ?? '-'),
              _buildDetailRow('创建时间', message.createTime ?? '-'),
            ],
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

  Widget _buildDetailRow(String label, String value, {int maxLines = 1}) {
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

  String _getTemplateTypeText(int? type) {
    switch (type) {
      case 1:
        return '站内信';
      case 2:
        return '邮件';
      case 3:
        return '短信';
      default:
        return '未知';
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
          Text(
            '通知消息管理',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('刷新'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text('暂无消息'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PaginatedDataTable(
        header: const Text('消息列表'),
        rowsPerPage: _pageSize,
        availableRowsPerPage: const [10, 20, 50],
        onPageChanged: (page) {
          _currentPage = page + 1;
          _loadData();
        },
        total: _total,
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('模板编码')),
          DataColumn(label: Text('模板名称')),
          DataColumn(label: Text('消息内容')),
          DataColumn(label: Text('模板类型')),
          DataColumn(label: Text('阅读状态')),
          DataColumn(label: Text('创建时间')),
          DataColumn(label: Text('操作')),
        ],
        source: _NotifyMessageDataSource(
          _messages,
          context,
          onDetail: _showMessageDetail,
          getTemplateTypeText: _getTemplateTypeText,
        ),
      ),
    );
  }
}

/// 通知消息数据源
class _NotifyMessageDataSource extends DataTableSource {
  final List<NotifyMessage> messages;
  final BuildContext context;
  final void Function(NotifyMessage)? onDetail;
  final String Function(int?) getTemplateTypeText;

  _NotifyMessageDataSource(
    this.messages,
    this.context, {
    this.onDetail,
    required this.getTemplateTypeText,
  });

  @override
  int get rowCount => messages.length;

  @override
  DataRow getRow(int index) {
    final message = messages[index];
    return DataRow(
      cells: [
        DataCell(Text(message.id?.toString() ?? '')),
        DataCell(Text(message.templateCode ?? '-')),
        DataCell(Text(message.templateNickname ?? '-')),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              message.templateContent ?? '-',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        DataCell(Text(getTemplateTypeText(message.templateType))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: message.readStatus == true
                  ? Colors.grey.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              message.readStatus == true ? '已读' : '未读',
              style: TextStyle(
                color: message.readStatus == true ? Colors.grey : Colors.blue,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(Text(message.createTime ?? '-')),
        DataCell(
          TextButton(
            onPressed: () => onDetail?.call(message),
            child: const Text('查看'),
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