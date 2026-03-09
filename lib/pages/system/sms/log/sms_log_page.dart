import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/../../api/system/sms_log_api.dart';
import '/../../api/system/sms_channel_api.dart';
import '/../../models/system/sms_log.dart';
import '/../../models/system/sms_channel.dart';

/// 短信日志管理页面
class SmsLogPage extends ConsumerStatefulWidget {
  const SmsLogPage({super.key});

  @override
  ConsumerState<SmsLogPage> createState() => _SmsLogPageState();
}

class _SmsLogPageState extends ConsumerState<SmsLogPage> {
  final _mobileController = TextEditingController();
  final _templateIdController = TextEditingController();
  int? _selectedChannelId;
  int? _selectedSendStatus;
  int? _selectedReceiveStatus;

  List<SmsLog> _logs = [];
  List<SmsChannel> _channels = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _pageSize = 10;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _loadChannels();
    _loadData();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _templateIdController.dispose();
    super.dispose();
  }

  Future<void> _loadChannels() async {
    try {
      final api = ref.read(smsChannelApiProvider);
      final response = await api.getSimpleSmsChannelList();
      if (response.isSuccess && response.data != null) {
        setState(() => _channels = response.data!);
      }
    } catch (e) {
      // Ignore error for channel loading
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final api = ref.read(smsLogApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_mobileController.text.isNotEmpty) 'mobile': _mobileController.text,
        if (_selectedChannelId != null) 'channelId': _selectedChannelId,
        if (_templateIdController.text.isNotEmpty)
          'templateId': int.tryParse(_templateIdController.text),
        if (_selectedSendStatus != null) 'sendStatus': _selectedSendStatus,
        if (_selectedReceiveStatus != null) 'receiveStatus': _selectedReceiveStatus,
      };

      final response = await api.getSmsLogPage(params);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _logs = response.data!.list;
          _total = response.data!.total;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _refresh() {
    _currentPage = 1;
    _loadData();
  }

  void _showDetailDialog(SmsLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('短信日志详情'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('创建时间', log.createTime ?? '-'),
                _buildDetailRow('手机号', log.mobile ?? '-'),
                _buildDetailRow('短信渠道', log.channelCode ?? '-'),
                _buildDetailRow('模板编号', log.templateId?.toString() ?? '-'),
                _buildDetailRow('模板类型', _getTemplateTypeText(log.templateType)),
                _buildDetailRow('短信内容', log.templateContent ?? '-', maxLines: 3),
                _buildDetailRow('发送状态', _getSendStatusText(log.sendStatus), isStatus: true),
                _buildDetailRow('发送时间', log.sendTime ?? '-'),
                _buildDetailRow('API 发送编码', log.apiSendCode ?? '-'),
                _buildDetailRow('API 发送消息', log.apiSendMsg ?? '-'),
                _buildDetailRow('接收状态', _getReceiveStatusText(log.receiveStatus), isStatus: true),
                _buildDetailRow('接收时间', log.receiveTime ?? '-'),
                _buildDetailRow('API 接收编码', log.apiReceiveCode ?? '-'),
                _buildDetailRow('API 接收消息', log.apiReceiveMsg ?? '-'),
                _buildDetailRow('API 请求 ID', log.apiRequestId ?? '-'),
                _buildDetailRow('API 序列号', log.apiSerialNo ?? '-'),
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

  Widget _buildDetailRow(String label, String value, {int maxLines = 1, bool isStatus = false}) {
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
            child: isStatus
                ? _buildStatusBadge(value)
                : Text(value, maxLines: maxLines, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String statusText) {
    Color color;
    if (statusText.contains('成功') || statusText.contains('已接收')) {
      color = Colors.green;
    } else if (statusText.contains('失败') || statusText.contains('拒绝')) {
      color = Colors.red;
    } else {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        statusText,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  String _getTemplateTypeText(int? type) {
    switch (type) {
      case 1:
        return '验证码';
      case 2:
        return '通知';
      case 3:
        return '营销';
      default:
        return '-';
    }
  }

  String _getSendStatusText(int? status) {
    switch (status) {
      case 0:
        return '初始化';
      case 10:
        return '发送中';
      case 20:
        return '发送成功';
      case 30:
        return '发送失败';
      case 40:
        return '不发送';
      default:
        return '-';
    }
  }

  String _getReceiveStatusText(int? status) {
    switch (status) {
      case 0:
        return '等待接收';
      case 10:
        return '接收成功';
      case 20:
        return '接收失败';
      default:
        return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(context),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildDataTable(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 150,
            child: TextField(
              controller: _mobileController,
              decoration: const InputDecoration(
                hintText: '手机号',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _refresh(),
            ),
          ),
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<int>(
              value: _selectedChannelId,
              decoration: const InputDecoration(
                labelText: '短信渠道',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('全部')),
                ..._channels.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.signature),
                    )),
              ],
              onChanged: (value) {
                setState(() => _selectedChannelId = value);
                _refresh();
              },
            ),
          ),
          SizedBox(
            width: 120,
            child: TextField(
              controller: _templateIdController,
              decoration: const InputDecoration(
                hintText: '模板编号',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _refresh(),
            ),
          ),
          SizedBox(
            width: 140,
            child: DropdownButtonFormField<int>(
              value: _selectedSendStatus,
              decoration: const InputDecoration(
                labelText: '发送状态',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('全部')),
                DropdownMenuItem(value: 0, child: Text('初始化')),
                DropdownMenuItem(value: 10, child: Text('发送中')),
                DropdownMenuItem(value: 20, child: Text('发送成功')),
                DropdownMenuItem(value: 30, child: Text('发送失败')),
              ],
              onChanged: (value) {
                setState(() => _selectedSendStatus = value);
                _refresh();
              },
            ),
          ),
          SizedBox(
            width: 140,
            child: DropdownButtonFormField<int>(
              value: _selectedReceiveStatus,
              decoration: const InputDecoration(
                labelText: '接收状态',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('全部')),
                DropdownMenuItem(value: 0, child: Text('等待接收')),
                DropdownMenuItem(value: 10, child: Text('接收成功')),
                DropdownMenuItem(value: 20, child: Text('接收失败')),
              ],
              onChanged: (value) {
                setState(() => _selectedReceiveStatus = value);
                _refresh();
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.search),
            label: const Text('搜索'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              _mobileController.clear();
              _templateIdController.clear();
              setState(() {
                _selectedChannelId = null;
                _selectedSendStatus = null;
                _selectedReceiveStatus = null;
              });
              _refresh();
            },
            icon: const Icon(Icons.clear),
            label: const Text('重置'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PaginatedDataTable(
        header: Row(
          children: [
            const Text('短信日志列表'),
            const Spacer(),
            Text('共 $_total 条记录', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        rowsPerPage: _pageSize,
        availableRowsPerPage: const [10, 20, 50, 100],
        onPageChanged: (page) {
          _currentPage = (page ~/ _pageSize) + 1;
          _loadData();
        },
        onRowsPerPageChanged: (value) {
          setState(() => _pageSize = value ?? 10);
          _loadData();
        },
        columns: const [
          DataColumn(label: Text('编号')),
          DataColumn(label: Text('手机号')),
          DataColumn(label: Text('短信内容')),
          DataColumn(label: Text('发送状态')),
          DataColumn(label: Text('发送时间')),
          DataColumn(label: Text('接收状态')),
          DataColumn(label: Text('接收时间')),
          DataColumn(label: Text('渠道')),
          DataColumn(label: Text('操作')),
        ],
        source: _SmsLogDataSource(
          _logs,
          context,
          onDetail: _showDetailDialog,
          getSendStatusText: _getSendStatusText,
          getReceiveStatusText: _getReceiveStatusText,
          getChannelCodeText: _getChannelCodeText,
        ),
      ),
    );
  }

  String _getChannelCodeText(String? code) {
    switch (code) {
      case 'aliyun':
        return '阿里云';
      case 'tencent':
        return '腾讯云';
      case 'huawei':
        return '华为云';
      case 'yunpian':
        return '云片';
      default:
        return code ?? '-';
    }
  }
}

/// 数据源
class _SmsLogDataSource extends DataTableSource {
  final List<SmsLog> logs;
  final BuildContext context;
  final void Function(SmsLog) onDetail;
  final String Function(int?) getSendStatusText;
  final String Function(int?) getReceiveStatusText;
  final String Function(String?) getChannelCodeText;

  _SmsLogDataSource(
    this.logs,
    this.context, {
    required this.onDetail,
    required this.getSendStatusText,
    required this.getReceiveStatusText,
    required this.getChannelCodeText,
  });

  @override
  int get rowCount => logs.length;

  @override
  DataRow getRow(int index) {
    final log = logs[index];
    return DataRow(
      cells: [
        DataCell(Text(log.id?.toString() ?? '-')),
        DataCell(Text(log.mobile ?? '-')),
        DataCell(
          SizedBox(
            width: 200,
            child: Text(
              log.templateContent ?? '-',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        DataCell(_buildSendStatusTag(log.sendStatus)),
        DataCell(Text(log.sendTime ?? '-')),
        DataCell(_buildReceiveStatusTag(log.receiveStatus)),
        DataCell(Text(log.receiveTime ?? '-')),
        DataCell(Text(getChannelCodeText(log.channelCode))),
        DataCell(
          TextButton(
            onPressed: () => onDetail(log),
            child: const Text('详情'),
          ),
        ),
      ],
    );
  }

  Widget _buildSendStatusTag(int? status) {
    String text = getSendStatusText(status);
    Color color;
    switch (status) {
      case 20:
        color = Colors.green;
        break;
      case 30:
        color = Colors.red;
        break;
      case 10:
        color = Colors.blue;
        break;
      default:
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

  Widget _buildReceiveStatusTag(int? status) {
    String text = getReceiveStatusText(status);
    Color color;
    switch (status) {
      case 10:
        color = Colors.green;
        break;
      case 20:
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
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

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}