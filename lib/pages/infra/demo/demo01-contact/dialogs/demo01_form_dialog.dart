import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/demo01_contact_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo01_contact.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 示例联系人表单对话框（新增/编辑）
class Demo01FormDialog extends StatefulWidget {
  final Demo01Contact? contact;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const Demo01FormDialog({
    super.key,
    this.contact,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<Demo01FormDialog> createState() => _Demo01FormDialogState();
}

class _Demo01FormDialogState extends State<Demo01FormDialog> {
  late final TextEditingController _nameController;
  late int _sex;
  DateTime? _birthday;
  late final TextEditingController _descriptionController;
  late final TextEditingController _avatarController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _sex = widget.contact?.sex ?? 1;
    if (widget.contact?.birthday != null) {
      _birthday = DateTime.fromMillisecondsSinceEpoch(widget.contact!.birthday!);
    }
    _descriptionController = TextEditingController(text: widget.contact?.description ?? '');
    _avatarController = TextEditingController(text: widget.contact?.avatar ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseFillRequired)),
      );
      return;
    }

    final contactData = Demo01Contact(
      id: widget.contact?.id,
      name: _nameController.text,
      sex: _sex,
      birthday: _birthday?.millisecondsSinceEpoch,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      avatar: _avatarController.text.isEmpty ? null : _avatarController.text,
    );

    try {
      final contactApi = widget.ref.read(demo01ContactApiProvider);
      ApiResponse<void> response;

      if (widget.contact == null) {
        response = await contactApi.createDemo01Contact(contactData);
      } else {
        response = await contactApi.updateDemo01Contact(contactData);
      }

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.contact == null ? S.current.addSuccess : S.current.editSuccess)),
          );
          widget.onSuccess();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg ?? S.current.operationFailed)),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.contact == null
        ? '${S.current.add}${S.current.demo01Contact}'
        : '${S.current.edit}${S.current.demo01Contact}'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${S.current.name} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _sex,
                decoration: InputDecoration(
                  labelText: S.current.sex,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 1, child: Text(S.current.male)),
                  DropdownMenuItem(value: 2, child: Text(S.current.female)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _sex = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _birthday ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _birthday = date);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: S.current.birthday,
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(
                    _birthday != null
                      ? '${_birthday!.year}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}'
                      : S.current.selectDate,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: S.current.description,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _avatarController,
                decoration: InputDecoration(
                  labelText: S.current.avatarUrl,
                  border: const OutlineInputBorder(),
                ),
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

/// 显示示例联系人表单对话框的便捷方法
void showDemo01FormDialog(
  BuildContext context, {
  Demo01Contact? contact,
  required WidgetRef ref,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (context) => Demo01FormDialog(
      contact: contact,
      ref: ref,
      onSuccess: onSuccess,
    ),
  );
}