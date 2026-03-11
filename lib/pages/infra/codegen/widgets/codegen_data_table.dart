import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/models/infra/codegen.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 代码生成数据表格组件
class CodegenDataTable extends StatelessWidget {
  final List<CodegenTable> tableList;
  final List<DataSourceConfig> dataSourceList;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool isLoading;
  final String? error;
  final List<int> selectedIds;
  final VoidCallback onReload;
  final void Function(int pageSize) onPageSizeChanged;
  final void Function(int page) onPageChanged;
  final void Function(List<int> ids) onSelectionChanged;
  final void Function(CodegenTable table) onPreview;
  final void Function(CodegenTable table) onEdit;
  final void Function(CodegenTable table) onSync;
  final void Function(CodegenTable table) onGenerate;
  final void Function(CodegenTable table) onDelete;

  const CodegenDataTable({
    super.key,
    required this.tableList,
    required this.dataSourceList,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.isLoading,
    required this.error,
    required this.selectedIds,
    required this.onReload,
    required this.onPageSizeChanged,
    required this.onPageChanged,
    required this.onSelectionChanged,
    required this.onPreview,
    required this.onEdit,
    required this.onSync,
    required this.onGenerate,
    required this.onDelete,
  });

  String _getDataSourceName(int? dataSourceConfigId) {
    if (dataSourceConfigId == null) return '-';
    final config = dataSourceList.firstWhere(
      (e) => e.id == dataSourceConfigId,
      orElse: () => DataSourceConfig(),
    );
    return config.name ?? '-';
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
            ElevatedButton(
              onPressed: onReload,
              child: Text(S.current.retry),
            ),
          ],
        ),
      );
    }

    if (tableList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 表头工具栏
          Row(
            children: [
              Text(S.current.codegenList),
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
                    value: selectedIds.length == tableList.length && tableList.isNotEmpty,
                    tristate: true,
                    onChanged: (value) {
                      if (value == true) {
                        onSelectionChanged(tableList.map((e) => e.id!).toList());
                      } else {
                        onSelectionChanged([]);
                      }
                    },
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.dataSource),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.tableName),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.tableComment),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.className),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.createTime),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.updateTime),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.operation),
                  size: ColumnSize.L,
                  numeric: true,
                ),
              ],
              rows: tableList.map((table) {
                final isSelected = selectedIds.contains(table.id);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (value) {
                    if (value == true) {
                      onSelectionChanged([...selectedIds, table.id!]);
                    } else {
                      onSelectionChanged(selectedIds.where((e) => e != table.id).toList());
                    }
                  },
                  cells: [
                    DataCell(Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        if (value == true) {
                          onSelectionChanged([...selectedIds, table.id!]);
                        } else {
                          onSelectionChanged(selectedIds.where((e) => e != table.id).toList());
                        }
                      },
                    )),
                    DataCell(Text(_getDataSourceName(table.dataSourceConfigId))),
                    DataCell(Text(table.tableName ?? '-')),
                    DataCell(Text(table.tableComment ?? '-')),
                    DataCell(Text(table.className ?? '-')),
                    DataCell(Text(table.createTime ?? '-')),
                    DataCell(Text(table.updateTime ?? '-')),
                    DataCell(_buildActionButtons(context, table)),
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

  Widget _buildActionButtons(BuildContext context, CodegenTable table) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => onPreview(table),
          child: Text(S.current.preview),
        ),
        TextButton(
          onPressed: () => onGenerate(table),
          child: Text(S.current.generateCode),
        ),
        PopupMenuButton<String>(
          tooltip: S.current.more,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 18),
                  const SizedBox(width: 8),
                  Text(S.current.edit),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'sync',
              child: Row(
                children: [
                  const Icon(Icons.sync, size: 18),
                  const SizedBox(width: 8),
                  Text(S.current.sync),
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
              case 'edit':
                onEdit(table);
                break;
              case 'sync':
                onSync(table);
                break;
              case 'delete':
                onDelete(table);
                break;
            }
          },
        ),
      ],
    );
  }
}