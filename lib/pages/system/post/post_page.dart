import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/post_api.dart';
import '../../../models/system/post.dart';
import '../../../models/common/page_result.dart';
import '../../../models/common/api_response.dart';
import '../../../i18n/i18n.dart';

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
          _error = response.msg ?? S.current.loadFailed;
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
        label: Text(S.current.addPost),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // 岗位名称搜索
          SizedBox(
            width: 220,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: S.current.postName,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          // 岗位编码搜索
          SizedBox(
            width: 220,
            child: TextField(
              controller: _codeSearchController,
              decoration: InputDecoration(
                hintText: S.current.postCode,
                prefixIcon: const Icon(Icons.code),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          // 状态筛选
          SizedBox(
            width: 160,
            child: DropdownButtonFormField<int?>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: S.current.status,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(S.current.all)),
                DropdownMenuItem(value: 0, child: Text(S.current.enabled)),
                DropdownMenuItem(value: 1, child: Text(S.current.disabled)),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
          ),
          // 搜索按钮
          ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search),
            label: Text(S.current.search),
          ),
          // 重置按钮
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            label: Text(S.current.reset),
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
            Text('${S.current.loadFailed}: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPostList,
              child: Text(S.current.retry),
            ),
          ],
        ),
      );
    }

    if (_postList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PaginatedDataTable(
        header: Text(S.current.postList),
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
        columns: [
          DataColumn(label: Text(S.current.postId)),
          DataColumn(label: Text(S.current.postName)),
          DataColumn(label: Text(S.current.postCode)),
          DataColumn(label: Text(S.current.postSort)),
          DataColumn(label: Text(S.current.status)),
          DataColumn(label: Text(S.current.remark)),
          DataColumn(label: Text(S.current.createTime)),
          DataColumn(label: Text(S.current.operation)),
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
          title: Text(post == null ? S.current.addPost : S.current.editPost),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '${S.current.postName} *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: '${S.current.postCode} *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: sortController,
                    decoration: InputDecoration(
                      labelText: S.current.postSort,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: status,
                    decoration: InputDecoration(
                      labelText: S.current.status,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 0, child: Text(S.current.enabled)),
                      DropdownMenuItem(value: 1, child: Text(S.current.disabled)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => status = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: remarkController,
                    decoration: InputDecoration(
                      labelText: S.current.remark,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.current.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || codeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.current.pleaseFillRequired)),
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
                        SnackBar(content: Text(post == null ? S.current.addSuccess : S.current.editSuccess)),
                      );
                      _loadPostList();
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response.msg ?? S.current.operationFailed)),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${S.current.operationFailed}: $e')),
                    );
                  }
                }
              },
              child: Text(S.current.confirm),
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
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeletePost} "${post.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(S.current.delete),
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
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadPostList();
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg ?? S.current.deleteFailed)),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${S.current.deleteFailed}: $e')),
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
              post.status == 0 ? S.current.enabled : S.current.disabled,
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
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              TextButton(
                onPressed: () => onEdit(post),
                child: Text(S.current.edit),
              ),
              TextButton(
                onPressed: () => onDelete(post),
                child: Text(S.current.delete, style: TextStyle(color: Colors.red)),
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