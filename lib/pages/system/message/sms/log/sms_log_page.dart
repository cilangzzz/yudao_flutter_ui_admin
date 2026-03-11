import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/api/system/sms_log_api.dart';
import 'package:yudao_flutter_ui_admin/api/system/sms_channel_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/sms_log.dart';
import 'package:yudao_flutter_ui_admin/models/system/sms_channel.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

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

  List<SmsLog> _logList = [];
  List<SmsChannel> _channelList = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChannelList();
    _loadLogList();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _templateIdController.dispose();
    super.dispose();
  }

  Future<void> _loadChannelList() async {
    try {
      final api = ref.read(smsChannelApiProvider);
      final response = await api.getSimpleSmsChannelList();
      if (response.isSuccess && response.data != null) {
        setState(() => _channelList = response.data!);
      }
    } catch (e) {
      // 渠道列表加载失败不影响日志列表
    }
  }

  Future<void> _loadLogList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(smsLogApiProvider);
      final params = <String, dynamic>{
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
          _logList = response.data!.list;
          _totalCount = response.data!.total;
          _isLoading = false;
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
    _loadLogList();
  }

  void _reset() {
    _mobileController.clear();
    _templateIdController.clear();
    setState(() {
      _selectedChannelId = null;
      _selectedSendStatus = null;
      _selectedReceiveStatus = null;
    });
    _currentPage = 1;
    _loadLogList();
  }

  void _showDetailDialog(SmsLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('短信日志详情'),
        content: SizedBox(
          width: DeviceUIMode.select(context, mobile: () => double.maxFinite, desktop: () => 600.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('创建时间', log.createTime ?? '-'),
                _buildDetailRow('手机号', log.mobile ?? '-'),
                _buildDetailRow('短信渠道', _getChannelCodeText(log.channelCode)),
                _buildDetailRow('模板编号', log.templateId?.toString() ?? '-'),
                _buildDetailRow('模板类型', _getTemplateTypeText(log.templateType)),
                _buildDetailRow('短信内容', log.templateContent ?? '-', maxLines: 3),
                _buildDetailRow('发送状态', _getSendStatusText(log.sendStatus), isSendStatus: true),
                _buildDetailRow('发送时间', log.sendTime ?? '-'),
                _buildDetailRow('API 发送编码', log.apiSendCode ?? '-'),
                _buildDetailRow('API 发送消息', log.apiSendMsg ?? '-'),
                _buildDetailRow('接收状态', _getReceiveStatusText(log.receiveStatus), isReceiveStatus: true),
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

  Widget _buildDetailRow(String label, String value, {int maxLines = 1, bool isSendStatus = false, bool isReceiveStatus = false}) {
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
            child: isSendStatus
                ? _buildSendStatusTag(_getSendStatusCode(value))
                : isReceiveStatus
                    ? _buildReceiveStatusTag(_getReceiveStatusCode(value))
                    : Text(value, maxLines: maxLines, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  int _getSendStatusCode(String text) {
    switch (text) {
      case '初始化':
        return 0;
      case '发送中':
        return 10;
      case '发送成功':
        return 20;
      case '发送失败':
        return 30;
      case '不发送':
        return 40;
      default:
        return -1;
    }
  }

  int _getReceiveStatusCode(String text) {
    switch (text) {
      case '等待接收':
        return 0;
      case '接收成功':
        return 10;
      case '接收失败':
        return 20;
      default:
        return -1;
    }
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        children: [
          SizedBox(
            width: DeviceUIMode.select(context, mobile: () => 120.0, desktop: () => 150.0),
            child: TextField(
              controller: _mobileController,
              decoration: const InputDecoration(
                hintText: '手机号',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          SizedBox(
            width: DeviceUIMode.select(context, mobile: () => 120.0, desktop: () => 180.0),
            child: DropdownButtonFormField<int>(
              value: _selectedChannelId,
              decoration: const InputDecoration(
                labelText: '短信渠道',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('全部')),
                ..._channelList.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.signature),
                    )),
              ],
              onChanged: (value) {
                setState(() => _selectedChannelId = value);
                _search();
              },
            ),
          ),
          SizedBox(
            width: DeviceUIMode.select(context, mobile: () => 100.0, desktop: () => 120.0),
            child: TextField(
              controller: _templateIdController,
              decoration: const InputDecoration(
                hintText: '模板编号',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _search(),
            ),
          ),
          SizedBox(
            width: DeviceUIMode.select(context, mobile: () => 100.0, desktop: () => 140.0),
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
                _search();
              },
            ),
          ),
          SizedBox(
            width: DeviceUIMode.select(context, mobile: () => 100.0, desktop: () => 140.0),
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
            icon: const Icon(Icons.clear),
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
                  controller: _mobileController,
                  decoration: const InputDecoration(
                    hintText: '手机号',
                    prefixIcon: Icon(Icons.phone, size: 20),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
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
                    DropdownMenuItem(value: 20, child: Text('发送成功')),
                    DropdownMenuItem(value: 30, child: Text('发送失败')),
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
                  icon: const Icon(Icons.clear, size: 20),
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
            ElevatedButton(onPressed: _loadLogList, child: const Text('重试')),
          ],
        ),
      );
    }

    if (_logList.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text('短信日志列表'),
              const Spacer(),
              Text('共 $_totalCount 条'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 1000,
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
                DataColumn2(label: Text('手机号'), size: ColumnSize.M),
                DataColumn2(label: Text('短信内容'), size: ColumnSize.L),
                DataColumn2(label: Text('发送状态'), size: ColumnSize.M),
                DataColumn2(label: Text('发送时间'), size: ColumnSize.L),
                DataColumn2(label: Text('接收状态'), size: ColumnSize.M),
                DataColumn2(label: Text('接收时间'), size: ColumnSize.L),
                DataColumn2(label: Text('渠道'), size: ColumnSize.M),
                DataColumn2(label: Text('操作'), size: ColumnSize.S),
              ],
              rows: _logList.map((log) {
                return DataRow2(
                  cells: [
                    DataCell(Text(log.id?.toString() ?? '-')),
                    DataCell(Text(log.mobile ?? '-')),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
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
                    DataCell(Text(_getChannelCodeText(log.channelCode))),
                    DataCell(
                      TextButton(
                        onPressed: () => _showDetailDialog(log),
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
            ElevatedButton(onPressed: _loadLogList, child: const Text('重试')),
          ],
        ),
      );
    }

    if (_logList.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return RefreshIndicator(
      onRefresh: _loadLogList,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _logList.length,
        itemBuilder: (context, index) {
          final log = _logList[index];
          return _buildLogCard(log);
        },
      ),
    );
  }

  Widget _buildLogCard(SmsLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildSendStatusTag(log.sendStatus),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    log.mobile ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                _buildReceiveStatusTag(log.receiveStatus),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              log.templateContent ?? '-',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.sms, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _getChannelCodeText(log.channelCode),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  log.sendTime ?? '-',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showDetailDialog(log),
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('详情'),
              ),
            ),
          ],
        ),
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
                  _loadLogList();
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
                      _loadLogList();
                    }
                  : null,
            ),
            Text('$_currentPage / ${(_totalCount / _pageSize).ceil()}'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _currentPage * _pageSize < _totalCount
                  ? () {
                      setState(() => _currentPage++);
                      _loadLogList();
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSendStatusTag(int? status) {
    String text = _getSendStatusText(status);
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
    String text = _getReceiveStatusText(status);
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
}