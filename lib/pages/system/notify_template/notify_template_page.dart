import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/notify_template_api.dart';
import '../../../models/system/notify_template.dart';

/// 通知模板管理页面
class NotifyTemplatePage extends ConsumerStatefulWidget {
  const NotifyTemplatePage({super.key});

  @override
  ConsumerState<NotifyTemplatePage> createState() => _NotifyTemplatePageState();
}

class _NotifyTemplatePageState extends ConsumerState<NotifyTemplatePage> {
  List<NotifyTemplate> _templates = [];
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
      final api = ref.read(notifyTemplateApiProvider);
      final response = await api.getNotifyTemplatePage({
        'pageNo': _currentPage,
        'pageSize': _pageSize,
      });

      if (response.isSuccess && response.data != null) {
        setState(() {
          _templates = response.data!.list;
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

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _deleteTemplate(NotifyTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除模板 "${template.name}" 吗？'),
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
        final api = ref.read(notifyTemplateApiProvider);
        final response = await api.deleteNotifyTemplate(template.id!);
        if (response.isSuccess) {
          _showSuccess('删除成功');
          _loadData();
        } else {
          _showError(response.msg ?? '删除失败');
        }
      } catch (e) {
        _showError('删除异常: $e');
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
      builder: (context) => AlertDialog(
        title: Text(template == null ? '添加通知模板' : '编辑通知模板'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '模板名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: '模板编码',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nicknameController,
                  decoration: const InputDecoration(
                    labelText: '发送人名称',
                    border: OutlineInputBorder(),
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
                  onChanged: (value) => type = value ?? 1,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: '模板内容',
                    border: OutlineInputBorder(),
                    hintText: '支持使用 {param} 格式定义参数',
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: '状态',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('开启')),
                    DropdownMenuItem(value: 1, child: Text('关闭')),
                  ],
                  onChanged: (value) => status = value ?? 0,
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
              final data = NotifyTemplate(
                id: template?.id,
                name: nameController.text,
                code: codeController.text,
                nickname: nicknameController.text.isEmpty ? null : nicknameController.text,
                content: contentController.text,
                type: type,
                status: status,
                remark: remarkController.text.isEmpty ? null : remarkController.text,
              );

              try {
                final api = ref.read(notifyTemplateApiProvider);
                final response = template == null
                    ? await api.createNotifyTemplate(data)
                    : await api.updateNotifyTemplate(data);

                if (response.isSuccess) {
                  Navigator.pop(context);
                  _showSuccess(template == null ? '添加成功' : '更新成功');
                  _loadData();
                } else {
                  _showError(response.msg ?? '操作失败');
                }
              } catch (e) {
                _showError('操作异常: $e');
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showSendTestDialog(NotifyTemplate template) {
    final userIdController = TextEditingController();
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
      builder: (context) => AlertDialog(
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
                Text(
                  '模板内容:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(template.content ?? '-'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: userIdController,
                  decoration: const InputDecoration(
                    labelText: '接收用户ID',
                    border: OutlineInputBorder(),
                    hintText: '输入要发送的用户ID',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                if (paramControllers.isNotEmpty) ...[
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
                          labelText: entry.key,
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
            child: const Text('取消'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final userId = int.tryParse(userIdController.text);
              if (userId == null) {
                _showError('请输入有效的用户ID');
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
                  userType: 1, // 默认管理员类型
                  templateCode: template.code,
                  templateParams: templateParams,
                ));

                if (response.isSuccess) {
                  Navigator.pop(context);
                  _showSuccess('发送成功');
                } else {
                  _showError(response.msg ?? '发送失败');
                }
              } catch (e) {
                _showError('发送异常: $e');
              }
            },
            icon: const Icon(Icons.send),
            label: const Text('发送'),
          ),
        ],
      ),
    );
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
      child: Row(
        children: [
          Text(
            '通知模板管理',
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

    if (_templates.isEmpty) {
      return const Center(
        child: Text('暂无模板数据'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PaginatedDataTable(
        header: const Text('模板列表'),
        rowsPerPage: _pageSize,
        availableRowsPerPage: const [10, 20, 50],
        onPageChanged: (page) {
          _currentPage = page + 1;
          _loadData();
        },
        // total: _total,
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('模板名称')),
          DataColumn(label: Text('模板编码')),
          DataColumn(label: Text('发送人')),
          DataColumn(label: Text('模板类型')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('创建时间')),
          DataColumn(label: Text('操作')),
        ],
        source: _NotifyTemplateDataSource(
          _templates,
          context,
          getTypeText: _getTypeText,
          onEdit: _showTemplateDialog,
          onDelete: _deleteTemplate,
          onSend: _showSendTestDialog,
        ),
      ),
    );
  }
}

/// 通知模板数据源
class _NotifyTemplateDataSource extends DataTableSource {
  final List<NotifyTemplate> templates;
  final BuildContext context;
  final String Function(int?) getTypeText;
  final void Function(NotifyTemplate)? onEdit;
  final void Function(NotifyTemplate)? onDelete;
  final void Function(NotifyTemplate)? onSend;

  _NotifyTemplateDataSource(
    this.templates,
    this.context, {
    required this.getTypeText,
    this.onEdit,
    this.onDelete,
    this.onSend,
  });

  @override
  int get rowCount => templates.length;

  @override
  DataRow getRow(int index) {
    final template = templates[index];
    return DataRow(
      cells: [
        DataCell(Text(template.id?.toString() ?? '')),
        DataCell(Text(template.name)),
        DataCell(Text(template.code)),
        DataCell(Text(template.nickname ?? '-')),
        DataCell(Text(getTypeText(template.type))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: template.status == 0
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
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
        ),
        DataCell(Text('-')),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => onEdit?.call(template),
                child: const Text('编辑'),
              ),
              TextButton(
                onPressed: () => onSend?.call(template),
                child: const Text('测试', style: TextStyle(color: Colors.blue)),
              ),
              TextButton(
                onPressed: () => onDelete?.call(template),
                child: const Text('删除', style: TextStyle(color: Colors.red)),
              ),
            ],
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