import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/post_api.dart';
import '../../../models/system/post.dart';
import '../../../i18n/i18n.dart';
import 'widgets/post_search_form.dart';
import 'widgets/post_action_buttons.dart';
import 'widgets/post_data_table.dart';
import 'dialogs/post_form_dialog.dart';

/// 岗位管理页面
class PostPage extends ConsumerStatefulWidget {
  const PostPage({super.key});

  @override
  ConsumerState<PostPage> createState() => _PostPageState();
}

class _PostPageState extends ConsumerState<PostPage> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
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
    _nameController.dispose();
    _codeController.dispose();
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
        if (_nameController.text.isNotEmpty) 'name': _nameController.text,
        if (_codeController.text.isNotEmpty) 'code': _codeController.text,
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
    setState(() => _currentPage = 1);
    _loadPostList();
  }

  void _reset() {
    _nameController.clear();
    _codeController.clear();
    setState(() {
      _selectedStatus = null;
      _currentPage = 1;
    });
    _loadPostList();
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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadPostList();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg ?? S.current.deleteFailed)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${S.current.deleteFailed}: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 搜索栏
          PostSearchForm(
            nameController: _nameController,
            codeController: _codeController,
            selectedStatus: _selectedStatus,
            onStatusChanged: (value) => setState(() => _selectedStatus = value),
            onSearch: _search,
            onReset: _reset,
          ),
          const Divider(height: 1),

          // 工具栏
          PostActionButtons(
            onAdd: () => showPostFormDialog(
              context,
              ref: ref,
              onSuccess: _loadPostList,
            ),
          ),
          const Divider(height: 1),

          // 数据表格
          Expanded(
            child: PostDataTable(
              postList: _postList,
              totalCount: _totalCount,
              currentPage: _currentPage,
              pageSize: _pageSize,
              isLoading: _isLoading,
              error: _error,
              onReload: _loadPostList,
              onPageSizeChanged: (value) {
                setState(() {
                  _pageSize = value;
                  _currentPage = 1;
                });
                _loadPostList();
              },
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                _loadPostList();
              },
              onEdit: (post) => showPostFormDialog(
                context,
                post: post,
                ref: ref,
                onSuccess: _loadPostList,
              ),
              onDelete: _deletePost,
            ),
          ),
        ],
      ),
    );
  }
}