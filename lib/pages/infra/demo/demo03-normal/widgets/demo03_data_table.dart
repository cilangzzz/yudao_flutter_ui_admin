import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo03_student.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 学生数据表格组件
class Demo03DataTable extends StatelessWidget {
  final List<Demo03Student> studentList;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool isLoading;
  final String? error;
  final VoidCallback onReload;
  final void Function(int pageSize) onPageSizeChanged;
  final void Function(int page) onPageChanged;
  final void Function(Demo03Student student) onEdit;
  final void Function(Demo03Student student) onDelete;
  final Set<int> selectedIds;
  final void Function(Set<int> ids) onSelectionChanged;
  final void Function(Demo03Student student)? onRowTap;
  final int? selectedStudentId;
  final bool isMobile;
  final double availableWidth;

  const Demo03DataTable({
    super.key,
    required this.studentList,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.isLoading,
    required this.error,
    required this.onReload,
    required this.onPageSizeChanged,
    required this.onPageChanged,
    required this.onEdit,
    required this.onDelete,
    required this.selectedIds,
    required this.onSelectionChanged,
    this.onRowTap,
    this.selectedStudentId,
    this.isMobile = false,
    this.availableWidth = double.infinity,
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
            ElevatedButton(
              onPressed: onReload,
              child: Text(S.current.retry),
            ),
          ],
        ),
      );
    }

    if (studentList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    // 响应式适配：根据可用宽度调整最小宽度
    final minWidth = isMobile ? availableWidth : 900.0;
    final columnSpacing = isMobile ? 8.0 : 12.0;
    final horizontalMargin = isMobile ? 8.0 : 12.0;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      child: Column(
        children: [
          // 表头工具栏
          Row(
            children: [
              Text('${S.current.student}${S.current.list}'),
              const Spacer(),
              Text('${S.current.total}: $totalCount'),
            ],
          ),
          const SizedBox(height: 8),
          // 表格 - 使用 Flexible 防止溢出
          Flexible(
            child: DataTable2(
              columnSpacing: columnSpacing,
              horizontalMargin: horizontalMargin,
              minWidth: minWidth,
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
                  label: Checkbox(
                    value: selectedIds.length == studentList.length && studentList.isNotEmpty,
                    onChanged: (value) {
                      if (value == true) {
                        onSelectionChanged(studentList.map((e) => e.id!).toSet());
                      } else {
                        onSelectionChanged({});
                      }
                    },
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.id),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.name),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.sex),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.birthday),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.description),
                  size: ColumnSize.L,
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
              rows: studentList.map((student) {
                final isSelected = selectedIds.contains(student.id);
                final isRowSelected = selectedStudentId == student.id;
                return DataRow2(
                  selected: isSelected,
                  onTap: onRowTap != null ? () => onRowTap!(student) : null,
                  color: WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                      if (isRowSelected) {
                        return Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3);
                      }
                      return null;
                    },
                  ),
                  onSelectChanged: (value) {
                    final newSet = Set<int>.from(selectedIds);
                    if (value == true) {
                      newSet.add(student.id!);
                    } else {
                      newSet.remove(student.id!);
                    }
                    onSelectionChanged(newSet);
                  },
                  cells: [
                    DataCell(Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        final newSet = Set<int>.from(selectedIds);
                        if (value == true) {
                          newSet.add(student.id!);
                        } else {
                          newSet.remove(student.id!);
                        }
                        onSelectionChanged(newSet);
                      },
                    )),
                    DataCell(Text(student.id?.toString() ?? '-')),
                    DataCell(Text(student.name)),
                    DataCell(_buildSexCell(student)),
                    DataCell(Text(_formatBirthday(student.birthday))),
                    DataCell(Text(student.description ?? '-', overflow: TextOverflow.ellipsis)),
                    DataCell(Text(student.createTime ?? '-')),
                    DataCell(_buildActionButtons(context, student)),
                  ],
                );
              }).toList(),
            ),
          ),
          // 分页控件 - 使用 SingleChildScrollView 防止溢出
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
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
          ),
        ],
      ),
    );
  }

  Widget _buildSexCell(Demo03Student student) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: student.sex == 1
            ? Colors.blue.withValues(alpha: 0.1)
            : Colors.pink.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        student.sex == 1 ? S.current.male : S.current.female,
        style: TextStyle(
          color: student.sex == 1 ? Colors.blue : Colors.pink,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatBirthday(int? birthday) {
    if (birthday == null) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(birthday);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildActionButtons(BuildContext context, Demo03Student student) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => onEdit(student),
          child: Text(S.current.edit),
        ),
        PopupMenuButton<String>(
          tooltip: S.current.more,
          itemBuilder: (context) => [
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
              case 'delete':
                onDelete(student);
                break;
            }
          },
        ),
      ],
    );
  }
}