import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/system/dict_data_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/dict_data.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 字典数据表单对话框（新增/编辑字典数据）
class DictDataFormDialog extends StatefulWidget {
  final DictData? dictData;
  final String? dictType;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const DictDataFormDialog({
    super.key,
    this.dictData,
    this.dictType,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<DictDataFormDialog> createState() => _DictDataFormDialogState();
}

class _DictDataFormDialogState extends State<DictDataFormDialog> {
  late final TextEditingController _labelController;
  late final TextEditingController _valueController;
  late final TextEditingController _sortController;
  late final TextEditingController _cssClassController;
  late final TextEditingController _remarkController;
  late String _colorType;
  late int _status;

  final _colorOptions = [
    {'value': '', 'label': S.current.none, 'color': Colors.grey},
    {'value': 'processing', 'label': S.current.colorPrimary, 'color': Colors.blue},
    {'value': 'success', 'label': S.current.colorSuccess, 'color': Colors.green},
    {'value': 'warning', 'label': S.current.colorWarning, 'color': Colors.orange},
    {'value': 'danger', 'label': S.current.colorDanger, 'color': Colors.red},
    {'value': 'info', 'label': S.current.colorInfo, 'color': Colors.cyan},
  ];

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.dictData?.label ?? '');
    _valueController = TextEditingController(text: widget.dictData?.value ?? '');
    _sortController = TextEditingController(text: (widget.dictData?.sort ?? 0).toString());
    _cssClassController = TextEditingController(text: widget.dictData?.cssClass ?? '');
    _remarkController = TextEditingController(text: widget.dictData?.remark ?? '');
    _colorType = widget.dictData?.colorType ?? '';
    _status = widget.dictData?.status ?? 0;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _valueController.dispose();
    _sortController.dispose();
    _cssClassController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_labelController.text.isEmpty || _valueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseFillRequired)),
      );
      return;
    }

    final data = DictData(
      id: widget.dictData?.id,
      label: _labelController.text,
      value: _valueController.text,
      dictType: widget.dictType,
      sort: int.tryParse(_sortController.text) ?? 0,
      colorType: _colorType.isEmpty ? null : _colorType,
      cssClass: _cssClassController.text.isEmpty ? null : _cssClassController.text,
      status: _status,
      remark: _remarkController.text.isEmpty ? null : _remarkController.text,
    );

    try {
      final api = widget.ref.read(dictDataApiProvider);
      final response = widget.dictData == null
          ? await api.createDictData(data)
          : await api.updateDictData(data);

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.dictData == null ? S.current.addSuccess : S.current.editSuccess)),
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
      title: Text(widget.dictData == null ? S.current.addDictData : S.current.editDictData),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 字典类型显示
              TextField(
                enabled: false,
                controller: TextEditingController(text: widget.dictType ?? ''),
                decoration: InputDecoration(
                  labelText: S.current.dictType,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: '${S.current.dataLabel} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: '${S.current.dataValue} *',
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
              DropdownButtonFormField<String>(
                value: _colorType,
                decoration: InputDecoration(
                  labelText: S.current.colorType,
                  border: const OutlineInputBorder(),
                ),
                items: _colorOptions.map((opt) {
                  return DropdownMenuItem(
                    value: opt['value'] as String,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: opt['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(opt['label'] as String),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _colorType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cssClassController,
                decoration: InputDecoration(
                  labelText: S.current.cssClass,
                  border: const OutlineInputBorder(),
                  hintText: S.current.cssClassHint,
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
          onPressed: _submit,
          child: Text(S.current.confirm),
        ),
      ],
    );
  }
}

/// 显示字典数据表单对话框的便捷方法
void showDictDataFormDialog(
  BuildContext context, {
  DictData? dictData,
  String? dictType,
  required WidgetRef ref,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (context) => DictDataFormDialog(
      dictData: dictData,
      dictType: dictType,
      ref: ref,
      onSuccess: onSuccess,
    ),
  );
}