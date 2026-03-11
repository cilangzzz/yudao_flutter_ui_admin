import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '/../../api/system/sms_template_api.dart';
import '/../../api/system/sms_channel_api.dart';
import '/../../models/system/sms_template.dart';
import '/../../models/system/sms_channel.dart';

/// 短信模板管理页面
class SmsTemplatePage extends ConsumerStatefulWidget {
  const SmsTemplatePage({super.key});

  @override
  ConsumerState<SmsTemplatePage> createState() => _SmsTemplatePageState();
}

class _SmsTemplatePageState extends ConsumerState<SmsTemplatePage> {
  final _searchCodeController = TextEditingController();
  final _searchNameController = TextEditingController();
  int? _selectedType;
  int? _selectedStatus;
  int? _selectedChannelId;

  List<SmsTemplate> _templateList = [];
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
    _loadTemplateList();
  }

  @override
  void dispose() {
    _searchCodeController.dispose();
    _searchNameController.dispose();
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
      // 渠道列表加载失败不影响模板列表
    }
  }

  Future<void> _loadTemplateList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(smsTemplateApiProvider);
      final params = <String, dynamic>{
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_searchCodeController.text.isNotEmpty) 'code': _searchCodeController.text,
        if (_searchNameController.text.isNotEmpty) 'name': _searchNameController.text,
        if (_selectedType != null) 'type': _selectedType,
        if (_selectedStatus != null) 'status': _selectedStatus,
        if (_selectedChannelId != null) 'channelId': _selectedChannelId,
      };

      final response = await api.getSmsTemplatePage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _templateList = response.data!.list;
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
    _loadTemplateList();
  }

  void _reset() {
    _searchCodeController.clear();
    _searchNameController.clear();
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
      _selectedChannelId = null;
    });
    _currentPage = 1;
    _loadTemplateList();
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
        final api = ref.read(smsTemplateApiProvider);
        final response = await api.deleteSmsTemplateList(_selectedIds.toList());

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('删除成功')),
            );
            _loadTemplateList();
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

  Future<void> _deleteTemplate(SmsTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除短信模板 "${template.name}" 吗？'),
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
        final api = ref.read(smsTemplateApiProvider);
        final response = await api.deleteSmsTemplate(template.id!);
        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('删除成功')),
            );
            _loadTemplateList();
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

  void _showTemplateDialog([SmsTemplate? template]) {
    final isEdit = template != null;
    final nameController = TextEditingController(text: template?.name ?? '');
    final codeController = TextEditingController(text: template?.code ?? '');
    final contentController = TextEditingController(text: template?.content ?? '');
    final apiTemplateIdController = TextEditingController(text: template?.apiTemplateId ?? '');
    final remarkController = TextEditingController(text: template?.remark ?? '');
    int type = template?.type ?? 1;
    int status = template?.status ?? 0;
    int? channelId = template?.channelId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? '编辑短信模板' : '添加短信模板'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: type,
                    decoration: const InputDecoration(
                      labelText: '短信类型 *',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('验证码')),
                      DropdownMenuItem(value: 2, child: Text('通知')),
                      DropdownMenuItem(value: 3, child: Text('营销')),
                    ],
                    onChanged: (value) => setState(() => type = value ?? 1),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '模板名称 *',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: '模板编码 *',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: channelId,
                    decoration: const InputDecoration(
                      labelText: '短信渠道 *',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('请选择')),
                      ..._channelList.map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.signature),
                          )),
                    ],
                    onChanged: (value) => setState(() => channelId = value),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: status,
                    decoration: const InputDecoration(
                      labelText: '开启状态',
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
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: '模板内容 *',
                      border: OutlineInputBorder(),
                      isDense: true,
                      hintText: '例如：您的验证码为{code}，有效期{time}分钟',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: apiTemplateIdController,
                    decoration: const InputDecoration(
                      labelText: '短信 API 的模板编号 *',
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
                if (nameController.text.isEmpty ||
                    codeController.text.isEmpty ||
                    contentController.text.isEmpty ||
                    apiTemplateIdController.text.isEmpty ||
                    channelId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请填写必填项')),
                  );
                  return;
                }

                final data = SmsTemplate(
                  id: template?.id,
                  type: type,
                  name: nameController.text,
                  code: codeController.text,
                  channelId: channelId,
                  status: status,
                  content: contentController.text,
                  apiTemplateId: apiTemplateIdController.text,
                  remark: remarkController.text.isEmpty ? null : remarkController.text,
                );

                try {
                  final api = ref.read(smsTemplateApiProvider);
                  final response = isEdit
                      ? await api.updateSmsTemplate(data)
                      : await api.createSmsTemplate(data);

                  if (response.isSuccess) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEdit ? '修改成功' : '添加成功')),
                      );
                    }
                    _loadTemplateList();
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

  void _showSendSmsDialog(SmsTemplate template) {
    final mobileController = TextEditingController();
    final Map<String, TextEditingController> paramControllers = {};

    // 解析模板参数
    final paramPattern = RegExp(r'\{(\w+)\}');
    final matches = paramPattern.allMatches(template.content);
    for (final match in matches) {
      final paramName = match.group(1);
      if (paramName != null && !paramControllers.containsKey(paramName)) {
        paramControllers[paramName] = TextEditingController();
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发送测试短信'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('模板内容:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(template.content),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: mobileController,
                  decoration: const InputDecoration(
                    labelText: '手机号码 *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                if (paramControllers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('模板参数:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...paramControllers.entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: entry.value,
                          decoration: InputDecoration(
                            labelText: '参数 ${entry.key}',
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      )),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              for (final controller in paramControllers.values) {
                controller.dispose();
              }
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (mobileController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入手机号码')),
                );
                return;
              }

              final templateParams = <String, dynamic>{};
              for (final entry in paramControllers.entries) {
                templateParams[entry.key] = entry.value.text;
              }

              try {
                final api = ref.read(smsTemplateApiProvider);
                final request = SmsSendReqVO(
                  mobile: mobileController.text,
                  templateCode: template.code,
                  templateParams: templateParams,
                );
                final response = await api.sendSms(request);

                if (response.isSuccess) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('短信发送成功')),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('发送失败: $e')),
                  );
                }
              }
            },
            child: const Text('发送'),
          ),
        ],
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
          _buildToolbar(context),
          const Divider(height: 1),
          Expanded(child: _buildDataTable(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTemplateDialog(),
        icon: const Icon(Icons.add),
        label: const Text('添加模板'),
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
              controller: _searchCodeController,
              decoration: const InputDecoration(
                hintText: '模板编码',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          SizedBox(
            width: 150,
            child: TextField(
              controller: _searchNameController,
              decoration: const InputDecoration(
                hintText: '模板名称',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          SizedBox(
            width: 140,
            child: DropdownButtonFormField<int>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: '短信类型',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('全部')),
                DropdownMenuItem(value: 1, child: Text('验证码')),
                DropdownMenuItem(value: 2, child: Text('通知')),
                DropdownMenuItem(value: 3, child: Text('营销')),
              ],
              onChanged: (value) {
                setState(() => _selectedType = value);
                _search();
              },
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
            width: 120,
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
            ElevatedButton(onPressed: _loadTemplateList, child: const Text('重试')),
          ],
        ),
      );
    }

    if (_templateList.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: _selectedIds.length == _templateList.length && _templateList.isNotEmpty,
                tristate: true,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedIds = _templateList.where((t) => t.id != null).map((t) => t.id!).toSet();
                    } else {
                      _selectedIds.clear();
                    }
                  });
                },
              ),
              const Text('短信模板列表'),
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
              dataRowColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3);
                }
                return null;
              }),
              columns: const [
                DataColumn2(label: Text('编号'), size: ColumnSize.S),
                DataColumn2(label: Text('类型'), size: ColumnSize.S),
                DataColumn2(label: Text('模板名称'), size: ColumnSize.M),
                DataColumn2(label: Text('模板编码'), size: ColumnSize.M),
                DataColumn2(label: Text('模板内容'), size: ColumnSize.L),
                DataColumn2(label: Text('状态'), size: ColumnSize.S),
                DataColumn2(label: Text('API模板编号'), size: ColumnSize.M),
                DataColumn2(label: Text('渠道'), size: ColumnSize.S),
                DataColumn2(label: Text('操作'), size: ColumnSize.M),
              ],
              rows: _templateList.map((template) {
                final isSelected = template.id != null && _selectedIds.contains(template.id);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    if (template.id != null) {
                      setState(() {
                        if (selected == true) {
                          _selectedIds.add(template.id!);
                        } else {
                          _selectedIds.remove(template.id!);
                        }
                      });
                    }
                  },
                  cells: [
                    DataCell(Text(template.id?.toString() ?? '-')),
                    DataCell(_buildTypeTag(template.type)),
                    DataCell(Text(template.name)),
                    DataCell(Text(template.code)),
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Text(
                          template.content,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    DataCell(_buildStatusTag(template.status)),
                    DataCell(Text(template.apiTemplateId ?? '-')),
                    DataCell(Text(_getChannelCodeText(template.channelCode))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _showTemplateDialog(template),
                            child: const Text('编辑'),
                          ),
                          PopupMenuButton<String>(
                            tooltip: '更多',
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'test',
                                child: Row(
                                  children: [
                                    Icon(Icons.send, size: 18, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('测试', style: TextStyle(color: Colors.blue)),
                                  ],
                                ),
                              ),
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
                              switch (value) {
                                case 'test':
                                  _showSendSmsDialog(template);
                                  break;
                                case 'delete':
                                  _deleteTemplate(template);
                                  break;
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
                  _loadTemplateList();
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
                      _loadTemplateList();
                    }
                  : null,
            ),
            Text('$_currentPage / ${(_totalCount / _pageSize).ceil()}'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _currentPage * _pageSize < _totalCount
                  ? () {
                      setState(() => _currentPage++);
                      _loadTemplateList();
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeTag(int? type) {
    final Map<int, (String, Color)> typeMap = {
      1: ('验证码', Colors.blue),
      2: ('通知', Colors.green),
      3: ('营销', Colors.orange),
    };

    final info = typeMap[type] ?? ('未知', Colors.grey);
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

  String _getChannelCodeText(String? code) {
    switch (code) {
      case 'aliyun': return '阿里云';
      case 'tencent': return '腾讯云';
      case 'huawei': return '华为云';
      case 'yunpian': return '云片';
      default: return code ?? '-';
    }
  }
}