import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/sms_channel_api.dart';
import '../../../core/api_client.dart';
import '../../../models/system/sms_channel.dart';

/// 短信渠道管理页面
class SmsChannelPage extends ConsumerStatefulWidget {
  const SmsChannelPage({super.key});

  @override
  ConsumerState<SmsChannelPage> createState() => _SmsChannelPageState();
}

class _SmsChannelPageState extends ConsumerState<SmsChannelPage> {
  final _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedCode;

  List<SmsChannel> _channels = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _pageSize = 10;
  int _total = 0;

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
    setState(() => _isLoading = true);

    try {
      final api = ref.read(smsChannelApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_searchController.text.isNotEmpty) 'signature': _searchController.text,
        if (_selectedStatus != null) 'status': int.parse(_selectedStatus!),
        if (_selectedCode != null) 'code': _selectedCode,
      };

      final response = await api.getSmsChannelPage(params);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _channels = response.data!.list;
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

  Future<void> _deleteChannel(SmsChannel channel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除短信渠道 "${channel.signature}" 吗？'),
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
        final api = ref.read(smsChannelApiProvider);
        final response = await api.deleteSmsChannel(channel.id!);
        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('删除成功')),
            );
          }
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

  void _showChannelDialog([SmsChannel? channel]) {
    final isEdit = channel != null;
    final signatureController = TextEditingController(text: channel?.signature ?? '');
    final codeController = TextEditingController(text: channel?.code ?? '');
    final apiKeyController = TextEditingController(text: channel?.apiKey ?? '');
    final apiSecretController = TextEditingController(text: channel?.apiSecret ?? '');
    final callbackUrlController = TextEditingController(text: channel?.callbackUrl ?? '');
    final remarkController = TextEditingController(text: channel?.remark ?? '');
    int status = channel?.status ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? '编辑短信渠道' : '添加短信渠道'),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: signatureController,
                    decoration: const InputDecoration(
                      labelText: '短信签名 *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: codeController.text.isEmpty ? null : codeController.text,
                    decoration: const InputDecoration(
                      labelText: '渠道编码 *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'aliyun', child: Text('阿里云')),
                      DropdownMenuItem(value: 'tencent', child: Text('腾讯云')),
                      DropdownMenuItem(value: 'huawei', child: Text('华为云')),
                      DropdownMenuItem(value: 'yunpian', child: Text('云片')),
                    ],
                    onChanged: (value) => codeController.text = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: status,
                    decoration: const InputDecoration(
                      labelText: '启用状态',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('开启')),
                      DropdownMenuItem(value: 1, child: Text('关闭')),
                    ],
                    onChanged: (value) => setState(() => status = value ?? 0),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: apiKeyController,
                    decoration: const InputDecoration(
                      labelText: '短信 API 的账号 *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: apiSecretController,
                    decoration: const InputDecoration(
                      labelText: '短信 API 的密钥',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: callbackUrlController,
                    decoration: const InputDecoration(
                      labelText: '短信发送回调 URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: remarkController,
                    decoration: const InputDecoration(
                      labelText: '备注',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (signatureController.text.isEmpty ||
                    codeController.text.isEmpty ||
                    apiKeyController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请填写必填项')),
                  );
                  return;
                }

                final data = SmsChannel(
                  id: channel?.id,
                  signature: signatureController.text,
                  code: codeController.text,
                  status: status,
                  apiKey: apiKeyController.text,
                  apiSecret: apiSecretController.text.isEmpty ? null : apiSecretController.text,
                  callbackUrl: callbackUrlController.text.isEmpty ? null : callbackUrlController.text,
                  remark: remarkController.text.isEmpty ? null : remarkController.text,
                );

                try {
                  final api = ref.read(smsChannelApiProvider);
                  final response = isEdit
                      ? await api.updateSmsChannel(data)
                      : await api.createSmsChannel(data);

                  if (response.isSuccess) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEdit ? '修改成功' : '添加成功')),
                      );
                    }
                    _loadData();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('操作失败: $e')),
                    );
                  }
                }
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildDataTable(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showChannelDialog(),
        icon: const Icon(Icons.add),
        label: const Text('添加渠道'),
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
                hintText: '搜索短信签名',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _refresh(),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<String>(
              value: _selectedCode,
              decoration: const InputDecoration(
                labelText: '渠道编码',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('全部')),
                DropdownMenuItem(value: 'aliyun', child: Text('阿里云')),
                DropdownMenuItem(value: 'tencent', child: Text('腾讯云')),
                DropdownMenuItem(value: 'huawei', child: Text('华为云')),
                DropdownMenuItem(value: 'yunpian', child: Text('云片')),
              ],
              onChanged: (value) {
                setState(() => _selectedCode = value);
                _refresh();
              },
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 120,
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: '状态',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('全部')),
                DropdownMenuItem(value: '0', child: Text('开启')),
                DropdownMenuItem(value: '1', child: Text('关闭')),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                _refresh();
              },
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PaginatedDataTable(
        header: const Text('短信渠道列表'),
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
          DataColumn(label: Text('短信签名')),
          DataColumn(label: Text('渠道编码')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('API 账号')),
          DataColumn(label: Text('创建时间')),
          DataColumn(label: Text('操作')),
        ],
        source: _SmsChannelDataSource(
          _channels,
          context,
          onEdit: _showChannelDialog,
          onDelete: _deleteChannel,
        ),
      ),
    );
  }
}

/// 数据源
class _SmsChannelDataSource extends DataTableSource {
  final List<SmsChannel> channels;
  final BuildContext context;
  final void Function(SmsChannel) onEdit;
  final void Function(SmsChannel) onDelete;

  _SmsChannelDataSource(
    this.channels,
    this.context, {
    required this.onEdit,
    required this.onDelete,
  });

  @override
  int get rowCount => channels.length;

  @override
  DataRow getRow(int index) {
    final channel = channels[index];
    return DataRow(
      cells: [
        DataCell(Text(channel.id?.toString() ?? '-')),
        DataCell(Text(channel.signature)),
        DataCell(_buildChannelCodeTag(channel.code)),
        DataCell(_buildStatusTag(channel.status)),
        DataCell(Text(channel.apiKey)),
        DataCell(Text(channel.createTime ?? '-')),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => onEdit(channel),
                child: const Text('编辑'),
              ),
              TextButton(
                onPressed: () => onDelete(channel),
                child: const Text('删除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChannelCodeTag(String code) {
    final Map<String, (String, Color)> codeMap = {
      'aliyun': ('阿里云', Colors.orange),
      'tencent': ('腾讯云', Colors.blue),
      'huawei': ('华为云', Colors.red),
      'yunpian': ('云片', Colors.green),
    };

    final info = codeMap[code] ?? (code, Colors.grey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: info.$2.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        info.$1,
        style: TextStyle(color: info.$2, fontSize: 12),
      ),
    );
  }

  Widget _buildStatusTag(int status) {
    final isEnabled = status == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isEnabled ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isEnabled ? '开启' : '关闭',
        style: TextStyle(
          color: isEnabled ? Colors.green : Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}