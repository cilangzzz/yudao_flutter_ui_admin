import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 定时任务操作按钮组件（工具栏）
class JobActionButtons extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onExport;
  final VoidCallback onViewLog;
  final bool hasSelection;
  final VoidCallback onDeleteBatch;

  const JobActionButtons({
    super.key,
    required this.onAdd,
    required this.onExport,
    required this.onViewLog,
    required this.hasSelection,
    required this.onDeleteBatch,
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
            onPressed: onAdd,
            icon: isMobile ? null : const Icon(Icons.add),
            label: Text(S.current.addJob),
          ),
          if (!isMobile)
            ElevatedButton.icon(
              onPressed: onExport,
              icon: const Icon(Icons.download),
              label: Text(S.current.export),
            ),
          ElevatedButton.icon(
            onPressed: onViewLog,
            icon: isMobile ? null : const Icon(Icons.history),
            label: Text(S.current.jobLog),
          ),
          OutlinedButton.icon(
            onPressed: hasSelection ? onDeleteBatch : null,
            icon: const Icon(Icons.delete, color: Colors.red),
            label: Text(
              S.current.deleteBatch,
              style: TextStyle(color: hasSelection ? Colors.red : Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}