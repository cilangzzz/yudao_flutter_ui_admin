import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/system/notice_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/notice.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 公告管理页面
class NoticePage extends ConsumerStatefulWidget {
  const NoticePage({super.key});

  @override
  ConsumerState<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends ConsumerState<NoticePage> {
  final _searchController = TextEditingController();
  int? _selectedStatus;

  List<Notice> _noticeList = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNoticeList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNoticeList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final noticeApi = ref.read(noticeApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_searchController.text.isNotEmpty) 'title': _searchController.text,
        if (_selectedStatus != null) 'status': _selectedStatus,
      };

      final response = await noticeApi.getNoticePage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _noticeList = response.data!.list;
          _totalCount = response.data!.total;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.msg ?? S.current.strings.loadFailed;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _search() {
    _currentPage = 1;
    _loadNoticeList();
  }

  void _reset() {
    _searchController.clear();
    setState(() {
      _selectedStatus = null;
    });
    _currentPage = 1;
    _loadNoticeList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DeviceUIMode.builder(
        context,
        mobile: (context) => _buildMobileLayout(context),
        desktop: (context) => _buildDesktopLayout(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoticeDialog(context),
        icon: const Icon(Icons.add),
        label: Text(S.current.strings.addNotice),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        _buildDesktopSearchBar(context),
        const Divider(height: 1),
        Expanded(
          child: _buildDesktopDataTable(context),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildMobileSearchBar(context),
        const Divider(height: 1),
        Expanded(child: _buildMobileList(context)),
      ],
    );
  }

  Widget _buildDesktopSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: DeviceUIMode.select(context, mobile: () => 150.0, desktop: () => 200.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: S.current.strings.noticeName,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          SizedBox(
            width: DeviceUIMode.select(context, mobile: () => 120.0, desktop: () => 150.0),
            child: DropdownButtonFormField<int?>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: S.current.strings.status,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(S.current.strings.all)),
                DropdownMenuItem(value: 0, child: Text(S.current.strings.enabled)),
                DropdownMenuItem(value: 1, child: Text(S.current.strings.disabled)),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search),
            label: Text(S.current.strings.search),
          ),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            label: Text(S.current.strings.reset),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: S.current.strings.noticeName,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: DropdownButtonFormField<int?>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text(S.current.strings.all)),
                    DropdownMenuItem(value: 0, child: Text(S.current.strings.enabled)),
                    DropdownMenuItem(value: 1, child: Text(S.current.strings.disabled)),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _search,
                  icon: const Icon(Icons.search, size: 20),
                  label: Text(S.current.strings.search),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: Text(S.current.strings.reset),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopDataTable(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${S.current.strings.loadFailed}: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNoticeList,
              child: Text(S.current.strings.retry),
            ),
          ],
        ),
      );
    }

    if (_noticeList.isEmpty) {
      return Center(child: Text(S.current.strings.noData));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PaginatedDataTable(
        header: Text(S.current.strings.noticeList),
        rowsPerPage: _pageSize,
        availableRowsPerPage: const [10, 20, 50, 100],
        onPageChanged: (page) {
          setState(() {
            _currentPage = page ~/ _pageSize + 1;
          });
          _loadNoticeList();
        },
        onRowsPerPageChanged: (value) {
          if (value != null) {
            setState(() {
              _pageSize = value;
              _currentPage = 1;
            });
            _loadNoticeList();
          }
        },
        columns: [
          DataColumn(label: Text(S.current.strings.noticeId)),
          DataColumn(label: Text(S.current.strings.noticeName)),
          DataColumn(label: Text(S.current.strings.noticeType)),
          DataColumn(label: Text(S.current.strings.status)),
          DataColumn(label: Text(S.current.strings.noticeCreator)),
          DataColumn(label: Text(S.current.strings.createTime)),
          DataColumn(label: Text(S.current.strings.operation)),
        ],
        source: _NoticeDataSource(
          _noticeList,
          context,
          _editNotice,
          _deleteNotice,
          _pushNotice,
        ),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${S.current.strings.loadFailed}: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNoticeList,
              child: Text(S.current.strings.retry),
            ),
          ],
        ),
      );
    }

    if (_noticeList.isEmpty) {
      return Center(child: Text(S.current.strings.noData));
    }

    return RefreshIndicator(
      onRefresh: _loadNoticeList,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _noticeList.length,
        itemBuilder: (context, index) {
          final notice = _noticeList[index];
          return _buildNoticeCard(notice);
        },
      ),
    );
  }

  Widget _buildNoticeCard(Notice notice) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(notice.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getTypeName(notice.type),
                    style: TextStyle(color: _getTypeColor(notice.type), fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    notice.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: notice.status == 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    notice.status == 0 ? S.current.strings.enabled : S.current.strings.disabled,
                    style: TextStyle(
                      color: notice.status == 0 ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notice.content ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  notice.creator ?? '-',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  notice.createTime ?? '-',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _editNotice(notice),
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(S.current.strings.edit),
                ),
                TextButton.icon(
                  onPressed: () => _pushNotice(notice),
                  icon: const Icon(Icons.send, size: 18),
                  label: Text(S.current.strings.push),
                ),
                TextButton.icon(
                  onPressed: () => _deleteNotice(notice),
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: Text(S.current.strings.delete),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeName(int type) {
    switch (type) {
      case 1:
        return S.current.strings.typeNotify;
      case 2:
        return S.current.strings.typeAnnouncement;
      default:
        return S.current.strings.typeUnknown;
    }
  }

  Color _getTypeColor(int type) {
    switch (type) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showNoticeDialog(BuildContext context, [Notice? notice]) {
    final titleController = TextEditingController(text: notice?.title ?? '');
    final contentController = TextEditingController(text: notice?.content ?? '');
    final remarkController = TextEditingController(text: notice?.remark ?? '');
    int type = notice?.type ?? 1;
    int status = notice?.status ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(notice == null ? S.current.strings.addNotice : S.current.strings.editNotice),
          content: SizedBox(
            width: DeviceUIMode.select(context, mobile: () => double.maxFinite, desktop: () => 500.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: '${S.current.strings.noticeName} *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('${S.current.strings.noticeType}:'),
                  Wrap(
                    children: [
                      Radio<int>(
                        value: 1,
                        groupValue: type,
                        onChanged: (value) {
                          setState(() {
                            type = value!;
                          });
                        },
                      ),
                      Text(S.current.strings.typeNotify),
                      Radio<int>(
                        value: 2,
                        groupValue: type,
                        onChanged: (value) {
                          setState(() {
                            type = value!;
                          });
                        },
                      ),
                      Text(S.current.strings.typeAnnouncement),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('${S.current.strings.noticeContent}: *'),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                      maxLines: 6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('${S.current.strings.status}:'),
                  Wrap(
                    children: [
                      Radio<int>(
                        value: 0,
                        groupValue: status,
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                      Text(S.current.strings.enabled),
                      Radio<int>(
                        value: 1,
                        groupValue: status,
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                      Text(S.current.strings.disabled),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: remarkController,
                    decoration: const InputDecoration(
                      labelText: '备注',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.current.strings.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || contentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.current.strings.pleaseFillRequired)),
                  );
                  return;
                }

                final noticeData = Notice(
                  id: notice?.id,
                  title: titleController.text,
                  type: type,
                  content: contentController.text,
                  status: status,
                  remark: remarkController.text.isEmpty ? null : remarkController.text,
                );

                try {
                  final noticeApi = ref.read(noticeApiProvider);
                  ApiResponse<void> response;

                  if (notice == null) {
                    response = await noticeApi.createNotice(noticeData);
                  } else {
                    response = await noticeApi.updateNotice(noticeData);
                  }

                  if (response.isSuccess) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(notice == null ? S.current.strings.addSuccess : S.current.strings.editSuccess)),
                      );
                      _loadNoticeList();
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response.msg ?? S.current.strings.operationFailed)),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${S.current.strings.operationFailed}: $e')),
                    );
                  }
                }
              },
              child: Text(S.current.strings.confirm),
            ),
          ],
        ),
      ),
    );
  }

  void _editNotice(Notice notice) {
    _showNoticeDialog(context, notice);
  }

  Future<void> _deleteNotice(Notice notice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.strings.confirmDelete),
        content: Text('${S.current.strings.confirmDeleteNotice} "${notice.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.strings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(S.current.strings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final noticeApi = ref.read(noticeApiProvider);
        final response = await noticeApi.deleteNotice(notice.id!);

        if (response.isSuccess) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.strings.deleteSuccess)),
            );
            _loadNoticeList();
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg ?? S.current.strings.deleteFailed)),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${S.current.strings.deleteFailed}: $e')),
          );
        }
      }
    }
  }

  Future<void> _pushNotice(Notice notice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.strings.confirmPush),
        content: Text('${S.current.strings.confirmPushNotice} "${notice.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.strings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.current.strings.push),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final noticeApi = ref.read(noticeApiProvider);
        final response = await noticeApi.pushNotice(notice.id!);

        if (response.isSuccess) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.strings.pushSuccess)),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg ?? S.current.strings.pushFailed)),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${S.current.strings.pushFailed}: $e')),
          );
        }
      }
    }
  }
}

/// 数据源
class _NoticeDataSource extends DataTableSource {
  final List<Notice> notices;
  final BuildContext context;
  final void Function(Notice) onEdit;
  final Future<void> Function(Notice) onDelete;
  final Future<void> Function(Notice) onPush;

  _NoticeDataSource(
    this.notices,
    this.context,
    this.onEdit,
    this.onDelete,
    this.onPush,
  );

  String _getTypeName(int type) {
    switch (type) {
      case 1:
        return S.current.strings.typeNotify;
      case 2:
        return S.current.strings.typeAnnouncement;
      default:
        return S.current.strings.typeUnknown;
    }
  }

  Color _getTypeColor(int type) {
    switch (type) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  int get rowCount => notices.length;

  Widget _buildActionButtons(Notice notice) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => onEdit(notice),
          child: Text(S.current.strings.edit),
        ),
        PopupMenuButton<String>(
          tooltip: S.current.more,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'push',
              child: Row(
                children: [
                  const Icon(Icons.send, size: 18),
                  const SizedBox(width: 8),
                  Text(S.current.strings.push),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(S.current.strings.delete, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'push':
                onPush(notice);
                break;
              case 'delete':
                onDelete(notice);
                break;
            }
          },
        ),
      ],
    );
  }

  @override
  DataRow getRow(int index) {
    final notice = notices[index];
    return DataRow(
      cells: [
        DataCell(Text(notice.id?.toString() ?? '-')),
        DataCell(Text(notice.title)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getTypeColor(notice.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getTypeName(notice.type),
              style: TextStyle(
                color: _getTypeColor(notice.type),
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: notice.status == 0
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              notice.status == 0 ? S.current.strings.enabled : S.current.strings.disabled,
              style: TextStyle(
                color: notice.status == 0 ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(Text(notice.creator ?? '-')),
        DataCell(Text(notice.createTime ?? '-')),
        DataCell(_buildActionButtons(notice)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}