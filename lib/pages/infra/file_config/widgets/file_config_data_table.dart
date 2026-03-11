import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/models/infra/file_config.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 文件配置数据表格组件
class FileConfigDataTable extends StatelessWidget {
  final List<FileConfig> configList;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool isLoading;
  final String? error;
  final Set<int> selectedIds;
  final void Function(Set<int>) onSelectionChanged;
  final VoidCallback onReload;
  final void Function(int pageSize) onPageSizeChanged;
  final void Function(int page) onPageChanged;
  final void Function(FileConfig config) onEdit;
  final void Function(FileConfig config) onDelete;
  final void Function(FileConfig config) onSetMaster;
  final void Function(FileConfig config) onTest;

  const FileConfigDataTable({
    super.key,
    required this.configList,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.isLoading,
    required this.error,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onReload,
    required this.onPageSizeChanged,
    required this.onPageChanged,
    required this.onEdit,
    required this.onDelete,
    required this.onSetMaster,
    required this.onTest,
  });

  void _toggleSelection(int id) {
    final newSet = Set<int>.from(selectedIds);
    if (newSet.contains(id)) {
      newSet.remove(id);
    } else {
      newSet.add(id);
    }
    onSelectionChanged(newSet);
  }

  void _toggleSelectAll() {
    if (selectedIds.length == configList.length) {
      onSelectionChanged({});
    } else {
      onSelectionChanged(configList.where((c) => c.id != null).map((c) => c.id!).toSet());
    }
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

    if (configList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 表头工具栏
          Row(
            children: [
              Text(S.current.fileConfigList),
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
              columns: [
                DataColumn2(
                  label: Row(
                    children: [
                      Checkbox(
                        value: selectedIds.length == configList.length && configList.isNotEmpty,
                        tristate: true,
                        onChanged: (_) => _toggleSelectAll(),
                      ),
                    ],
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.configId),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.configName),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.storage),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.remark),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.masterConfig),
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
              rows: configList.map((config) {
                final isSelected = config.id != null && selectedIds.contains(config.id);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: config.id != null ? (_) => _toggleSelection(config.id!) : null,
                  cells: [
                    DataCell(
                      Checkbox(
                        value: isSelected,
                        onChanged: config.id != null ? (_) => _toggleSelection(config.id!) : null,
                      ),
                    ),
                    DataCell(Text(config.id?.toString() ?? '-')),
                    DataCell(Text(config.name)),
                    DataCell(_buildStorageCell(config)),
                    DataCell(Text(config.remark ?? '-')),
                    DataCell(_buildMasterCell(config)),
                    DataCell(Text(config.createTime ?? '-')),
                    DataCell(_buildActionButtons(context, config)),
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

  Widget _buildStorageCell(FileConfig config) {
    final label = StorageType.getLabel(config.storage);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMasterCell(FileConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.master
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        config.master ? S.current.yes : S.current.no,
        style: TextStyle(
          color: config.master ? Colors.green : Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, FileConfig config) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => onEdit(config),
          child: Text(S.current.edit),
        ),
        TextButton(
          onPressed: () => onTest(config),
          child: Text(S.current.test),
        ),
        PopupMenuButton<String>(
          tooltip: S.current.more,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'master',
              enabled: !config.master,
              child: Row(
                children: [
                  const Icon(Icons.star, size: 18),
                  const SizedBox(width: 8),
                  Text(S.current.setMasterConfig),
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
              case 'master':
                if (!config.master) onSetMaster(config);
                break;
              case 'delete':
                if (config.id != null) onDelete(config);
                break;
            }
          },
        ),
      ],
    );
  }
}