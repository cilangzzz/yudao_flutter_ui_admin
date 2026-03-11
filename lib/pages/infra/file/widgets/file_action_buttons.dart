import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 文件操作按钮组件（工具栏）
class FileActionButtons extends StatelessWidget {
  final VoidCallback onUpload;
  final VoidCallback? onDeleteBatch;

  const FileActionButtons({
    super.key,
    required this.onUpload,
    this.onDeleteBatch,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: onUpload,
            icon: isMobile ? null : const Icon(Icons.upload),
            label: Text(S.current.uploadFile),
          ),
          if (onDeleteBatch != null)
            ElevatedButton.icon(
              onPressed: onDeleteBatch,
              icon: isMobile ? null : const Icon(Icons.delete),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              label: Text(S.current.deleteBatch),
            ),
        ],
      ),
    );
  }
}