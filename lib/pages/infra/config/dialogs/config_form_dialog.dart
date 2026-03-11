import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/config_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/config.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 参数配置表单对话框（新增/编辑参数配置）
class ConfigFormDialog extends StatefulWidget {
  final Config? config;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const ConfigFormDialog({
    super.key,
    this.config,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<ConfigFormDialog> createState() => _ConfigFormDialogState();
}

class _ConfigFormDialogState extends State<ConfigFormDialog> {
  late final TextEditingController _categoryController;
  late final TextEditingController _nameController;
  late final TextEditingController _keyController;
  late final TextEditingController _valueController;
  late final TextEditingController _remarkController;
  late bool _visible;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(text: widget.config?.category ?? '');
    _nameController = TextEditingController(text: widget.config?.name ?? '');
    _keyController = TextEditingController(text: widget.config?.key ?? '');
    _valueController = TextEditingController(text: widget.config?.value ?? '');
    _remarkController = TextEditingController(text: widget.config?.remark ?? '');
    _visible = widget.config?.visible ?? true;
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _nameController.dispose();
    _keyController.dispose();
    _valueController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_categoryController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _keyController.text.isEmpty ||
        _valueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseFillRequired)),
      );
      return;
    }

    final configData = Config(
      id: widget.config?.id,
      category: _categoryController.text,
      name: _nameController.text,
      key: _keyController.text,
      value: _valueController.text,
      visible: _visible,
      remark: _remarkController.text.isEmpty ? null : _remarkController.text,
    );

    try {
      final configApi = widget.ref.read(configApiProvider);
      ApiResponse<void> response;

      if (widget.config == null) {
        response = await configApi.createConfig(configData);
      } else {
        response = await configApi.updateConfig(configData);
      }

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.config == null ? S.current.addSuccess : S.current.editSuccess)),
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
    final isMobile = DeviceUIMode.isMobile(context);
    final screenWidth = DeviceUIMode.widthOf(context);
    final dialogWidth = isMobile ? screenWidth - 32 : 450.0;

    return AlertDialog(
      title: Text(widget.config == null ? S.current.addConfig : S.current.editConfig),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: '${S.current.configCategory} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${S.current.configName} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _keyController,
                decoration: InputDecoration(
                  labelText: '${S.current.configKey} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: '${S.current.configValue} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<bool>(
                value: _visible,
                decoration: InputDecoration(
                  labelText: S.current.visible,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: true, child: Text(S.current.yes)),
                  DropdownMenuItem(value: false, child: Text(S.current.no)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _visible = value);
                  }
                },
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

/// 显示参数配置表单对话框的便捷方法
void showConfigFormDialog(
  BuildContext context, {
  Config? config,
  required WidgetRef ref,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (context) => ConfigFormDialog(
      config: config,
      ref: ref,
      onSuccess: onSuccess,
    ),
  );
}