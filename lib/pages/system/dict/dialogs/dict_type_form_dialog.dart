import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/system/dict_type_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/dict_type.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 字典类型表单对话框（新增/编辑字典类型）
class DictTypeFormDialog extends StatefulWidget {
  final DictType? dictType;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const DictTypeFormDialog({
    super.key,
    this.dictType,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<DictTypeFormDialog> createState() => _DictTypeFormDialogState();
}

class _DictTypeFormDialogState extends State<DictTypeFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _typeController;
  late final TextEditingController _remarkController;
  late int _status;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dictType?.name ?? '');
    _typeController = TextEditingController(text: widget.dictType?.type ?? '');
    _remarkController = TextEditingController(text: widget.dictType?.remark ?? '');
    _status = widget.dictType?.status ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty || _typeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseFillRequired)),
      );
      return;
    }

    final data = DictType(
      id: widget.dictType?.id,
      name: _nameController.text,
      type: _typeController.text,
      status: _status,
      remark: _remarkController.text.isEmpty ? null : _remarkController.text,
    );

    try {
      final api = widget.ref.read(dictTypeApiProvider);
      final response = widget.dictType == null
          ? await api.createDictType(data)
          : await api.updateDictType(data);

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.dictType == null ? S.current.addSuccess : S.current.editSuccess)),
          );
        }
        widget.onSuccess();
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dictType == null ? S.current.addDictType : S.current.editDictType),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${S.current.dictName} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _typeController,
                enabled: widget.dictType == null, // 编辑时不可修改类型
                decoration: InputDecoration(
                  labelText: '${S.current.dictType} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('${S.current.status}: '),
                  Radio<int>(
                    value: 0,
                    groupValue: _status,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
                  ),
                  Text(S.current.enabled),
                  Radio<int>(
                    value: 1,
                    groupValue: _status,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
                  ),
                  Text(S.current.disabled),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _remarkController,
                decoration: InputDecoration(
                  labelText: S.current.remark,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
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

/// 显示字典类型表单对话框的便捷方法
void showDictTypeFormDialog(
  BuildContext context, {
  DictType? dictType,
  required WidgetRef ref,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (context) => DictTypeFormDialog(
      dictType: dictType,
      ref: ref,
      onSuccess: onSuccess,
    ),
  );
}