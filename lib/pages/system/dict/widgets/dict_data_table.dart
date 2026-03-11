import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/models/system/dict_data.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 字典数据表格组件
class DictDataTable extends StatelessWidget {
  final List<DictData> dictDataList;
  final Set<int> selectedIds;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool isLoading;
  final String? error;
  final String? selectedDictType;
  final VoidCallback onReload;
  final void Function(int pageSize) onPageSizeChanged;
  final void Function(int page) onPageChanged;
  final void Function(Set<int> selectedIds) onSelectionChanged;
  final void Function(DictData dictData) onEdit;
  final void Function(DictData dictData) onDelete;

  const DictDataTable({
    super.key,
    required this.dictDataList,
    required this.selectedIds,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.isLoading,
    required this.error,
    required this.selectedDictType,
    required this.onReload,
    required this.onPageSizeChanged,
    required this.onPageChanged,
    required this.onSelectionChanged,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _buildStatusChip(int? status) {
    final isEnabled = status == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isEnabled ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isEnabled ? S.current.enabled : S.current.disabled,
        style: TextStyle(
          color: isEnabled ? Colors.green : Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildColorChip(String? colorType) {
    if (colorType == null || colorType.isEmpty) {
      return const Text('-');
    }

    Color color;
    switch (colorType) {
      case 'processing':
        color = Colors.blue;
        break;
      case 'success':
        color = Colors.green;
        break;
      case 'warning':
        color = Colors.orange;
        break;
      case 'danger':
        color = Colors.red;
        break;
      case 'info':
        color = Colors.cyan;
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
      child: Text(
        colorType,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (selectedDictType == null) {
      return Center(
        child: Text(S.current.pleaseSelectDictTypeLeft),
      );
    }

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

    if (dictDataList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 700,
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
                  label: Text(S.current.dataLabel),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.dataValue),
                  size: ColumnSize.S,
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
                  label: Text(S.current.colorType),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.remark),
                  size: ColumnSize.L,
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
              rows: dictDataList.map((dictData) {
                final isSelected = dictData.id != null && selectedIds.contains(dictData.id);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    if (dictData.id != null) {
                      final newSelectedIds = Set<int>.from(selectedIds);
                      if (selected == true) {
                        newSelectedIds.add(dictData.id!);
                      } else {
                        newSelectedIds.remove(dictData.id!);
                      }
                      onSelectionChanged(newSelectedIds);
                    }
                  },
                  cells: [
                    DataCell(Text(dictData.id?.toString() ?? '-')),
                    DataCell(Text(dictData.label)),
                    DataCell(Text(dictData.value)),
                    DataCell(Text(dictData.sort?.toString() ?? '0')),
                    DataCell(_buildStatusChip(dictData.status)),
                    DataCell(_buildColorChip(dictData.colorType)),
                    DataCell(Text(dictData.remark ?? '-')),
                    DataCell(Text(
                      dictData.createTime?.toString().substring(0, 19) ?? '-',
                    )),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => onEdit(dictData),
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
                                  onDelete(dictData);
                                  break;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          // 分页控件
          const SizedBox(height: 8),
          _buildPagination(context),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context) {
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
}