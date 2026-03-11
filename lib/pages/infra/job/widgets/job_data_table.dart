import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/models/infra/job.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 定时任务数据表格组件
class JobDataTable extends StatelessWidget {
  final List<Job> jobList;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool isLoading;
  final String? error;
  final VoidCallback onReload;
  final void Function(int pageSize) onPageSizeChanged;
  final void Function(int page) onPageChanged;
  final void Function(Job job) onEdit;
  final void Function(Job job) onDelete;
  final void Function(Job job) onUpdateStatus;
  final void Function(Job job) onTrigger;
  final void Function(Job job) onDetail;
  final void Function(Job job) onViewLog;
  final Set<int> selectedIds;
  final void Function(Set<int> ids) onSelectionChanged;

  const JobDataTable({
    super.key,
    required this.jobList,
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
    required this.onUpdateStatus,
    required this.onTrigger,
    required this.onDetail,
    required this.onViewLog,
    required this.selectedIds,
    required this.onSelectionChanged,
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

    if (jobList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 表头工具栏
          Row(
            children: [
              Text(S.current.jobList),
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
              minWidth: 1000,
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
                    value: selectedIds.length == jobList.length && jobList.isNotEmpty,
                    tristate: true,
                    onChanged: (value) {
                      if (value == true) {
                        onSelectionChanged(jobList.map((e) => e.id!).toSet());
                      } else {
                        onSelectionChanged({});
                      }
                    },
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.jobId),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.jobName),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.status),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.handlerName),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.handlerParam),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.cronExpression),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.operation),
                  size: ColumnSize.L,
                  numeric: true,
                ),
              ],
              rows: jobList.map((job) {
                final isSelected = selectedIds.contains(job.id);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    final newSet = Set<int>.from(selectedIds);
                    if (selected == true) {
                      newSet.add(job.id!);
                    } else {
                      newSet.remove(job.id!);
                    }
                    onSelectionChanged(newSet);
                  },
                  cells: [
                    DataCell(Checkbox(
                      value: isSelected,
                      onChanged: (selected) {
                        final newSet = Set<int>.from(selectedIds);
                        if (selected == true) {
                          newSet.add(job.id!);
                        } else {
                          newSet.remove(job.id!);
                        }
                        onSelectionChanged(newSet);
                      },
                    )),
                    DataCell(Text(job.id?.toString() ?? '-')),
                    DataCell(Text(job.name)),
                    DataCell(_buildStatusCell(job)),
                    DataCell(Text(job.handlerName)),
                    DataCell(Text(job.handlerParam.isEmpty ? '-' : job.handlerParam)),
                    DataCell(Text(job.cronExpression)),
                    DataCell(_buildActionButtons(context, job)),
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

  Widget _buildStatusCell(Job job) {
    final isNormal = job.status == JobStatus.normal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isNormal
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isNormal ? S.current.jobStatusNormal : S.current.jobStatusStop,
        style: TextStyle(
          color: isNormal ? Colors.green : Colors.orange,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Job job) {
    final isNormal = job.status == JobStatus.normal;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => onEdit(job),
          child: Text(S.current.edit),
        ),
        TextButton(
          onPressed: () => onUpdateStatus(job),
          child: Text(isNormal ? S.current.jobPause : S.current.jobStart),
        ),
        TextButton(
          onPressed: () => onTrigger(job),
          child: Text(S.current.jobExecute),
        ),
        PopupMenuButton<String>(
          tooltip: S.current.more,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'detail',
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18),
                  const SizedBox(width: 8),
                  Text(S.current.detail),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'log',
              child: Row(
                children: [
                  const Icon(Icons.history, size: 18),
                  const SizedBox(width: 8),
                  Text(S.current.jobLog),
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
              case 'detail':
                onDetail(job);
                break;
              case 'log':
                onViewLog(job);
                break;
              case 'delete':
                onDelete(job);
                break;
            }
          },
        ),
      ],
    );
  }
}