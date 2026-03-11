import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 文件配置操作按钮组件（工具栏）
class FileConfigActionButtons extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback? onDeleteBatch;

  const FileConfigActionButtons({
    super.key,
    required this.onAdd,
    this.onDeleteBatch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(S.current.addFileConfig),
          ),
          if (onDeleteBatch != null)
            ElevatedButton.icon(
              onPressed: onDeleteBatch,
              icon: const Icon(Icons.delete),
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