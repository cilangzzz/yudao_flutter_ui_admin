import 'package:flutter/material.dart';
import '../../../../i18n/i18n.dart';

/// 代码生成操作按钮组件
class CodegenActionButtons extends StatelessWidget {
  final VoidCallback onImport;
  final VoidCallback? onDeleteBatch;

  const CodegenActionButtons({
    super.key,
    required this.onImport,
    this.onDeleteBatch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: onImport,
            icon: const Icon(Icons.add),
            label: Text(S.current.import),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onDeleteBatch,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete),
            label: Text(S.current.deleteBatch),
          ),
        ],
      ),
    );
  }
}