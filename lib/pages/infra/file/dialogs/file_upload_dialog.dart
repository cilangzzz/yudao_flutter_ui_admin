import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';
import 'package:dio/dio.dart';
import 'package:yudao_flutter_ui_admin/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 文件上传对话框
class FileUploadDialog extends StatefulWidget {
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const FileUploadDialog({
    super.key,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<FileUploadDialog> createState() => _FileUploadDialogState();
}

class _FileUploadDialogState extends State<FileUploadDialog> {
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;
  double _uploadProgress = 0;

  Future<void> _pickFile() async {
    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'files',
        extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'pdf', 'doc', 'docx', 'xls', 'xlsx'],
      );

      final XFile? result = await openFile(acceptedTypeGroups: [typeGroup]);

      if (result != null) {
        setState(() {
          _selectedFile = File(result.path);
          _fileName = result.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.selectFileFailed}: $e')),
        );
      }
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseSelectFile)),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final dio = widget.ref.read(dioProvider);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_selectedFile!.path, filename: _fileName),
      });

      final response = await dio.post(
        '/infra/file/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            setState(() {
              _uploadProgress = sent / total;
            });
          }
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['code'] == 0) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.uploadSuccess)),
            );
            widget.onSuccess();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['msg'] ?? S.current.uploadFailed)),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.current.uploadFailed)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.uploadFailed}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.current.uploadFile),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 文件选择区域
            GestureDetector(
              onTap: _isUploading ? null : _pickFile,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedFile != null
                          ? _fileName!
                          : S.current.clickOrDragToUpload,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.current.supportFileFormats,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isUploading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: _uploadProgress),
              const SizedBox(height: 8),
              Text('${S.current.uploading} ${(_uploadProgress * 100).toStringAsFixed(0)}%'),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.pop(context),
          child: Text(S.current.cancel),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _uploadFile,
          child: Text(S.current.upload),
        ),
      ],
    );
  }
}

/// 显示文件上传对话框的便捷方法
void showFileUploadDialog(
  BuildContext context, {
  required WidgetRef ref,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (context) => FileUploadDialog(
      ref: ref,
      onSuccess: onSuccess,
    ),
  );
}