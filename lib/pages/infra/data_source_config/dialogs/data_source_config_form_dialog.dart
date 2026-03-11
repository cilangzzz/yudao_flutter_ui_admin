import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/data_source_config_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/data_source_config.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 数据源配置表单对话框（新增/编辑数据源配置）
class DataSourceConfigFormDialog extends StatefulWidget {
  final DataSourceConfig? dataSourceConfig;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const DataSourceConfigFormDialog({
    super.key,
    this.dataSourceConfig,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<DataSourceConfigFormDialog> createState() => _DataSourceConfigFormDialogState();
}

class _DataSourceConfigFormDialogState extends State<DataSourceConfigFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dataSourceConfig?.name ?? '');
    _urlController = TextEditingController(text: widget.dataSourceConfig?.url ?? '');
    _usernameController = TextEditingController(text: widget.dataSourceConfig?.username ?? '');
    _passwordController = TextEditingController(text: widget.dataSourceConfig?.password ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty ||
        _urlController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseFillRequired)),
      );
      return;
    }

    final dataSourceConfigData = DataSourceConfig(
      id: widget.dataSourceConfig?.id,
      name: _nameController.text,
      url: _urlController.text,
      username: _usernameController.text,
      password: _passwordController.text,
    );

    try {
      final dataSourceConfigApi = widget.ref.read(dataSourceConfigApiProvider);
      ApiResponse<void> response;

      if (widget.dataSourceConfig == null) {
        response = await dataSourceConfigApi.createDataSourceConfig(dataSourceConfigData);
      } else {
        response = await dataSourceConfigApi.updateDataSourceConfig(dataSourceConfigData);
      }

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.dataSourceConfig == null ? S.current.addSuccess : S.current.editSuccess)),
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
      title: Text(widget.dataSourceConfig == null ? S.current.addDataSourceConfig : S.current.editDataSourceConfig),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${S.current.dataSourceConfigName} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: '${S.current.dataSourceUrl} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: '${S.current.username} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '${S.current.password} *',
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
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

/// 显示数据源配置表单对话框的便捷方法
void showDataSourceConfigFormDialog(
  BuildContext context, {
  DataSourceConfig? dataSourceConfig,
  required WidgetRef ref,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (context) => DataSourceConfigFormDialog(
      dataSourceConfig: dataSourceConfig,
      ref: ref,
      onSuccess: onSuccess,
    ),
  );
}