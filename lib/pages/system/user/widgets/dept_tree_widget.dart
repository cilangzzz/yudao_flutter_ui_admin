import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/models/system/dept.dart';

/// 部门树组件
class DeptTreeWidget extends StatelessWidget {
  final List<Dept> depts;
  final int? selectedDeptId;
  final Map<int, bool> expandedMap;
  final void Function(Dept dept) onDeptSelect;
  final void Function(int deptId) onToggleExpand;

  const DeptTreeWidget({
    super.key,
    required this.depts,
    required this.selectedDeptId,
    required this.expandedMap,
    required this.onDeptSelect,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: depts.length,
      itemBuilder: (context, index) {
        final dept = depts[index];
        return _buildDeptTile(context, dept, 0);
      },
    );
  }

  Widget _buildDeptTile(BuildContext context, Dept dept, int level) {
    final hasChildren = dept.children != null && dept.children!.isNotEmpty;
    final isSelected = selectedDeptId == dept.id;
    // 默认折叠所有节点
    final isExpanded = expandedMap[dept.id] ?? false;

    return Column(
      children: [
        InkWell(
          onTap: () => onDeptSelect(dept),
          child: Padding(
            padding: EdgeInsets.only(left: 16.0 * level, top: 8, bottom: 8),
            child: Row(
              children: [
                // 展开/折叠图标
                if (hasChildren)
                  GestureDetector(
                    onTap: () => onToggleExpand(dept.id!),
                    child: Icon(
                      isExpanded ? Icons.expand_more : Icons.chevron_right,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  )
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 4),
                Icon(
                  hasChildren ? Icons.folder : Icons.folder_open,
                  size: 18,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dept.name,
                    style: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 只在展开时渲染子节点
        if (hasChildren && isExpanded)
          ...dept.children!.map((child) => _buildDeptTile(context, child, level + 1)),
      ],
    );
  }
}