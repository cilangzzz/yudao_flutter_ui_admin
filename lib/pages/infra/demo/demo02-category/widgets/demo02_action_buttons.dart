import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 示例分类操作按钮组件
class Demo02ActionButtons extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onExpand;
  final VoidCallback onExport;
  final bool isExpanded;

  const Demo02ActionButtons({
    super.key,
    required this.onAdd,
    required this.onExpand,
    required this.onExport,
    this.isExpanded = true,
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
            label: Text('${S.current.add}${S.current.demo02Category}'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onExpand,
            icon: Icon(isExpanded ? Icons.unfold_less : Icons.unfold_more, size: 20),
            label: Text(isExpanded ? S.current.collapse : S.current.expand),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onExport,
            icon: const Icon(Icons.download, size: 20),
            label: Text(S.current.export),
          ),
        ],
      ),
    );
  }
}