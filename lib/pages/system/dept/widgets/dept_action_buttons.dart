import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/models/system/dept.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 部门行内操作按钮组件（表格每行的操作按钮）
class DeptActionButtons extends StatelessWidget {
  final Dept dept;
  final VoidCallback onEdit;
  final VoidCallback onAddChild;
  final VoidCallback onDelete;

  const DeptActionButtons({
    super.key,
    required this.dept,
    required this.onEdit,
    required this.onAddChild,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: onEdit,
          child: Text(S.current.edit),
        ),
        PopupMenuButton<String>(
          tooltip: S.current.more,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'addChild',
              child: Row(
                children: [
                  const Icon(Icons.add, size: 18),
                  const SizedBox(width: 8),
                  Text(S.current.addChild),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(S.current.delete, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'addChild':
                onAddChild();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
        ),
      ],
    );
  }
}

/// 部门工具栏操作按钮组件
class DeptToolbarButtons extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onToggleExpand;
  final VoidCallback onDeleteSelected;
  final bool isExpanded;
  final bool hasSelection;

  const DeptToolbarButtons({
    super.key,
    required this.onAdd,
    required this.onToggleExpand,
    required this.onDeleteSelected,
    required this.isExpanded,
    required this.hasSelection,
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
            icon: const Icon(Icons.add, size: 20),
            label: Text(S.current.addDept),
          ),
          OutlinedButton.icon(
            onPressed: onToggleExpand,
            icon: Icon(isExpanded ? Icons.unfold_less : Icons.unfold_more, size: 20),
            label: Text(isExpanded ? S.current.collapseAll : S.current.expandAll),
          ),
          ElevatedButton.icon(
            onPressed: hasSelection ? onDeleteSelected : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete, size: 20),
            label: Text(S.current.deleteBatch),
          ),
        ],
      ),
    );
  }
}