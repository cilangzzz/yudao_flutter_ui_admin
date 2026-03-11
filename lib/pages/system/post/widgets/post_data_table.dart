import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/models/system/post.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 岗位数据表格组件
class PostDataTable extends StatelessWidget {
  final List<Post> postList;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool isLoading;
  final String? error;
  final VoidCallback onReload;
  final void Function(int pageSize) onPageSizeChanged;
  final void Function(int page) onPageChanged;
  final void Function(Post post) onEdit;
  final void Function(Post post) onDelete;

  const PostDataTable({
    super.key,
    required this.postList,
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

    if (postList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 表头工具栏
          Row(
            children: [
              Text(S.current.postList),
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
              minWidth: 800,
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
                  label: Text(S.current.postId),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.postName),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.postCode),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.postSort),
                  size: ColumnSize.S,
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
                  size: ColumnSize.L,
                  numeric: true,
                ),
              ],
              rows: postList.map((post) {
                return DataRow2(
                  cells: [
                    DataCell(Text(post.id?.toString() ?? '-')),
                    DataCell(Text(post.name)),
                    DataCell(Text(post.code)),
                    DataCell(Text(post.sort.toString())),
                    DataCell(_buildStatusCell(post)),
                    DataCell(Text(post.remark ?? '-')),
                    DataCell(Text(post.createTime ?? '-')),
                    DataCell(_buildActionButtons(context, post)),
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

  Widget _buildStatusCell(Post post) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: post.status == 0
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        post.status == 0 ? S.current.enabled : S.current.disabled,
        style: TextStyle(
          color: post.status == 0 ? Colors.green : Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Post post) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => onEdit(post),
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
                onDelete(post);
                break;
            }
          },
        ),
      ],
    );
  }
}