import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/system/role_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/role.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 角色表单对话框（新增/编辑角色）
class RoleFormDialog extends StatefulWidget {
  final Role? role;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const RoleFormDialog({
    super.key,
    this.role,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<RoleFormDialog> createState() => _RoleFormDialogState();
}

class _RoleFormDialogState extends State<RoleFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _sortController;
  late int _status;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role?.name ?? '');
    _codeController = TextEditingController(text: widget.role?.code ?? '');
    _sortController = TextEditingController(text: widget.role?.sort?.toString() ?? '0');
    _status = widget.role?.status ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _sortController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty || _codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.requiredField)),
      );
      return;
    }

    Navigator.pop(context);

    final roleData = Role(
      id: widget.role?.id,
      name: _nameController.text,
      code: _codeController.text,
      sort: int.tryParse(_sortController.text) ?? 0,
      status: _status,
    );

    try {
      final roleApi = widget.ref.read(roleApiProvider);
      final response = widget.role == null
          ? await roleApi.createRole(roleData)
          : await roleApi.updateRole(roleData);

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.current.saveSuccess)),
          );
        }
        widget.onSuccess();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.saveFailed), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.role == null ? S.current.addRole : S.current.editRole),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${S.current.roleName} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: '${S.current.roleCode} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _sortController,
                decoration: InputDecoration(
                  labelText: S.current.sort,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _status,
                decoration: InputDecoration(
                  labelText: S.current.status,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 0, child: Text(S.current.enabled)),
                  DropdownMenuItem(value: 1, child: Text(S.current.disabled)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
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

/// 显示角色表单对话框的便捷方法
void showRoleFormDialog(
  BuildContext context, {
  Role? role,
  required WidgetRef ref,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (context) => RoleFormDialog(
      role: role,
      ref: ref,
      onSuccess: onSuccess,
    ),
  );
}