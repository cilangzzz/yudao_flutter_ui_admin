import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 字典数据操作按钮组件
class DictDataActionButtons extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback? onDeleteSelected;
  final bool hasSelection;
  final bool hasDictType;
  final int totalCount;

  const DictDataActionButtons({
    super.key,
    required this.onAdd,
    this.onDeleteSelected,
    required this.hasSelection,
    required this.hasDictType,
    required this.totalCount,
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
            onPressed: hasDictType ? onAdd : null,
            icon: const Icon(Icons.add),
            label: Text(S.current.addDictData),
          ),
          ElevatedButton.icon(
            onPressed: hasSelection ? onDeleteSelected : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete),
            label: Text(S.current.deleteBatch),
          ),
          const SizedBox(width: 16),
          Text('${S.current.total}: $totalCount'),
        ],
      ),
    );
  }
}