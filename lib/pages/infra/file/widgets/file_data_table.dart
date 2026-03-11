import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/models/infra/file.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 文件数据表格组件
class FileDataTable extends StatelessWidget {
  final List<File> fileList;
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
  final void Function(File file) onDelete;

  const FileDataTable({
    super.key,
    required this.fileList,
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
    required this.onDelete,
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
    if (selectedIds.length == fileList.length) {
      onSelectionChanged({});
    } else {
      onSelectionChanged(fileList.where((f) => f.id != null).map((f) => f.id!).toSet());
    }
  }

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
            mainAxisSize: MainAxisSize.min,
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

    if (fileList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Padding(
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      child: Column(
        children: [
          // 表头工具栏
          Row(
            children: [
              Text(S.current.fileList),
              const Spacer(),
              Text('${S.current.total}: $totalCount'),
            ],
          ),
          const SizedBox(height: 8),
          // 表格
          Expanded(
            child: DataTable2(
              columnSpacing: isMobile ? 8 : 12,
              horizontalMargin: isMobile ? 8 : 12,
              minWidth: isMobile ? 600 : 1000,
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
                        value: selectedIds.length == fileList.length && fileList.isNotEmpty,
                        tristate: true,
                        onChanged: (_) => _toggleSelectAll(),
                      ),
                    ],
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.fileName),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.filePath),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text('URL'),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.fileSize),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.fileType),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.fileContent),
                  size: ColumnSize.M,
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
              rows: fileList.map((file) {
                final isSelected = file.id != null && selectedIds.contains(file.id);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: file.id != null ? (_) => _toggleSelection(file.id!) : null,
                  cells: [
                    DataCell(
                      Checkbox(
                        value: isSelected,
                        onChanged: file.id != null ? (_) => _toggleSelection(file.id!) : null,
                      ),
                    ),
                    DataCell(Text(file.name ?? '-')),
                    DataCell(
                      Tooltip(
                        message: file.path,
                        child: Text(
                          file.path.length > 30 ? '${file.path.substring(0, 30)}...' : file.path,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      Tooltip(
                        message: file.url ?? '',
                        child: Text(
                          (file.url ?? '-').length > 30
                              ? '${file.url!.substring(0, 30)}...'
                              : file.url ?? '-',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text(file.formattedSize)),
                    DataCell(Text(file.type ?? '-')),
                    DataCell(_buildFileContentCell(context, file)),
                    DataCell(Text(file.createTime ?? '-')),
                    DataCell(_buildActionButtons(context, file, isMobile)),
                  ],
                );
              }).toList(),
            ),
          ),
          // 分页控件
          const SizedBox(height: 8),
          _buildPagination(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
        ],
      );
    }

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

  Widget _buildFileContentCell(BuildContext context, File file) {
    if (file.isImage && file.url != null) {
      return InkWell(
        onTap: () => _showImagePreview(context, file.url!),
        child: const Icon(Icons.image, color: Colors.blue),
      );
    }
    if (file.isPdf && file.url != null) {
      return TextButton(
        onPressed: () => _openUrl(file.url!),
        child: Text(S.current.preview),
      );
    }
    if (file.url != null) {
      return TextButton(
        onPressed: () => _openUrl(file.url!),
        child: Text(S.current.download),
      );
    }
    return const Text('-');
  }

  void _showImagePreview(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(S.current.preview),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Flexible(
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openUrl(String url) {
    // 使用 url_launcher 打开 URL
  }

  Widget _buildActionButtons(BuildContext context, File file, bool isMobile) {
    if (isMobile) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (file.url != null)
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () => _copyUrl(context, file.url!),
              tooltip: S.current.copyUrl,
            ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
            onPressed: file.id != null ? () => onDelete(file) : null,
            tooltip: S.current.delete,
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: file.url != null ? () => _copyUrl(context, file.url!) : null,
          child: Text(S.current.copyUrl),
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
                if (file.id != null) onDelete(file);
                break;
            }
          },
        ),
      ],
    );
  }

  void _copyUrl(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.current.copySuccess)),
    );
  }
}