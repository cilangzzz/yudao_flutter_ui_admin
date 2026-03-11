import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/models/system/user.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'user_action_buttons.dart';

/// 用户数据表格组件
class UserDataTable extends StatelessWidget {
  final List<User> userList;
  final Set<int> selectedIds;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool isLoading;
  final String? error;
  final void Function(int userId, bool selected) onSelectChanged;
  final void Function(bool selectAll) onSelectAll;
  final void Function(User user) onEdit;
  final Future<void> Function(User user) onDelete;
  final void Function(User user) onResetPassword;
  final void Function(User user) onAssignRole;
  final void Function(User user) onUpdateStatus;
  final VoidCallback onRetry;
  final void Function(int pageSize) onPageSizeChanged;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  const UserDataTable({
    super.key,
    required this.userList,
    required this.selectedIds,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.isLoading,
    this.error,
    required this.onSelectChanged,
    required this.onSelectAll,
    required this.onEdit,
    required this.onDelete,
    required this.onResetPassword,
    required this.onAssignRole,
    required this.onUpdateStatus,
    required this.onRetry,
    required this.onPageSizeChanged,
    required this.onPreviousPage,
    required this.onNextPage,
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
            ElevatedButton(onPressed: onRetry, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (userList.isEmpty) {
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
                value: selectedIds.length == userList.length && userList.isNotEmpty,
                tristate: true,
                onChanged: (value) {
                  onSelectAll(value == true);
                },
              ),
              Text(S.current.userList),
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
              minWidth: 900,
              smRatio: 0.75,
              lmRatio: 1.5,
              headingRowColor: WidgetStateProperty.resolveWith(
                (states) => Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              headingTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              dataRowColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3);
                }
                return null;
              }),
              columns: [
                DataColumn2(
                  label: Text('ID'),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.username),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.nickname),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.department),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.mobile),
                  size: ColumnSize.M,
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
              rows: userList.map((user) {
                final isSelected = user.id != null && selectedIds.contains(user.id);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    if (user.id != null) {
                      onSelectChanged(user.id!, selected == true);
                    }
                  },
                  cells: [
                    DataCell(Text(user.id?.toString() ?? '-')),
                    DataCell(Text(user.username)),
                    DataCell(Text(user.nickname)),
                    DataCell(Text(user.deptName ?? '-')),
                    DataCell(Text(user.mobile ?? '-')),
                    DataCell(
                      _StatusSwitch(
                        isEnabled: user.status == 0,
                        onChanged: () => onUpdateStatus(user),
                      ),
                    ),
                    DataCell(Text(user.createTime?.toString().substring(0, 19) ?? '-')),
                    DataCell(
                      UserActionButtons(
                        user: user,
                        onEdit: onEdit,
                        onDelete: onDelete,
                        onResetPassword: onResetPassword,
                        onAssignRole: onAssignRole,
                      ),
                    ),
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
              // 每页行数选择
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
              // 分页导航
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: currentPage > 1 ? onPreviousPage : null,
                  ),
                  Text('$currentPage / ${(totalCount / pageSize).ceil()}'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: currentPage * pageSize < totalCount ? onNextPage : null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 状态开关组件
class _StatusSwitch extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onChanged;

  const _StatusSwitch({
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isEnabled,
      onChanged: (_) => onChanged(),
    );
  }
}