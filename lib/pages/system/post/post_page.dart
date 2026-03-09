import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/post_api.dart';
import '../../../models/system/post.dart';
import '../../../models/common/page_result.dart';
import '../../../models/common/api_response.dart';

/// 岗位管理页面
class PostPage extends ConsumerStatefulWidget {
  const PostPage({super.key});

  @override
  ConsumerState<PostPage> createState() => _PostPageState();
}

class _PostPageState extends ConsumerState<PostPage> {
  final _searchController = TextEditingController();
  final _codeSearchController = TextEditingController();
  int? _selectedStatus;

  List<Post> _postList = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPostList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _codeSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadPostList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final postApi = ref.read(postApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_searchController.text.isNotEmpty) 'name': _searchController.text,
        if (_codeSearchController.text.isNotEmpty) 'code': _codeSearchController.text,
        if (_selectedStatus != null) 'status': _selectedStatus,
      };

      final response = await postApi.getPostPage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _postList = response.data!.list;
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
    _loadPostList();
  }

  void _reset() {
    _searchController.clear();
    _codeSearchController.clear();
    setState(() {
      _selectedStatus = null;
    });
    _currentPage = 1;
    _loadPostList();
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

      // 添加岗位按钮
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPostDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('添加岗位'),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 岗位名称搜索
          SizedBox(
            width: 200,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '岗位名称',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          const SizedBox(width: 16),

          // 岗位编码搜索
          SizedBox(
            width: 200,
            child: TextField(
              controller: _codeSearchController,
              decoration: const InputDecoration(
                hintText: '岗位编码',
                prefixIcon: Icon(Icons.code),
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
              onPressed: _loadPostList,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_postList.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PaginatedDataTable(
        header: const Text('岗位列表'),
        rowsPerPage: _pageSize,
        availableRowsPerPage: const [10, 20, 50, 100],
        onPageChanged: (page) {
          setState(() {
            _currentPage = page ~/ _pageSize + 1;
          });
          _loadPostList();
        },
        onRowsPerPageChanged: (value) {
          if (value != null) {
            setState(() {
              _pageSize = value;
              _currentPage = 1;
            });
            _loadPostList();
          }
        },
        columns: const [
          DataColumn(label: Text('岗位编号')),
          DataColumn(label: Text('岗位名称')),
          DataColumn(label: Text('岗位编码')),
          DataColumn(label: Text('显示顺序')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('备注')),
          DataColumn(label: Text('创建时间')),
          DataColumn(label: Text('操作')),
        ],
        source: _PostDataSource(_postList, context, _editPost, _deletePost),
      ),
    );
  }

  void _showPostDialog(BuildContext context, [Post? post]) {
    final nameController = TextEditingController(text: post?.name ?? '');
    final codeController = TextEditingController(text: post?.code ?? '');
    final sortController = TextEditingController(text: (post?.sort ?? 0).toString());
    final remarkController = TextEditingController(text: post?.remark ?? '');
    int status = post?.status ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(post == null ? '添加岗位' : '编辑岗位'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '岗位名称 *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: '岗位编码 *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sortController,
                  decoration: const InputDecoration(
                    labelText: '显示顺序',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('状态: '),
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
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || codeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请填写必填项')),
                  );
                  return;
                }

                final postData = Post(
                  id: post?.id,
                  name: nameController.text,
                  code: codeController.text,
                  sort: int.tryParse(sortController.text) ?? 0,
                  status: status,
                  remark: remarkController.text.isEmpty ? null : remarkController.text,
                );

                try {
                  final postApi = ref.read(postApiProvider);
                  ApiResponse<void> response;

                  if (post == null) {
                    response = await postApi.createPost(postData);
                  } else {
                    response = await postApi.updatePost(postData);
                  }

                  if (response.isSuccess) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(post == null ? '添加成功' : '修改成功')),
                      );
                      _loadPostList();
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

  void _editPost(Post post) {
    _showPostDialog(context, post);
  }

  Future<void> _deletePost(Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除岗位 "${post.name}" 吗？'),
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
        final postApi = ref.read(postApiProvider);
        final response = await postApi.deletePost(post.id!);

        if (response.isSuccess) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('删除成功')),
            );
            _loadPostList();
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
}

/// 数据源
class _PostDataSource extends DataTableSource {
  final List<Post> posts;
  final BuildContext context;
  final void Function(Post) onEdit;
  final Future<void> Function(Post) onDelete;

  _PostDataSource(this.posts, this.context, this.onEdit, this.onDelete);

  @override
  int get rowCount => posts.length;

  @override
  DataRow getRow(int index) {
    final post = posts[index];
    return DataRow(
      cells: [
        DataCell(Text(post.id?.toString() ?? '-')),
        DataCell(Text(post.name)),
        DataCell(Text(post.code)),
        DataCell(Text(post.sort.toString())),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: post.status == 0
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              post.status == 0 ? '启用' : '禁用',
              style: TextStyle(
                color: post.status == 0 ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(Text(post.remark ?? '-')),
        DataCell(Text(post.createTime ?? '-')),
        DataCell(
          Row(
            children: [
              TextButton(
                onPressed: () => onEdit(post),
                child: const Text('编辑'),
              ),
              TextButton(
                onPressed: () => onDelete(post),
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