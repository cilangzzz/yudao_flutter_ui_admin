import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/notice_api.dart';
import '../../../models/system/notice.dart';
import '../../../models/common/api_response.dart';

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
          _error = response.msg ?? '加载失败';
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
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(context),
          const Divider(height: 1),

          // 数据表格
          Expanded(
            child: _buildDataTable(context),
          ),
        ],
      ),

      // 添加公告按钮
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoticeDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('添加公告'),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 公告标题搜索
          SizedBox(
            width: 200,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '公告标题',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          const SizedBox(width: 16),

          // 状态筛选
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<int?>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: '状态',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('全部')),
                DropdownMenuItem(value: 0, child: Text('启用')),
                DropdownMenuItem(value: 1, child: Text('禁用')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
          ),
          const SizedBox(width: 16),

          // 搜索按钮
          ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search),
            label: const Text('搜索'),
          ),
          const SizedBox(width: 8),

          // 重置按钮
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            label: const Text('重置'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNoticeList,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_noticeList.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PaginatedDataTable(
        header: const Text('公告列表'),
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
        columns: const [
          DataColumn(label: Text('公告编号')),
          DataColumn(label: Text('公告标题')),
          DataColumn(label: Text('公告类型')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('创建者')),
          DataColumn(label: Text('创建时间')),
          DataColumn(label: Text('操作')),
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

  void _showNoticeDialog(BuildContext context, [Notice? notice]) {
    final titleController = TextEditingController(text: notice?.title ?? '');
    final contentController = TextEditingController(text: notice?.content ?? '');
    final remarkController = TextEditingController(text: notice?.remark ?? '');
    int type = notice?.type ?? 1; // 默认通知
    int status = notice?.status ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(notice == null ? '添加公告' : '编辑公告'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: '公告标题 *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('公告类型:'),
                  Row(
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
                      const Text('通知'),
                      Radio<int>(
                        value: 2,
                        groupValue: type,
                        onChanged: (value) {
                          setState(() {
                            type = value!;
                          });
                        },
                      ),
                      const Text('公告'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('公告内容: *'),
                  const SizedBox(height: 8),
                  Container(
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
                  const Text('状态:'),
                  Row(
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
                      const Text('启用'),
                      Radio<int>(
                        value: 1,
                        groupValue: status,
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                          });
                        },
                      ),
                      const Text('禁用'),
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
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || contentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请填写必填项')),
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
                        SnackBar(content: Text(notice == null ? '添加成功' : '修改成功')),
                      );
                      _loadNoticeList();
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response.msg ?? '操作失败')),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('操作失败: $e')),
                    );
                  }
                }
              },
              child: const Text('确定'),
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
        title: const Text('确认删除'),
        content: Text('确定要删除公告 "${notice.title}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('删除'),
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
              const SnackBar(content: Text('删除成功')),
            );
            _loadNoticeList();
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg ?? '删除失败')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
    }
  }

  Future<void> _pushNotice(Notice notice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认推送'),
        content: Text('确定要推送公告 "${notice.title}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('推送'),
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
              const SnackBar(content: Text('推送成功')),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg ?? '推送失败')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('推送失败: $e')),
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
        return '通知';
      case 2:
        return '公告';
      default:
        return '未知';
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
              notice.status == 0 ? '启用' : '禁用',
              style: TextStyle(
                color: notice.status == 0 ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(Text(notice.creator ?? '-')),
        DataCell(Text(notice.createTime ?? '-')),
        DataCell(
          Row(
            children: [
              TextButton(
                onPressed: () => onEdit(notice),
                child: const Text('编辑'),
              ),
              TextButton(
                onPressed: () => onPush(notice),
                child: const Text('推送'),
              ),
              TextButton(
                onPressed: () => onDelete(notice),
                child: const Text('删除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}