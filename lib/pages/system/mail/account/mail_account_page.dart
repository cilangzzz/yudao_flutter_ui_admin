import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/../../api/system/mail_account_api.dart';
import '/../../models/system/mail_account.dart';
import '/../../models/common/page_result.dart';

// 邮件账号管理页面
class MailAccountPage extends ConsumerStatefulWidget {
  const MailAccountPage({super.key});

  @override
  ConsumerState<MailAccountPage> createState() => _MailAccountPageState();
}

class _MailAccountPageState extends ConsumerState<MailAccountPage> {
  final _searchMailController = TextEditingController();
  final _searchUsernameController = TextEditingController();

  List<MailAccount> _dataList = [];
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
    _searchMailController.dispose();
    _searchUsernameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final api = ref.read(mailAccountApiProvider);
      final response = await api.getMailAccountPage({
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_searchMailController.text.isNotEmpty) 'mail': _searchMailController.text,
        if (_searchUsernameController.text.isNotEmpty) 'username': _searchUsernameController.text,
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

  void _showAccountDialog([MailAccount? account]) {
    showDialog(
      context: context,
      builder: (context) => _MailAccountFormDialog(
        account: account,
        onSuccess: _refresh,
      ),
    );
  }

  Future<void> _deleteAccount(MailAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除邮箱账号 "${account.mail}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final api = ref.read(mailAccountApiProvider);
      final response = await api.deleteMailAccount(account.id!);
      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除成功')),
          );
        }
        _loadData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg ?? '删除失败')),
          );
        }
      }
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
            child: _buildDataTable(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAccountDialog(),
        icon: const Icon(Icons.add),
        label: const Text('添加邮箱账号'),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              controller: _searchMailController,
              decoration: const InputDecoration(
                hintText: '邮箱',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _refresh(),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 200,
            child: TextField(
              controller: _searchUsernameController,
              decoration: const InputDecoration(
                hintText: '用户名',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _refresh(),
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
              _searchMailController.clear();
              _searchUsernameController.clear();
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
        header: const Text('邮箱账号列表'),
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
          DataColumn(label: Text('邮箱')),
          DataColumn(label: Text('用户名')),
          DataColumn(label: Text('SMTP服务器域名')),
          DataColumn(label: Text('SMTP端口')),
          DataColumn(label: Text('SSL')),
          DataColumn(label: Text('STARTTLS')),
          DataColumn(label: Text('创建时间')),
          DataColumn(label: Text('操作')),
        ],
        source: _MailAccountDataSource(
          _dataList,
          context,
          onEdit: _showAccountDialog,
          onDelete: _deleteAccount,
        ),
      ),
    );
  }
}

/// 数据源
class _MailAccountDataSource extends DataTableSource {
  final List<MailAccount> dataList;
  final BuildContext context;
  final void Function(MailAccount) onEdit;
  final void Function(MailAccount) onDelete;

  _MailAccountDataSource(
    this.dataList,
    this.context, {
    required this.onEdit,
    required this.onDelete,
  });

  @override
  int get rowCount => dataList.length;

  @override
  DataRow getRow(int index) {
    final item = dataList[index];
    return DataRow(
      cells: [
        DataCell(Text(item.id?.toString() ?? '-')),
        DataCell(Text(item.mail)),
        DataCell(Text(item.username)),
        DataCell(Text(item.host)),
        DataCell(Text(item.port.toString())),
        DataCell(_buildBoolTag(item.sslEnable)),
        DataCell(_buildBoolTag(item.starttlsEnable)),
        DataCell(Text(item.createTime ?? '-')),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => onEdit(item),
                child: const Text('编辑'),
              ),
              TextButton(
                onPressed: () => onDelete(item),
                child: const Text('删除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBoolTag(bool value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: value ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value ? '是' : '否',
        style: TextStyle(
          color: value ? Colors.green : Colors.grey,
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

/// 邮箱账号表单对话框
class _MailAccountFormDialog extends StatefulWidget {
  final MailAccount? account;
  final VoidCallback onSuccess;

  const _MailAccountFormDialog({
    this.account,
    required this.onSuccess,
  });

  @override
  State<_MailAccountFormDialog> createState() => _MailAccountFormDialogState();
}

class _MailAccountFormDialogState extends State<_MailAccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _mailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _remarkController = TextEditingController();

  bool _sslEnable = true;
  bool _starttlsEnable = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _mailController.text = widget.account!.mail;
      _usernameController.text = widget.account!.username;
      _passwordController.text = widget.account!.password;
      _hostController.text = widget.account!.host;
      _portController.text = widget.account!.port.toString();
      _remarkController.text = widget.account!.remark ?? '';
      _sslEnable = widget.account!.sslEnable;
      _starttlsEnable = widget.account!.starttlsEnable;
    }
  }

  @override
  void dispose() {
    _mailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = MailAccount(
        id: widget.account?.id,
        mail: _mailController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        host: _hostController.text,
        port: int.tryParse(_portController.text) ?? 25,
        sslEnable: _sslEnable,
        starttlsEnable: _starttlsEnable,
        remark: _remarkController.text.isNotEmpty ? _remarkController.text : null,
      );

      final container = ProviderScope.containerOf(context);
      final api = container.read(mailAccountApiProvider);

      final response = widget.account?.id != null
          ? await api.updateMailAccount(data)
          : await api.createMailAccount(data);

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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.account == null ? '添加邮箱账号' : '编辑邮箱账号'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _mailController,
                  decoration: const InputDecoration(
                    labelText: '邮箱',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty == true ? '请输入邮箱' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: '用户名',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty == true ? '请输入用户名' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: '密码',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) => v?.isEmpty == true ? '请输入密码' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hostController,
                  decoration: const InputDecoration(
                    labelText: 'SMTP服务器域名',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty == true ? '请输入SMTP服务器域名' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    labelText: 'SMTP服务器端口',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v?.isEmpty == true ? '请输入端口' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('是否开启SSL'),
                    const SizedBox(width: 16),
                    Switch(
                      value: _sslEnable,
                      onChanged: (v) => setState(() => _sslEnable = v),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('是否开启STARTTLS'),
                    const SizedBox(width: 16),
                    Switch(
                      value: _starttlsEnable,
                      onChanged: (v) => setState(() => _starttlsEnable = v),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _remarkController,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
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
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('确定'),
        ),
      ],
    );
  }
}