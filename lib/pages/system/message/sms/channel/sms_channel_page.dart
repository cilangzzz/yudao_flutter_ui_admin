import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/api/system/sms_channel_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/sms_channel.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 短信渠道管理页面
class SmsChannelPage extends ConsumerStatefulWidget {
  const SmsChannelPage({super.key});

  @override
  ConsumerState<SmsChannelPage> createState() => _SmsChannelPageState();
}

class _SmsChannelPageState extends ConsumerState<SmsChannelPage> {
  final _searchController = TextEditingController();
  int? _selectedStatus;
  String? _selectedCode;

  List<SmsChannel> _channelList = [];
  Set<int> _selectedIds = {};
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChannelList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChannelList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(smsChannelApiProvider);
      final params = <String, dynamic>{
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_searchController.text.isNotEmpty) 'signature': _searchController.text,
        if (_selectedStatus != null) 'status': _selectedStatus,
        if (_selectedCode != null) 'code': _selectedCode,
      };

      final response = await api.getSmsChannelPage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _channelList = response.data!.list;
          _totalCount = response.data!.total;
          _isLoading = false;
          _selectedIds.clear();
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
    _loadChannelList();
  }

  void _reset() {
    _searchController.clear();
    setState(() {
      _selectedStatus = null;
      _selectedCode = null;
    });
    _currentPage = 1;
    _loadChannelList();
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择要删除的数据')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 ${_selectedIds.length} 条记录吗？'),
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
        final response = await api.deleteSmsChannelList(_selectedIds.toList());

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('删除成功')),
            );
            _loadChannelList();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : '删除失败')),
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
            _loadChannelList();
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
            width: DeviceUIMode.select(context, mobile: () => double.maxFinite, desktop: () => 450.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: signatureController,
                    decoration: const InputDecoration(
                      labelText: '短信签名 *',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: codeController.text.isEmpty ? null : codeController.text,
                    decoration: const InputDecoration(
                      labelText: '渠道编码 *',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'aliyun', child: Text('阿里云')),
                      DropdownMenuItem(value: 'tencent', child: Text('腾讯云')),
                      DropdownMenuItem(value: 'huawei', child: Text('华为云')),
                      DropdownMenuItem(value: 'yunpian', child: Text('云片')),
                    ],
                    onChanged: (value) => setState(() => codeController.text = value ?? ''),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: status,
                    decoration: const InputDecoration(
                      labelText: '启用状态',
                      border: OutlineInputBorder(),
                      isDense: true,
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
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: apiSecretController,
                    decoration: const InputDecoration(
                      labelText: '短信 API 的密钥',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: callbackUrlController,
                    decoration: const InputDecoration(
                      labelText: '短信发送回调 URL',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: remarkController,
                    decoration: const InputDecoration(
                      labelText: '备注',
                      border: OutlineInputBorder(),
                      isDense: true,
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
                    _loadChannelList();
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
      body: DeviceUIMode.builder(
        context,
        mobile: (context) => _buildMobileLayout(context),
        desktop: (context) => _buildDesktopLayout(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showChannelDialog(),
        icon: const Icon(Icons.add),
        label: const Text('添加渠道'),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        _buildDesktopSearchBar(context),
        const Divider(height: 1),
        _buildToolbar(context),
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
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: DeviceUIMode.select(context, mobile: () => 150.0, desktop: () => 200.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '短信签名',
                prefixIcon: Icon(Icons.search, size: 20),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          SizedBox(
            width: DeviceUIMode.select(context, mobile: () => 120.0, desktop: () => 150.0),
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
                _search();
              },
            ),
          ),
          SizedBox(
            width: DeviceUIMode.select(context, mobile: () => 100.0, desktop: () => 120.0),
            child: DropdownButtonFormField<int>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: '状态',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('全部')),
                DropdownMenuItem(value: 0, child: Text('开启')),
                DropdownMenuItem(value: 1, child: Text('关闭')),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                _search();
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search, size: 20),
            label: const Text('搜索'),
          ),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh, size: 20),
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
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: '短信签名',
              prefixIcon: Icon(Icons.search, size: 20),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCode,
                  decoration: const InputDecoration(
                    hintText: '渠道',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('全部')),
                    DropdownMenuItem(value: 'aliyun', child: Text('阿里云')),
                    DropdownMenuItem(value: 'tencent', child: Text('腾讯云')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCode = value);
                    _search();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    hintText: '状态',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('全部')),
                    DropdownMenuItem(value: 0, child: Text('开启')),
                    DropdownMenuItem(value: 1, child: Text('关闭')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
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

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete),
            label: const Text('批量删除'),
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
            ElevatedButton(onPressed: _loadChannelList, child: const Text('重试')),
          ],
        ),
      );
    }

    if (_channelList.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: _selectedIds.length == _channelList.length && _channelList.isNotEmpty,
                tristate: true,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedIds = _channelList.where((c) => c.id != null).map((c) => c.id!).toSet();
                    } else {
                      _selectedIds.clear();
                    }
                  });
                },
              ),
              const Text('短信渠道列表'),
              const Spacer(),
              Text('共 $_totalCount 条'),
            ],
          ),
          const SizedBox(height: 8),
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
              dataRowColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3);
                }
                return null;
              }),
              columns: const [
                DataColumn2(label: Text('编号'), size: ColumnSize.S),
                DataColumn2(label: Text('短信签名'), size: ColumnSize.M),
                DataColumn2(label: Text('渠道编码'), size: ColumnSize.M),
                DataColumn2(label: Text('状态'), size: ColumnSize.S),
                DataColumn2(label: Text('API 账号'), size: ColumnSize.L),
                DataColumn2(label: Text('创建时间'), size: ColumnSize.L),
                DataColumn2(label: Text('操作'), size: ColumnSize.M),
              ],
              rows: _channelList.map((channel) {
                final isSelected = channel.id != null && _selectedIds.contains(channel.id);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    if (channel.id != null) {
                      setState(() {
                        if (selected == true) {
                          _selectedIds.add(channel.id!);
                        } else {
                          _selectedIds.remove(channel.id!);
                        }
                      });
                    }
                  },
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
                            onPressed: () => _showChannelDialog(channel),
                            child: const Text('编辑'),
                          ),
                          PopupMenuButton<String>(
                            tooltip: '更多',
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 18, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('删除', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deleteChannel(channel);
                              }
                            },
                          ),
                        ],
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
            ElevatedButton(onPressed: _loadChannelList, child: const Text('重试')),
          ],
        ),
      );
    }

    if (_channelList.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return RefreshIndicator(
      onRefresh: _loadChannelList,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _channelList.length,
        itemBuilder: (context, index) {
          final channel = _channelList[index];
          return _buildChannelCard(channel);
        },
      ),
    );
  }

  Widget _buildChannelCard(SmsChannel channel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildChannelCodeTag(channel.code),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    channel.signature,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusTag(channel.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'API账号: ${channel.apiKey}',
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  channel.createTime ?? '-',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showChannelDialog(channel),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('编辑'),
                ),
                TextButton.icon(
                  onPressed: () => _deleteChannel(channel),
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: const Text('删除'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
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
                  _loadChannelList();
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
                      _loadChannelList();
                    }
                  : null,
            ),
            Text('$_currentPage / ${(_totalCount / _pageSize).ceil()}'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _currentPage * _pageSize < _totalCount
                  ? () {
                      setState(() => _currentPage++);
                      _loadChannelList();
                    }
                  : null,
            ),
          ],
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
      child: Text(info.$1, style: TextStyle(color: info.$2, fontSize: 12)),
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
        style: TextStyle(color: isEnabled ? Colors.green : Colors.red, fontSize: 12),
      ),
    );
  }
}