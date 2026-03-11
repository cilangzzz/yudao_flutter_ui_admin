import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '/../../api/system/mail_account_api.dart';
import '/../../api/system/mail_template_api.dart';
import '/../../models/system/mail_account.dart';
import '/../../models/system/mail_template.dart';

/// 邮件模板管理页面
class MailTemplatePage extends ConsumerStatefulWidget {
  const MailTemplatePage({super.key});

  @override
  ConsumerState<MailTemplatePage> createState() => _MailTemplatePageState();
}

class _MailTemplatePageState extends ConsumerState<MailTemplatePage> {
  final _searchNameController = TextEditingController();
  final _searchCodeController = TextEditingController();
  int? _selectedStatus;
  int? _selectedAccountId;

  List<MailTemplate> _dataList = [];
  List<MailAccount> _accountList = [];
  Set<int> _selectedIds = {};
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
    _searchNameController.dispose();
    _searchCodeController.dispose();
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

  String? _getAccountMail(int? accountId) {
    if (accountId == null) return null;
    return _accountList
        .firstWhere(
          (a) => a.id == accountId,
          orElse: () => MailAccount(
            mail: '',
            username: '',
            password: '',
            host: '',
            port: 0,
          ),
        )
        .mail;
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(mailTemplateApiProvider);
      final response = await api.getMailTemplatePage({
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_searchNameController.text.isNotEmpty) 'name': _searchNameController.text,
        if (_searchCodeController.text.isNotEmpty) 'code': _searchCodeController.text,
        if (_selectedStatus != null) 'status': _selectedStatus,
        if (_selectedAccountId != null) 'accountId': _selectedAccountId,
      });

      if (response.isSuccess && response.data != null) {
        setState(() {
          _dataList = response.data!.list;
          _totalCount = response.data!.total;
          _isLoading = false;
          _selectedIds.clear();
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
    _searchNameController.clear();
    _searchCodeController.clear();
    setState(() {
      _selectedStatus = null;
      _selectedAccountId = null;
    });
    _currentPage = 1;
    _loadData();
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
        final api = ref.read(mailTemplateApiProvider);
        final response = await api.deleteMailTemplateList(_selectedIds.toList());

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('删除成功')),
            );
            _loadData();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg ?? '删除失败')),
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

  Future<void> _deleteTemplate(MailTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除邮件模板 "${template.name}" 吗？'),
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
      final api = ref.read(mailTemplateApiProvider);
      final response = await api.deleteMailTemplate(template.id!);
      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除成功')),
          );
          _loadData();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg ?? '删除失败')),
          );
        }
      }
    }
  }

  void _showTemplateDialog([MailTemplate? template]) {
    showDialog(
      context: context,
      builder: (context) => _MailTemplateFormDialog(
        template: template,
        accountList: _accountList,
        onSuccess: _loadData,
      ),
    );
  }

  void _showSendMailDialog(MailTemplate template) {
    showDialog(
      context: context,
      builder: (context) => _SendMailDialog(template: template),
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
        label: const Text('添加邮件模板'),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 150,
              child: TextField(
                controller: _searchNameController,
                decoration: const InputDecoration(
                  hintText: '模板名称',
                  prefixIcon: Icon(Icons.text_fields),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _search(),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 150,
              child: TextField(
                controller: _searchCodeController,
                decoration: const InputDecoration(
                  hintText: '模板编码',
                  prefixIcon: Icon(Icons.code),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _search(),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 150,
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
            const SizedBox(width: 16),
            SizedBox(
              width: 200,
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
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _search,
              icon: const Icon(Icons.search),
              label: const Text('搜索'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('重置'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: () => _showTemplateDialog(),
            icon: const Icon(Icons.add),
            label: const Text('新增'),
          ),
          const SizedBox(width: 8),
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
              Checkbox(
                value: _selectedIds.length == _dataList.length && _dataList.isNotEmpty,
                tristate: true,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedIds = _dataList.where((e) => e.id != null).map((e) => e.id!).toSet();
                    } else {
                      _selectedIds.clear();
                    }
                  });
                },
              ),
              const Text('邮件模板列表'),
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
                DataColumn2(label: Text('模板编码'), size: ColumnSize.M),
                DataColumn2(label: Text('模板名称'), size: ColumnSize.M),
                DataColumn2(label: Text('模板标题'), size: ColumnSize.M),
                DataColumn2(label: Text('邮箱账号'), size: ColumnSize.M),
                DataColumn2(label: Text('发送人名称'), size: ColumnSize.M),
                DataColumn2(label: Text('状态'), size: ColumnSize.S),
                DataColumn2(label: Text('创建时间'), size: ColumnSize.L),
                DataColumn2(label: Text('操作'), size: ColumnSize.L),
              ],
              rows: _dataList.map((item) {
                final isSelected = item.id != null && _selectedIds.contains(item.id);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    if (item.id != null) {
                      setState(() {
                        if (selected == true) {
                          _selectedIds.add(item.id!);
                        } else {
                          _selectedIds.remove(item.id!);
                        }
                      });
                    }
                  },
                  cells: [
                    DataCell(Text(item.id?.toString() ?? '-')),
                    DataCell(Text(item.code)),
                    DataCell(Text(item.name)),
                    DataCell(Text(item.title)),
                    DataCell(Text(_getAccountMail(item.accountId) ?? '-')),
                    DataCell(Text(item.nickname ?? '-')),
                    DataCell(_buildStatusTag(item.status)),
                    DataCell(Text(item.createTime ?? '-')),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => _showTemplateDialog(item),
                          child: const Text('编辑'),
                        ),
                        TextButton(
                          onPressed: () => _showSendMailDialog(item),
                          child: const Text('测试'),
                        ),
                        TextButton(
                          onPressed: () => _deleteTemplate(item),
                          child: const Text('删除', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    )),
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

/// 邮件模板表单对话框
class _MailTemplateFormDialog extends StatefulWidget {
  final MailTemplate? template;
  final List<MailAccount> accountList;
  final VoidCallback onSuccess;

  const _MailTemplateFormDialog({
    this.template,
    required this.accountList,
    required this.onSuccess,
  });

  @override
  State<_MailTemplateFormDialog> createState() => _MailTemplateFormDialogState();
}

class _MailTemplateFormDialogState extends State<_MailTemplateFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _nicknameController = TextEditingController();

  int _selectedAccountId = 0;
  int _status = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      _nameController.text = widget.template!.name;
      _codeController.text = widget.template!.code;
      _titleController.text = widget.template!.title;
      _contentController.text = widget.template!.content;
      _nicknameController.text = widget.template!.nickname ?? '';
      _selectedAccountId = widget.template!.accountId;
      _status = widget.template!.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = MailTemplate(
        id: widget.template?.id,
        name: _nameController.text,
        code: _codeController.text,
        accountId: _selectedAccountId,
        title: _titleController.text,
        content: _contentController.text,
        nickname: _nicknameController.text.isNotEmpty ? _nicknameController.text : null,
        status: _status,
      );

      final container = ProviderScope.containerOf(context);
      final api = container.read(mailTemplateApiProvider);

      final response = widget.template?.id != null
          ? await api.updateMailTemplate(data)
          : await api.createMailTemplate(data);

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('操作成功')),
          );
        }
        widget.onSuccess();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg ?? '操作失败')),
          );
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.template == null ? '添加邮件模板' : '编辑邮件模板'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '模板名称 *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty == true ? '请输入模板名称' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: '模板编码 *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty == true ? '请输入模板编码' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedAccountId > 0 ? _selectedAccountId : null,
                  decoration: const InputDecoration(
                    labelText: '邮箱账号 *',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.accountList
                      .map((a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.mail),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedAccountId = v ?? 0;
                    });
                  },
                  validator: (v) => v == null || v == 0 ? '请选择邮箱账号' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    labelText: '发送人名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '模板标题 *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty == true ? '请输入模板标题' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: '模板内容 *',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 6,
                  validator: (v) => v?.isEmpty == true ? '请输入模板内容' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('状态：'),
                    const SizedBox(width: 16),
                    Radio<int>(
                      value: 0,
                      groupValue: _status,
                      onChanged: (v) => setState(() => _status = v ?? 0),
                    ),
                    const Text('开启'),
                    const SizedBox(width: 16),
                    Radio<int>(
                      value: 1,
                      groupValue: _status,
                      onChanged: (v) => setState(() => _status = v ?? 1),
                    ),
                    const Text('关闭'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('确定'),
        ),
      ],
    );
  }
}

/// 发送邮件对话框
class _SendMailDialog extends StatefulWidget {
  final MailTemplate template;

  const _SendMailDialog({required this.template});

  @override
  State<_SendMailDialog> createState() => _SendMailDialogState();
}

class _SendMailDialogState extends State<_SendMailDialog> {
  final _formKey = GlobalKey<FormState>();
  final _toMailsController = TextEditingController();
  final _ccMailsController = TextEditingController();
  final _bccMailsController = TextEditingController();
  final Map<String, TextEditingController> _paramControllers = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 动态创建参数输入框
    for (final param in widget.template.params) {
      _paramControllers[param] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _toMailsController.dispose();
    _ccMailsController.dispose();
    _bccMailsController.dispose();
    for (final controller in _paramControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _sendMail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 构建参数对象
      final templateParams = <String, dynamic>{};
      for (final entry in _paramControllers.entries) {
        templateParams[entry.key] = entry.value.text;
      }

      // 解析邮箱列表
      final toMails = _toMailsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final ccMails = _ccMailsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final bccMails = _bccMailsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final data = MailSendReqVO(
        toMails: toMails,
        ccMails: ccMails.isNotEmpty ? ccMails : null,
        bccMails: bccMails.isNotEmpty ? bccMails : null,
        templateCode: widget.template.code,
        templateParams: templateParams,
      );

      final container = ProviderScope.containerOf(context);
      final api = container.read(mailTemplateApiProvider);
      final response = await api.sendMail(data);

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('邮件发送成功')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg ?? '邮件发送失败')),
          );
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('测试发送邮件'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 模板内容预览
                const Text('模板内容：', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.template.content,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
                // 动态参数输入
                if (widget.template.params.isNotEmpty) ...[
                  const Text('模板参数：', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...widget.template.params.map((param) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          controller: _paramControllers[param],
                          decoration: InputDecoration(
                            labelText: '参数 $param',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) => v?.isEmpty == true ? '请输入参数值' : null,
                        ),
                      )),
                  const SizedBox(height: 8),
                ],
                // 收件邮箱
                TextFormField(
                  controller: _toMailsController,
                  decoration: const InputDecoration(
                    labelText: '收件邮箱 *',
                    hintText: '多个邮箱用逗号分隔',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty == true ? '请输入收件邮箱' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ccMailsController,
                  decoration: const InputDecoration(
                    labelText: '抄送邮箱',
                    hintText: '多个邮箱用逗号分隔',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bccMailsController,
                  decoration: const InputDecoration(
                    labelText: '密送邮箱',
                    hintText: '多个邮箱用逗号分隔',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendMail,
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('发送'),
        ),
      ],
    );
  }
}