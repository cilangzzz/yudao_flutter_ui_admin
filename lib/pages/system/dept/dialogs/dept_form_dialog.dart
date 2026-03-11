import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/system/dept_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/dept.dart';
import 'package:yudao_flutter_ui_admin/models/system/user.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 部门表单对话框（新增/编辑部门）
class DeptFormDialog extends StatefulWidget {
  final Dept? dept;
  final int? parentId;
  final WidgetRef ref;
  final List<Dept> deptTree;
  final List<SimpleUser> userList;
  final VoidCallback onSuccess;

  const DeptFormDialog({
    super.key,
    this.dept,
    this.parentId,
    required this.ref,
    required this.deptTree,
    required this.userList,
    required this.onSuccess,
  });

  @override
  State<DeptFormDialog> createState() => _DeptFormDialogState();
}

class _DeptFormDialogState extends State<DeptFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _sortController;
  int? _selectedParentId;
  int? _selectedLeaderUserId;
  late int _status;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dept?.name ?? '');
    _phoneController = TextEditingController(text: widget.dept?.phone ?? '');
    _emailController = TextEditingController(text: widget.dept?.email ?? '');
    _sortController = TextEditingController(text: (widget.dept?.sort ?? 0).toString());
    _selectedParentId = widget.dept?.parentId ?? widget.parentId;
    _selectedLeaderUserId = widget.dept?.leaderUserId;
    _status = widget.dept?.status ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _sortController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseFillRequired)),
      );
      return;
    }

    final deptData = Dept(
      id: widget.dept?.id,
      name: _nameController.text,
      parentId: _selectedParentId,
      leaderUserId: _selectedLeaderUserId,
      phone: _phoneController.text.isEmpty ? null : _phoneController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      sort: int.tryParse(_sortController.text) ?? 0,
      status: _status,
    );

    try {
      final deptApi = widget.ref.read(deptApiProvider);
      final response = widget.dept == null
          ? await deptApi.createDept(deptData)
          : await deptApi.updateDept(deptData);

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.dept == null ? S.current.addSuccess : S.current.editSuccess)),
          );
          widget.onSuccess();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.operationFailed)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.operationFailed}: $e')),
        );
      }
    }
  }

  List<DropdownMenuItem<int?>> _buildDeptDropdownItems(List<Dept> depts, int level, [int? excludeId]) {
    final items = <DropdownMenuItem<int?>>[];
    for (final dept in depts) {
      // 排除当前编辑的部门及其子部门
      if (dept.id == excludeId) continue;

      items.add(DropdownMenuItem(
        value: dept.id,
        child: Padding(
          padding: EdgeInsets.only(left: 16.0 * level),
          child: Text(dept.name),
        ),
      ));
      if (dept.children != null && dept.children!.isNotEmpty) {
        items.addAll(_buildDeptDropdownItems(dept.children!, level + 1, excludeId));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dept == null ? S.current.addDept : S.current.editDept),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 上级部门
              DropdownButtonFormField<int?>(
                value: _selectedParentId,
                decoration: InputDecoration(
                  labelText: S.current.parentDept,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(S.current.topDept),
                  ),
                  ..._buildDeptDropdownItems(widget.deptTree, 0, widget.dept?.id),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedParentId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // 部门名称
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${S.current.deptName} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // 负责人
              DropdownButtonFormField<int?>(
                value: _selectedLeaderUserId,
                decoration: InputDecoration(
                  labelText: S.current.leader,
                  border: const OutlineInputBorder(),
                ),
                items: widget.userList.map((user) => DropdownMenuItem(
                  value: user.id,
                  child: Text(user.nickname),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLeaderUserId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // 联系电话
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: S.current.phone,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              // 邮箱
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: S.current.email,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // 显示顺序
              TextField(
                controller: _sortController,
                decoration: InputDecoration(
                  labelText: '${S.current.sort} *',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // 状态
              Row(
                children: [
                  Text('${S.current.status}: '),
                  Radio<int>(
                    value: 0,
                    groupValue: _status,
                    onChanged: (value) {
                      setState(() {
                        _status = value!;
                      });
                    },
                  ),
                  Text(S.current.enabled),
                  Radio<int>(
                    value: 1,
                    groupValue: _status,
                    onChanged: (value) {
                      setState(() {
                        _status = value!;
                      });
                    },
                  ),
                  Text(S.current.disabled),
                ],
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
          onPressed: _submit,
          child: Text(S.current.confirm),
        ),
      ],
    );
  }
}

/// 显示部门表单对话框的便捷方法
void showDeptFormDialog(
  BuildContext context, {
  Dept? dept,
  int? parentId,
  required WidgetRef ref,
  required List<Dept> deptTree,
  required List<SimpleUser> userList,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (context) => DeptFormDialog(
      dept: dept,
      parentId: parentId,
      ref: ref,
      deptTree: deptTree,
      userList: userList,
      onSuccess: onSuccess,
    ),
  );
}