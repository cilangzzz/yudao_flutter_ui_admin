import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/models/system/dict_type.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 字典类型数据表格组件
class DictTypeTable extends StatelessWidget {
  final List<DictType> dictTypeList;
  final Set<int> selectedIds;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool isLoading;
  final String? error;
  final VoidCallback onReload;
  final void Function(int pageSize) onPageSizeChanged;
  final void Function(int page) onPageChanged;
  final void Function(Set<int> selectedIds) onSelectionChanged;
  final void Function(DictType dictType) onEdit;
  final void Function(DictType dictType) onDelete;
  final void Function(DictType dictType)? onSelect;

  const DictTypeTable({
    super.key,
    required this.dictTypeList,
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
    required this.onDelete,
    this.onSelect,
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

    if (dictTypeList.isEmpty) {
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
              minWidth: 600,
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
                  label: Text(S.current.dictName),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.dictType),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.status),
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
              rows: dictTypeList.map((dictType) {
                final isSelected = dictType.id != null && selectedIds.contains(dictType.id);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    if (dictType.id != null) {
                      final newSelectedIds = Set<int>.from(selectedIds);
                      if (selected == true) {
                        newSelectedIds.add(dictType.id!);
                      } else {
                        newSelectedIds.remove(dictType.id!);
                      }
                      onSelectionChanged(newSelectedIds);
                    }
                  },
                  onTap: onSelect != null ? () => onSelect!(dictType) : null,
                  cells: [
                    DataCell(Text(dictType.id?.toString() ?? '-')),
                    DataCell(
                      InkWell(
                        onTap: onSelect != null ? () => onSelect!(dictType) : null,
                        child: Text(
                          dictType.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(dictType.type)),
                    DataCell(_buildStatusChip(dictType.status)),
                    DataCell(Text(dictType.remark ?? '-')),
                    DataCell(Text(
                      dictType.createTime?.toString().substring(0, 19) ?? '-',
                    )),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => onEdit(dictType),
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
                                  onDelete(dictType);
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