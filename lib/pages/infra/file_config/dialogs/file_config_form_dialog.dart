import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/file_config_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/file_config.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 文件配置表单对话框（新增/编辑）
class FileConfigFormDialog extends StatefulWidget {
  final FileConfig? config;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const FileConfigFormDialog({
    super.key,
    this.config,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<FileConfigFormDialog> createState() => _FileConfigFormDialogState();
}

class _FileConfigFormDialogState extends State<FileConfigFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _remarkController;
  late int? _selectedStorage;
  late bool _isEdit;

  // DB/Local/FTP/SFTP 配置
  late final TextEditingController _basePathController;
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late String _ftpMode;

  // S3 配置
  late final TextEditingController _endpointController;
  late final TextEditingController _bucketController;
  late final TextEditingController _accessKeyController;
  late final TextEditingController _accessSecretController;
  late final TextEditingController _regionController;
  late bool _pathStyleEnabled;
  late bool _publicAccessEnabled;

  // 通用配置
  late final TextEditingController _domainController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.config?.id != null;
    _nameController = TextEditingController(text: widget.config?.name ?? '');
    _remarkController = TextEditingController(text: widget.config?.remark ?? '');
    _selectedStorage = widget.config?.storage;

    _basePathController = TextEditingController(text: widget.config?.config?.basePath ?? '');
    _hostController = TextEditingController(text: widget.config?.config?.host ?? '');
    _portController = TextEditingController(text: widget.config?.config?.port?.toString() ?? '');
    _usernameController = TextEditingController(text: widget.config?.config?.username ?? '');
    _passwordController = TextEditingController(text: widget.config?.config?.password ?? '');
    _ftpMode = widget.config?.config?.mode ?? 'Passive';

    _endpointController = TextEditingController(text: widget.config?.config?.endpoint ?? '');
    _bucketController = TextEditingController(text: widget.config?.config?.bucket ?? '');
    _accessKeyController = TextEditingController(text: widget.config?.config?.accessKey ?? '');
    _accessSecretController = TextEditingController(text: widget.config?.config?.accessSecret ?? '');
    _regionController = TextEditingController(text: widget.config?.config?.region ?? '');
    _pathStyleEnabled = widget.config?.config?.pathStyle ?? false;
    _publicAccessEnabled = widget.config?.config?.enablePublicAccess ?? false;

    _domainController = TextEditingController(text: widget.config?.config?.domain ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _remarkController.dispose();
    _basePathController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _endpointController.dispose();
    _bucketController.dispose();
    _accessKeyController.dispose();
    _accessSecretController.dispose();
    _regionController.dispose();
    _domainController.dispose();
    super.dispose();
  }

  bool get _isFtpOrSftp => _selectedStorage == 11 || _selectedStorage == 12;
  bool get _isDb => _selectedStorage == 10;
  bool get _isS3 => _selectedStorage == 20;
  bool get _isLocalOrDb => _selectedStorage != null && _selectedStorage! <= 10;

  FileClientConfig _buildClientConfig() {
    return FileClientConfig(
      basePath: _basePathController.text.isNotEmpty ? _basePathController.text : '',
      host: _hostController.text.isNotEmpty ? _hostController.text : null,
      port: _portController.text.isNotEmpty ? int.tryParse(_portController.text) : null,
      username: _usernameController.text.isNotEmpty ? _usernameController.text : null,
      password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      mode: _isFtpOrSftp ? _ftpMode : null,
      endpoint: _endpointController.text.isNotEmpty ? _endpointController.text : null,
      bucket: _bucketController.text.isNotEmpty ? _bucketController.text : null,
      accessKey: _accessKeyController.text.isNotEmpty ? _accessKeyController.text : null,
      accessSecret: _accessSecretController.text.isNotEmpty ? _accessSecretController.text : null,
      pathStyle: _isS3 ? _pathStyleEnabled : null,
      enablePublicAccess: _isS3 ? _publicAccessEnabled : null,
      region: _regionController.text.isNotEmpty ? _regionController.text : null,
      domain: _domainController.text,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final configData = FileConfig(
        id: widget.config?.id,
        name: _nameController.text,
        storage: _selectedStorage,
        config: _buildClientConfig(),
        remark: _remarkController.text.isNotEmpty ? _remarkController.text : null,
      );

      final configApi = widget.ref.read(fileConfigApiProvider);
      ApiResponse<void> response;

      if (_isEdit) {
        response = await configApi.updateFileConfig(configData);
      } else {
        response = await configApi.createFileConfig(configData);
      }

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_isEdit ? S.current.editSuccess : S.current.addSuccess)),
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);
    final screenWidth = DeviceUIMode.widthOf(context);
    final dialogWidth = isMobile ? screenWidth - 32 : 600.0;

    return AlertDialog(
      title: Text(_isEdit ? S.current.editFileConfig : S.current.addFileConfig),
      content: SizedBox(
        width: dialogWidth,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 基本信息
                _buildSection(S.current.basicInfo, [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: '${S.current.configName} *',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return S.current.pleaseEnterName;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedStorage,
                    decoration: InputDecoration(
                      labelText: '${S.current.storage} *',
                      border: const OutlineInputBorder(),
                    ),
                    items: StorageType.values.map((type) => DropdownMenuItem(
                      value: type.value,
                      child: Text(type.label),
                    )).toList(),
                    onChanged: _isEdit ? null : (value) {
                      setState(() => _selectedStorage = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return S.current.pleaseSelectStorage;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _remarkController,
                    decoration: InputDecoration(
                      labelText: S.current.remark,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ]),

                // DB/Local/FTP/SFTP 配置
                if (_selectedStorage != null && (_isDb || _isFtpOrSftp || _isLocalOrDb)) ...[
                  const SizedBox(height: 24),
                  _buildSection(_isS3 ? 'S3 ${S.current.config}' : S.current.storageConfig, [
                    if (_isDb || _isFtpOrSftp) ...[
                      TextFormField(
                        controller: _basePathController,
                        decoration: InputDecoration(
                          labelText: '${S.current.basePath} *',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if ((_isDb || _isFtpOrSftp) && (value == null || value.isEmpty)) {
                            return S.current.pleaseEnterBasePath;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_isFtpOrSftp) ...[
                      TextFormField(
                        controller: _hostController,
                        decoration: InputDecoration(
                          labelText: '${S.current.hostAddress} *',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_isFtpOrSftp && (value == null || value.isEmpty)) {
                            return S.current.pleaseEnterHost;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _portController,
                        decoration: InputDecoration(
                          labelText: '${S.current.hostPort} *',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (_isFtpOrSftp && (value == null || value.isEmpty)) {
                            return S.current.pleaseEnterPort;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: '${S.current.username} *',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_isFtpOrSftp && (value == null || value.isEmpty)) {
                            return S.current.pleaseEnterUsername;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: '${S.current.password} *',
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (_isFtpOrSftp && (value == null || value.isEmpty)) {
                            return S.current.pleaseEnterPassword;
                          }
                          return null;
                        },
                      ),
                    ],
                    if (_selectedStorage == 11) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _ftpMode,
                        decoration: InputDecoration(
                          labelText: '${S.current.connectionMode} *',
                          border: const OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Active', child: Text('主动模式')),
                          DropdownMenuItem(value: 'Passive', child: Text('被动模式')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _ftpMode = value);
                          }
                        },
                      ),
                    ],
                  ]),
                ],

                // S3 配置
                if (_isS3) ...[
                  const SizedBox(height: 24),
                  _buildSection('S3 ${S.current.config}', [
                    TextFormField(
                      controller: _endpointController,
                      decoration: InputDecoration(
                        labelText: '${S.current.endpoint} *',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_isS3 && (value == null || value.isEmpty)) {
                          return S.current.pleaseEnterEndpoint;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bucketController,
                      decoration: InputDecoration(
                        labelText: '${S.current.bucket} *',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_isS3 && (value == null || value.isEmpty)) {
                          return S.current.pleaseEnterBucket;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accessKeyController,
                      decoration: InputDecoration(
                        labelText: 'Access Key *',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_isS3 && (value == null || value.isEmpty)) {
                          return S.current.pleaseEnterAccessKey;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accessSecretController,
                      decoration: InputDecoration(
                        labelText: 'Access Secret *',
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (_isS3 && (value == null || value.isEmpty)) {
                          return S.current.pleaseEnterAccessSecret;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<bool>(
                      value: _pathStyleEnabled,
                      decoration: InputDecoration(
                        labelText: S.current.pathStyle,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: true, child: Text(S.current.enabled)),
                        DropdownMenuItem(value: false, child: Text(S.current.disabled)),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _pathStyleEnabled = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<bool>(
                      value: _publicAccessEnabled,
                      decoration: InputDecoration(
                        labelText: S.current.publicAccess,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: true, child: Text(S.current.public)),
                        DropdownMenuItem(value: false, child: Text(S.current.private)),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _publicAccessEnabled = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _regionController,
                      decoration: InputDecoration(
                        labelText: S.current.region,
                        hintText: S.current.regionHint,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ]),
                ],

                // 通用配置
                if (_selectedStorage != null) ...[
                  const SizedBox(height: 24),
                  _buildSection(S.current.commonConfig, [
                    TextFormField(
                      controller: _domainController,
                      decoration: InputDecoration(
                        labelText: '${S.current.customDomain} *',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_selectedStorage != null && (value == null || value.isEmpty)) {
                          return S.current.pleaseEnterDomain;
                        }
                        return null;
                      },
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(S.current.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(S.current.confirm),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

/// 显示文件配置表单对话框的便捷方法
void showFileConfigFormDialog(
  BuildContext context, {
  FileConfig? config,
  required WidgetRef ref,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (context) => FileConfigFormDialog(
      config: config,
      ref: ref,
      onSuccess: onSuccess,
    ),
  );
}