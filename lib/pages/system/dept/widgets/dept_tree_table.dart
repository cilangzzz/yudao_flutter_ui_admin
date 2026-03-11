import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../../models/system/dept.dart';
import '../../../../models/system/user.dart';
import '../../../../i18n/i18n.dart';
import 'dept_action_buttons.dart';

/// 扁平化的部门数据，用于展示
class FlatDept {
  final Dept dept;
  final int level;
  final bool hasChildren;

  const FlatDept({
    required this.dept,
    required this.level,
    required this.hasChildren,
  });
}

/// 部门树形表格组件
class DeptTreeTable extends StatelessWidget {
  final List<Dept> deptList;
  final List<Dept> deptTree;
  final List<SimpleUser> userList;
  final Set<int> selectedIds;
  final Map<int, bool> expandedMap;
  final bool isLoading;
  final String? error;
  final void Function() onReload;
  final void Function(int deptId) onToggleExpand;
  final void Function(Set<int> selectedIds) onSelectionChanged;
  final void Function(Dept dept) onEdit;
  final void Function(Dept dept, int? parentId) onAddChild;
  final void Function(Dept dept) onDelete;

  const DeptTreeTable({
    super.key,
    required this.deptList,
    required this.deptTree,
    required this.userList,
    required this.selectedIds,
    required this.expandedMap,
    required this.isLoading,
    required this.error,
    required this.onReload,
    required this.onToggleExpand,
    required this.onSelectionChanged,
    required this.onEdit,
    required this.onAddChild,
    required this.onDelete,
  });

  /// 将树形数据扁平化为带层级的列表
  List<FlatDept> _flattenDeptTree(List<Dept> depts, int level) {
    final result = <FlatDept>[];
    for (final dept in depts) {
      final hasChildren = dept.children != null && dept.children!.isNotEmpty;
      // 默认折叠所有节点，优化大数据量性能
      final isExpanded = expandedMap[dept.id] ?? false;
      result.add(FlatDept(dept: dept, level: level, hasChildren: hasChildren));

      if (hasChildren && isExpanded) {
        result.addAll(_flattenDeptTree(dept.children!, level + 1));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${S.current.loadFailed}: $error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onReload, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (deptTree.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    final flatDepts = _flattenDeptTree(deptTree, 0);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: selectedIds.length == deptList.length && deptList.isNotEmpty,
                tristate: true,
                onChanged: (value) {
                  if (value == true) {
                    onSelectionChanged(deptList.where((d) => d.id != null).map((d) => d.id!).toSet());
                  } else {
                    onSelectionChanged({});
                  }
                },
              ),
              Text(S.current.deptList),
              const Spacer(),
              Text('${S.current.total}: ${deptList.length}'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 800,
              smRatio: 0.75,
              lmRatio: 1.5,
              headingRowColor: WidgetStateProperty.resolveWith(
                (states) => Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              headingTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              columns: [
                DataColumn2(
                  label: Text(S.current.deptName),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.leader),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.phone),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.sort),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.status),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.createTime),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.operation),
                  size: ColumnSize.M,
                ),
              ],
              rows: flatDepts.map((flatDept) {
                final dept = flatDept.dept;
                final isSelected = dept.id != null && selectedIds.contains(dept.id);
                final hasChildren = flatDept.hasChildren;
                final isExpanded = expandedMap[dept.id] ?? true;
                final level = flatDept.level;

                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    if (dept.id != null) {
                      final newSelectedIds = Set<int>.from(selectedIds);
                      if (selected == true) {
                        newSelectedIds.add(dept.id!);
                      } else {
                        newSelectedIds.remove(dept.id!);
                      }
                      onSelectionChanged(newSelectedIds);
                    }
                  },
                  cells: [
                    DataCell(
                      InkWell(
                        onTap: hasChildren ? () => onToggleExpand(dept.id!) : null,
                        child: Padding(
                          padding: EdgeInsets.only(left: level * 24.0),
                          child: Row(
                            children: [
                              if (hasChildren)
                                Icon(
                                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                                  size: 20,
                                )
                              else
                                const SizedBox(width: 20),
                              const SizedBox(width: 4),
                              Icon(
                                hasChildren ? Icons.folder : Icons.folder_open,
                                size: 20,
                                color: hasChildren ? Colors.amber : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(dept.name)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(userList.firstWhere(
                        (u) => u.id == dept.leaderUserId,
                        orElse: () => SimpleUser(id: -1, nickname: '-', username: '-'),
                      ).nickname),
                    ),
                    DataCell(Text(dept.phone ?? '-')),
                    DataCell(Text(dept.sort?.toString() ?? '0')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: dept.status == 0
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          dept.status == 0 ? S.current.enabled : S.current.disabled,
                          style: TextStyle(
                            color: dept.status == 0 ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(dept.createTime?.toString().substring(0, 19) ?? '-')),
                    DataCell(
                      DeptActionButtons(
                        dept: dept,
                        onEdit: () => onEdit(dept),
                        onAddChild: () => onAddChild(dept, dept.id),
                        onDelete: () => onDelete(dept),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}