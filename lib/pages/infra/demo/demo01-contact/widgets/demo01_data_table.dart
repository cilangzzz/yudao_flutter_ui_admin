import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo01_contact.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 示例联系人数据表格组件
class Demo01DataTable extends StatelessWidget {
  final List<Demo01Contact> contactList;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool isLoading;
  final String? error;
  final VoidCallback onReload;
  final void Function(int pageSize) onPageSizeChanged;
  final void Function(int page) onPageChanged;
  final void Function(Demo01Contact contact) onEdit;
  final void Function(Demo01Contact contact) onDelete;
  final Set<int> selectedIds;
  final void Function(Set<int> ids) onSelectionChanged;

  const Demo01DataTable({
    super.key,
    required this.contactList,
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

    if (contactList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 表头工具栏
          Row(
            children: [
              Text('${S.current.demo01Contact}${S.current.list}'),
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
                    value: selectedIds.length == contactList.length && contactList.isNotEmpty,
                    onChanged: (value) {
                      if (value == true) {
                        onSelectionChanged(contactList.map((e) => e.id!).toSet());
                      } else {
                        onSelectionChanged({});
                      }
                    },
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.id),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.name),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.sex),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.birthday),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.description),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.avatar),
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
              rows: contactList.map((contact) {
                final isSelected = selectedIds.contains(contact.id);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (value) {
                    final newSet = Set<int>.from(selectedIds);
                    if (value == true) {
                      newSet.add(contact.id!);
                    } else {
                      newSet.remove(contact.id!);
                    }
                    onSelectionChanged(newSet);
                  },
                  cells: [
                    DataCell(Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        final newSet = Set<int>.from(selectedIds);
                        if (value == true) {
                          newSet.add(contact.id!);
                        } else {
                          newSet.remove(contact.id!);
                        }
                        onSelectionChanged(newSet);
                      },
                    )),
                    DataCell(Text(contact.id?.toString() ?? '-')),
                    DataCell(Text(contact.name)),
                    DataCell(_buildSexCell(contact)),
                    DataCell(Text(_formatBirthday(contact.birthday))),
                    DataCell(Text(contact.description ?? '-')),
                    DataCell(_buildAvatarCell(contact)),
                    DataCell(Text(contact.createTime ?? '-')),
                    DataCell(_buildActionButtons(context, contact)),
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

  Widget _buildSexCell(Demo01Contact contact) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: contact.sex == 1
            ? Colors.blue.withValues(alpha: 0.1)
            : Colors.pink.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        contact.sex == 1 ? S.current.male : S.current.female,
        style: TextStyle(
          color: contact.sex == 1 ? Colors.blue : Colors.pink,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatBirthday(int? birthday) {
    if (birthday == null) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(birthday);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildAvatarCell(Demo01Contact contact) {
    if (contact.avatar == null || contact.avatar!.isEmpty) {
      return const Icon(Icons.person, size: 32, color: Colors.grey);
    }
    return CircleAvatar(
      radius: 16,
      backgroundImage: NetworkImage(contact.avatar!),
      onBackgroundImageError: (_, __) {},
      child: contact.avatar!.isEmpty ? const Icon(Icons.person, size: 20) : null,
    );
  }

  Widget _buildActionButtons(BuildContext context, Demo01Contact contact) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => onEdit(contact),
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
                onDelete(contact);
                break;
            }
          },
        ),
      ],
    );
  }
}