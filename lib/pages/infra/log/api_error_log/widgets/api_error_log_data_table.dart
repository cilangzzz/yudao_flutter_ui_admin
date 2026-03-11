import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/models/infra/api_error_log.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// API 错误日志数据表格组件
class ApiErrorLogDataTable extends StatelessWidget {
  final List<ApiErrorLog> logList;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool isLoading;
  final String? error;
  final VoidCallback onReload;
  final void Function(int pageSize) onPageSizeChanged;
  final void Function(int page) onPageChanged;
  final void Function(ApiErrorLog log) onDetail;
  final void Function(ApiErrorLog log, int processStatus) onProcess;

  const ApiErrorLogDataTable({
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
    required this.onProcess,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
        ),
      );
    }

    if (logList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    if (isMobile) {
      return _buildMobileListView(context);
    }

    return _buildDesktopTableView(context);
  }

  Widget _buildMobileListView(BuildContext context) {
    return Column(
      children: [
        // 列表头
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(S.current.apiErrorLogList),
              const Spacer(),
              Text('${S.current.total}: $totalCount'),
            ],
          ),
        ),
        // 列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: logList.length,
            itemBuilder: (context, index) {
              final log = logList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    log.exceptionName?.split('.').last ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildMethodChip(log.requestMethod),
                          const SizedBox(width: 8),
                          _buildProcessStatusChip(log.processStatus),
                        ],
                      ),
                      Text(
                        log.exceptionTime ?? '-',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                  children: [
                    _buildMobileDetailRow(S.current.logId, log.id?.toString()),
                    _buildMobileDetailRow(S.current.userId, log.userId?.toString()),
                    _buildMobileDetailRow(S.current.applicationName, log.applicationName),
                    _buildMobileDetailRow(S.current.requestUrl, log.requestUrl),
                    _buildMobileDetailRow(S.current.exceptionName, log.exceptionName),
                    _buildMobileDetailRow(S.current.exceptionMessage, log.exceptionMessage, maxLines: 2),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => onDetail(log),
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: Text(S.current.detail),
                        ),
                        if (log.processStatus == 0) ...[
                          TextButton(
                            onPressed: () => onProcess(log, 1),
                            style: TextButton.styleFrom(foregroundColor: Colors.green),
                            child: Text(S.current.processStatusDone),
                          ),
                          TextButton(
                            onPressed: () => onProcess(log, 2),
                            style: TextButton.styleFrom(foregroundColor: Colors.grey),
                            child: Text(S.current.processStatusIgnore),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // 分页控件
        _buildMobilePagination(context),
      ],
    );
  }

  Widget _buildMobileDetailRow(String label, String? value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(fontSize: 13),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodChip(String? method) {
    Color color;
    switch (method?.toUpperCase()) {
      case 'GET':
        color = Colors.green;
        break;
      case 'POST':
        color = Colors.blue;
        break;
      case 'PUT':
        color = Colors.orange;
        break;
      case 'DELETE':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        method ?? '-',
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildProcessStatusChip(int? processStatus) {
    String text;
    Color color;
    switch (processStatus) {
      case 0:
        text = S.current.processStatusInit;
        color = Colors.orange;
        break;
      case 1:
        text = S.current.processStatusDone;
        color = Colors.green;
        break;
      case 2:
        text = S.current.processStatusIgnore;
        color = Colors.grey;
        break;
      default:
        text = '-';
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildMobilePagination(BuildContext context) {
    final totalPages = (totalCount / pageSize).ceil();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1
                ? () => onPageChanged(currentPage - 1)
                : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('$currentPage / $totalPages'),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage * pageSize < totalCount
                ? () => onPageChanged(currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTableView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 表头工具栏
          Row(
            children: [
              Text(S.current.apiErrorLogList),
              const Spacer(),
              Text('${S.current.total}: $totalCount'),
            ],
          ),
          const SizedBox(height: 8),
          // 表格
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return DataTable2(
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
                      label: Text(S.current.userId),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: Text(S.current.userType),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: Text(S.current.applicationName),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: Text(S.current.requestMethod),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: Text(S.current.requestUrl),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: Text(S.current.exceptionTime),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: Text(S.current.exceptionName),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: Text(S.current.processStatus),
                      size: ColumnSize.S,
                    ),
                    DataColumn2(
                      label: Text(S.current.operation),
                      size: ColumnSize.L,
                      numeric: true,
                    ),
                  ],
                  rows: logList.map((log) {
                    return DataRow2(
                      cells: [
                        DataCell(Text(log.id?.toString() ?? '-')),
                        DataCell(Text(log.userId?.toString() ?? '-')),
                        DataCell(_buildUserTypeCell(log)),
                        DataCell(Text(log.applicationName ?? '-')),
                        DataCell(_buildMethodCell(log)),
                        DataCell(Tooltip(
                          message: log.requestUrl ?? '',
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth * 0.12,
                            ),
                            child: Text(
                              log.requestUrl ?? '-',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        )),
                        DataCell(Text(log.exceptionTime ?? '-')),
                        DataCell(Tooltip(
                          message: log.exceptionName ?? '',
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth * 0.1,
                            ),
                            child: Text(
                              log.exceptionName ?? '-',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        )),
                        DataCell(_buildProcessStatusCell(log)),
                        DataCell(_buildActionButtons(context, log)),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
          // 分页控件
          const SizedBox(height: 8),
          _buildDesktopPagination(context),
        ],
      ),
    );
  }

  Widget _buildDesktopPagination(BuildContext context) {
    return Row(
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
    );
  }

  Widget _buildUserTypeCell(ApiErrorLog log) {
    String text;
    Color color;
    switch (log.userType) {
      case 1:
        text = 'Admin';
        color = Colors.blue;
        break;
      case 2:
        text = 'Member';
        color = Colors.green;
        break;
      default:
        text = '-';
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Widget _buildMethodCell(ApiErrorLog log) {
    final method = log.requestMethod ?? '';
    Color color;
    switch (method.toUpperCase()) {
      case 'GET':
        color = Colors.green;
        break;
      case 'POST':
        color = Colors.blue;
        break;
      case 'PUT':
        color = Colors.orange;
        break;
      case 'DELETE':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(method, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Widget _buildProcessStatusCell(ApiErrorLog log) {
    String text;
    Color color;
    switch (log.processStatus) {
      case 0:
        text = S.current.processStatusInit;
        color = Colors.orange;
        break;
      case 1:
        text = S.current.processStatusDone;
        color = Colors.green;
        break;
      case 2:
        text = S.current.processStatusIgnore;
        color = Colors.grey;
        break;
      default:
        text = '-';
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Widget _buildActionButtons(BuildContext context, ApiErrorLog log) {
    final isInit = log.processStatus == 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => onDetail(log),
          child: Text(S.current.detail),
        ),
        if (isInit) ...[
          TextButton(
            onPressed: () => onProcess(log, 1),
            child: Text(S.current.processStatusDone, style: const TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () => onProcess(log, 2),
            child: Text(S.current.processStatusIgnore, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ],
    );
  }
}