import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/models/system/role.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 角色数据表格组件
class RoleDataTable extends StatelessWidget {
  final List<Role> roleList;
  final Set<int> selectedIds;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool isLoading;
  final String? error;
  final void Function() onReload;
  final void Function(int pageSize) onPageSizeChanged;
  final void Function(int page) onPageChanged;
  final void Function(Set<int> selectedIds) onSelectionChanged;
  final void Function(Role role) onEdit;
  final void Function(Role role) onAssignMenu;
  final void Function(Role role) onAssignDataScope;
  final void Function(Role role) onDelete;

  const RoleDataTable({
    super.key,
    required this.roleList,
    required this.selectedIds,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.isLoading,
    required this.error,
    required this.onReload,
    required this.onPageSizeChanged,
    required this.onPageChanged,
    required this.onSelectionChanged,
    required this.onEdit,
    required this.onAssignMenu,
    required this.onAssignDataScope,
    required this.onDelete,
  });

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

    if (roleList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 表头工具栏
          Row(
            children: [
              Checkbox(
                value: selectedIds.length == roleList.length && roleList.isNotEmpty,
                tristate: true,
                onChanged: (value) {
                  if (value == true) {
                    onSelectionChanged(roleList.where((r) => r.id != null).map((r) => r.id!).toSet());
                  } else {
                    onSelectionChanged({});
                  }
                },
              ),
              Text(S.current.roleList),
              const Spacer(),
              Text('${S.current.total}: $totalCount'),
            ],
          ),
          const SizedBox(height: 8),
          // 表格
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
                  label: Text('ID'),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.roleName),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.roleCode),
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
                  size: ColumnSize.L,
                  numeric: true,
                ),
              ],
              rows: roleList.map((role) {
                final isSelected = role.id != null && selectedIds.contains(role.id);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    if (role.id != null) {
                      final newSelectedIds = Set<int>.from(selectedIds);
                      if (selected == true) {
                        newSelectedIds.add(role.id!);
                      } else {
                        newSelectedIds.remove(role.id!);
                      }
                      onSelectionChanged(newSelectedIds);
                    }
                  },
                  cells: [
                    DataCell(Text(role.id?.toString() ?? '-')),
                    DataCell(Text(role.name)),
                    DataCell(Text(role.code)),
                    DataCell(Text(role.sort?.toString() ?? '-')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: role.status == 0
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          role.status == 0 ? S.current.enabled : S.current.disabled,
                          style: TextStyle(
                            color: role.status == 0 ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(role.createTime?.toString().substring(0, 19) ?? '-')),
                    DataCell(_buildActionButtons(context, role)),
                  ],
                );
              }).toList(),
            ),
          ),
          // 分页控件
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text('${S.current.pageSize}: '),
                  DropdownButton<int>(
                    value: pageSize,
                    items: [10, 20, 50, 100].map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text('$value'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onPageSizeChanged(value);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: currentPage > 1
                        ? () => onPageChanged(currentPage - 1)
                        : null,
                  ),
                  Text('$currentPage / ${(totalCount / pageSize).ceil()}'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: currentPage * pageSize < totalCount
                        ? () => onPageChanged(currentPage + 1)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Role role) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => onEdit(role),
          child: Text(S.current.edit),
        ),
        PopupMenuButton<String>(
          tooltip: S.current.more,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'menu',
              child: Row(
                children: [
                  const Icon(Icons.menu, size: 18),
                  const SizedBox(width: 8),
                  Text(S.current.menuPermission),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'data',
              child: Row(
                children: [
                  const Icon(Icons.data_usage, size: 18),
                  const SizedBox(width: 8),
                  Text(S.current.dataPermission),
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
              case 'menu':
                onAssignMenu(role);
                break;
              case 'data':
                onAssignDataScope(role);
                break;
              case 'delete':
                onDelete(role);
                break;
            }
          },
        ),
      ],
    );
  }
}