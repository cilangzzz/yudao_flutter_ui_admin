import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo02_category.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 示例分类树形数据表格组件
class Demo02TreeTable extends StatelessWidget {
  final List<Demo02Category> categoryList;
  final bool isLoading;
  final String? error;
  final VoidCallback onReload;
  final void Function(Demo02Category category) onEdit;
  final void Function(Demo02Category category) onDelete;
  final void Function(Demo02Category category) onAddChild;
  final void Function(bool expanded) onExpandAll;
  final bool isExpanded;
  final bool isMobile;
  final double availableWidth;

  const Demo02TreeTable({
    super.key,
    required this.categoryList,
    required this.isLoading,
    required this.error,
    required this.onReload,
    required this.onEdit,
    required this.onDelete,
    required this.onAddChild,
    required this.onExpandAll,
    required this.isExpanded,
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

    if (categoryList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    // 响应式适配：根据可用宽度调整最小宽度
    final minWidth = isMobile ? availableWidth : 800.0;
    final columnSpacing = isMobile ? 8.0 : 12.0;
    final horizontalMargin = isMobile ? 8.0 : 12.0;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      child: Column(
        children: [
          // 表头工具栏
          Row(
            children: [
              Text('${S.current.demo02Category}${S.current.list}'),
            ],
          ),
          const SizedBox(height: 8),
          // 树形表格 - 使用 Flexible 防止溢出
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
                  label: Text(S.current.id),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.name),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.parentId),
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
              rows: _buildTreeRows(categoryList),
            ),
          ),
        ],
      ),
    );
  }

  List<DataRow2> _buildTreeRows(List<Demo02Category> categories, {int level = 0}) {
    final rows = <DataRow2>[];
    for (final category in categories) {
      rows.add(_buildRow(category, level));
      if (category.children != null && category.children!.isNotEmpty) {
        rows.addAll(_buildTreeRows(category.children!, level: level + 1));
      }
    }
    return rows;
  }

  DataRow2 _buildRow(Demo02Category category, int level) {
    return DataRow2(
      cells: [
        DataCell(Text(category.id?.toString() ?? '-')),
        DataCell(Row(
          children: [
            SizedBox(width: level * 24.0),
            if (category.children != null && category.children!.isNotEmpty)
              const Icon(Icons.folder, size: 18, color: Colors.amber)
            else
              const Icon(Icons.folder_open, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(child: Text(category.name)),
          ],
        )),
        DataCell(Text(category.parentId == 0 ? S.current.topLevel : category.parentId.toString())),
        DataCell(Text(category.createTime ?? '-')),
        DataCell(_buildActionButtons(category)),
      ],
    );
  }

  Widget _buildActionButtons(Demo02Category category) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton.icon(
          onPressed: () => onAddChild(category),
          icon: const Icon(Icons.add, size: 16),
          label: Text(S.current.addSub),
        ),
        TextButton(
          onPressed: () => onEdit(category),
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
                onDelete(category);
                break;
            }
          },
        ),
      ],
    );
  }
}