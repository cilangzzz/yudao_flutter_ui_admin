import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/models/infra/job_log.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 任务日志数据表格组件
class JobLogDataTable extends StatelessWidget {
  final List<JobLog> logList;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool isLoading;
  final String? error;
  final VoidCallback onReload;
  final void Function(int pageSize) onPageSizeChanged;
  final void Function(int page) onPageChanged;
  final void Function(JobLog log) onDetail;

  const JobLogDataTable({
    super.key,
    required this.logList,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.isLoading,
    required this.error,
    required this.onReload,
    required this.onPageSizeChanged,
    required this.onPageChanged,
    required this.onDetail,
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

    if (logList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 表头工具栏
          Row(
            children: [
              Text(S.current.jobLogList),
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
                  label: Text(S.current.logId),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.jobId),
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
                  label: Text(S.current.executeIndex),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.executeTime),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.duration),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.status),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.operation),
                  size: ColumnSize.S,
                  numeric: true,
                ),
              ],
              rows: logList.map((log) {
                return DataRow2(
                  cells: [
                    DataCell(Text(log.id?.toString() ?? '-')),
                    DataCell(Text(log.jobId.toString())),
                    DataCell(Text(log.handlerName)),
                    DataCell(Text(log.handlerParam.isEmpty ? '-' : log.handlerParam)),
                    DataCell(Text(log.executeIndex)),
                    DataCell(Text(_formatExecuteTime(log))),
                    DataCell(Text('${log.duration} ${S.current.milliseconds}')),
                    DataCell(_buildStatusCell(log)),
                    DataCell(_buildActionButtons(context, log)),
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

  String _formatExecuteTime(JobLog log) {
    if (log.beginTime != null && log.endTime != null) {
      return '${log.beginTime} ~ ${log.endTime}';
    }
    return log.beginTime ?? '-';
  }

  Widget _buildStatusCell(JobLog log) {
    final isSuccess = log.status == JobLogStatus.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSuccess
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isSuccess ? S.current.jobLogStatusSuccess : S.current.jobLogStatusFailure,
        style: TextStyle(
          color: isSuccess ? Colors.green : Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, JobLog log) {
    return TextButton(
      onPressed: () => onDetail(log),
      child: Text(S.current.detail),
    );
  }
}