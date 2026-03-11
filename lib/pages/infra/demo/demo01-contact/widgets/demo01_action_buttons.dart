import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 示例联系人操作按钮组件
class Demo01ActionButtons extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onExport;
  final VoidCallback? onDeleteBatch;
  final bool hasSelection;

  const Demo01ActionButtons({
    super.key,
    required this.onAdd,
    required this.onExport,
    this.onDeleteBatch,
    this.hasSelection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 20),
            label: Text('${S.current.add}${S.current.demo01Contact}'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onExport,
            icon: const Icon(Icons.download, size: 20),
            label: Text(S.current.export),
          ),
          if (onDeleteBatch != null) ...[
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: hasSelection ? onDeleteBatch : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              icon: const Icon(Icons.delete_sweep, size: 20),
              label: Text(S.current.deleteBatch),
            ),
          ],
        ],
      ),
    );
  }
}