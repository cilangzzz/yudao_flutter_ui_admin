import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/api/system/notify_template_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/notify_template.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 站内信模板管理页面
class NotifyTemplatePage extends ConsumerStatefulWidget {
  const NotifyTemplatePage({super.key});

  @override
  ConsumerState<NotifyTemplatePage> createState() => _NotifyTemplatePageState();
}

class _NotifyTemplatePageState extends ConsumerState<NotifyTemplatePage> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  DateTimeRange? _createTimeRange;
  int? _selectedStatus;
  int? _selectedType;

  List<NotifyTemplate> _templateList = [];
  Set<int> _selectedIds = {};
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTemplateList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplateList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(notifyTemplateApiProvider);
      final params = <String, dynamic>{
        'pageNo': _currentPage,
        'pageSize': _pageSize,
      };

      if (_nameController.text.isNotEmpty) {
        params['name'] = _nameController.text;
      }
      if (_codeController.text.isNotEmpty) {
        params['code'] = _codeController.text;
      }
      if (_selectedStatus != null) {
        params['status'] = _selectedStatus;
      }
      if (_selectedType != null) {
        params['type'] = _selectedType;
      }
      if (_createTimeRange != null) {
        params['createTime'] = _formatDate(_createTimeRange!.start);
        params['createTimeEnd'] = _formatDate(_createTimeRange!.end);
      }

      final response = await api.getNotifyTemplatePage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _templateList = response.data!.list;
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
    _loadTemplateList();
  }

  void _reset() {
    _nameController.clear();
    _codeController.clear();
    setState(() {
      _createTimeRange = null;
      _selectedStatus = null;
      _selectedType = null;
    });
    _currentPage = 1;
    _loadTemplateList();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getTypeText(int? type) {
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

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseSelectData)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteSelected} (${_selectedIds.length})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(S.current.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final api = ref.read(notifyTemplateApiProvider);
        final response = await api.deleteNotifyTemplateList(_selectedIds.toList());

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadTemplateList();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.deleteFailed)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${S.current.deleteFailed}: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteTemplate(NotifyTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteUser} "${template.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(S.current.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final api = ref.read(notifyTemplateApiProvider);
        final response = await api.deleteNotifyTemplate(template.id!);

        if (response.isSuccess) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadTemplateList();
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.deleteFailed)),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${S.current.deleteFailed}: $e')),
          );
        }
      }
    }
  }

  void _showTemplateDialog([NotifyTemplate? template]) {
    final nameController = TextEditingController(text: template?.name ?? '');
    final codeController = TextEditingController(text: template?.code ?? '');
    final nicknameController = TextEditingController(text: template?.nickname ?? '');
    final contentController = TextEditingController(text: template?.content ?? '');
    final remarkController = TextEditingController(text: template?.remark ?? '');
    int type = template?.type ?? 1;
    int status = template?.status ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(template == null ? '新增站内信模板' : '编辑站内信模板'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '模板名称 *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: '模板编码 *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nicknameController,
                    decoration: InputDecoration(
                      labelText: '发送人名称 *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: type,
                    decoration: const InputDecoration(
                      labelText: '模板类型',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('站内信')),
                      DropdownMenuItem(value: 2, child: Text('邮件')),
                      DropdownMenuItem(value: 3, child: Text('短信')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        type = value ?? 1;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: '模板内容 *',
                      border: OutlineInputBorder(),
                      hintText: '支持使用 {param} 格式定义参数',
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  // 状态
                  Row(
                    children: [
                      Text('${S.current.status}: '),
                      Radio<int>(
                        value: 0,
                        groupValue: status,
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                      Text(S.current.enabled),
                      Radio<int>(
                        value: 1,
                        groupValue: status,
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                      Text(S.current.disabled),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: remarkController,
                    decoration: InputDecoration(
                      labelText: S.current.remark,
                      border: const OutlineInputBorder(),
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
              child: Text(S.current.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    codeController.text.isEmpty ||
                    nicknameController.text.isEmpty ||
                    contentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.current.pleaseFillRequired)),
                  );
                  return;
                }

                final templateData = NotifyTemplate(
                  id: template?.id,
                  name: nameController.text,
                  code: codeController.text,
                  nickname: nicknameController.text,
                  content: contentController.text,
                  type: type,
                  status: status,
                  remark: remarkController.text.isEmpty ? null : remarkController.text,
                );

                try {
                  final api = ref.read(notifyTemplateApiProvider);
                  final response = template == null
                      ? await api.createNotifyTemplate(templateData)
                      : await api.updateNotifyTemplate(templateData);

                  if (response.isSuccess) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(template == null ? S.current.addSuccess : S.current.editSuccess)),
                      );
                      _loadTemplateList();
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.operationFailed)),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${S.current.operationFailed}: $e')),
                    );
                  }
                }
              },
              child: Text(S.current.confirm),
            ),
          ],
        ),
      ),
    );
  }

  void _showSendTestDialog(NotifyTemplate template) {
    final userIdController = TextEditingController();
    int userType = 1; // 默认管理员
    final Map<String, TextEditingController> paramControllers = {};

    // 解析模板参数
    if (template.content != null) {
      final paramRegex = RegExp(r'\{(\w+)\}');
      final matches = paramRegex.allMatches(template.content!);
      for (final match in matches) {
        final paramName = match.group(1);
        if (paramName != null && !paramControllers.containsKey(paramName)) {
          paramControllers[paramName] = TextEditingController();
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.send, color: Colors.blue),
              const SizedBox(width: 8),
              Text('发送测试 - ${template.name}'),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 模板内容
                  Text(
                    '模板内容:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(template.content ?? '-'),
                  ),
                  const SizedBox(height: 16),
                  // 用户类型
                  Row(
                    children: [
                      const Text('用户类型: '),
                      Radio<int>(
                        value: 1,
                        groupValue: userType,
                        onChanged: (value) {
                          setState(() {
                            userType = value!;
                          });
                        },
                      ),
                      const Text('管理员'),
                      Radio<int>(
                        value: 2,
                        groupValue: userType,
                        onChanged: (value) {
                          setState(() {
                            userType = value!;
                          });
                        },
                      ),
                      const Text('会员'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 接收用户ID
                  TextField(
                    controller: userIdController,
                    decoration: const InputDecoration(
                      labelText: '接收用户ID *',
                      border: OutlineInputBorder(),
                      hintText: '输入要发送的用户ID',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  // 动态模板参数
                  if (paramControllers.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      '模板参数:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ...paramControllers.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: entry.value,
                          decoration: InputDecoration(
                            labelText: '参数 ${entry.key}',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.current.cancel),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final userId = int.tryParse(userIdController.text);
                if (userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入有效的用户ID')),
                  );
                  return;
                }

                final templateParams = <String, dynamic>{};
                for (final entry in paramControllers.entries) {
                  templateParams[entry.key] = entry.value.text;
                }

                try {
                  final api = ref.read(notifyTemplateApiProvider);
                  final response = await api.sendNotify(NotifySendReq(
                    userId: userId,
                    userType: userType,
                    templateCode: template.code,
                    templateParams: templateParams,
                  ));

                  if (response.isSuccess) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.current.operationSuccess)),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.operationFailed)),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${S.current.operationFailed}: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('发送'),
            ),
          ],
        ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTemplateDialog(),
        icon: const Icon(Icons.add),
        label: const Text('新增模板'),
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
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 180,
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '模板名称',
                prefixIcon: const Icon(Icons.text_fields, size: 18),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          SizedBox(
            width: 180,
            child: TextField(
              controller: _codeController,
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
            width: 120,
            child: DropdownButtonFormField<int?>(
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
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
          ),
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<int?>(
              value: _selectedType,
              decoration: const InputDecoration(
                hintText: '模板类型',
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
                  _selectedType = value;
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
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: '模板名称',
                    prefixIcon: const Icon(Icons.text_fields, size: 20),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _codeController,
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

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showTemplateDialog(),
            icon: const Icon(Icons.add),
            label: const Text('新增'),
          ),
          ElevatedButton.icon(
            onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete),
            label: Text(S.current.deleteBatch),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(NotifyTemplate template) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => _showTemplateDialog(template),
          child: Text(S.current.edit),
        ),
        PopupMenuButton<String>(
          tooltip: S.current.more,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'test',
              child: Row(
                children: [
                  const Icon(Icons.send, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text('测试', style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(S.current.delete, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'test':
                _showSendTestDialog(template);
                break;
              case 'delete':
                _deleteTemplate(template);
                break;
            }
          },
        ),
      ],
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
            ElevatedButton(onPressed: _loadTemplateList, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (_templateList.isEmpty) {
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
              const Text('站内信模板列表'),
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
              columns: [
                DataColumn2(
                  label: Text('编号'),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text('模板名称'),
                  size: ColumnSize.M,
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
                  label: Text('模板内容'),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text('模板类型'),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.status),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.remark),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.createTime),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.operation),
                  size: ColumnSize.M,
                  fixedWidth: 200,
                ),
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
                    DataCell(Text(template.name)),
                    DataCell(Text(template.code)),
                    DataCell(Text(template.nickname ?? '-')),
                    DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Text(
                        template.content ?? '-',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    )),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTypeColor(template.type).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getTypeText(template.type),
                        style: TextStyle(
                          color: _getTypeColor(template.type),
                          fontSize: 12,
                        ),
                      ),
                    )),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: template.status == 0
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        template.status == 0 ? '开启' : '关闭',
                        style: TextStyle(
                          color: template.status == 0 ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    )),
                    DataCell(Text(template.remark ?? '-')),
                    DataCell(Text('-')),
                    DataCell(_buildActionButtons(template)),
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
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(int? type) {
    switch (type) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
            ElevatedButton(onPressed: _loadTemplateList, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (_templateList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadTemplateList,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _templateList.length,
              itemBuilder: (context, index) {
                final template = _templateList[index];
                return _buildTemplateCard(template);
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
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(NotifyTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    template.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: template.status == 0
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    template.status == 0 ? '开启' : '关闭',
                    style: TextStyle(
                      color: template.status == 0 ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(template.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getTypeText(template.type),
                    style: TextStyle(
                      color: _getTypeColor(template.type),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.code, '模板编码', template.code),
            _buildInfoRow(Icons.person, '发送人', template.nickname ?? '-'),
            _buildInfoRow(Icons.message, '模板内容', template.content ?? '-', maxLines: 3),
            if (template.remark != null && template.remark!.isNotEmpty)
              _buildInfoRow(Icons.note, S.current.remark, template.remark!),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () => _showTemplateDialog(template),
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(S.current.edit),
                ),
                TextButton.icon(
                  onPressed: () => _showSendTestDialog(template),
                  icon: const Icon(Icons.send, size: 18, color: Colors.blue),
                  label: const Text('测试', style: TextStyle(color: Colors.blue)),
                ),
                TextButton.icon(
                  onPressed: () => _deleteTemplate(template),
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: Text(S.current.delete, style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}