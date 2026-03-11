import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/system/post_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/post.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 岗位表单对话框（新增/编辑岗位）
class PostFormDialog extends StatefulWidget {
  final Post? post;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const PostFormDialog({
    super.key,
    this.post,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<PostFormDialog> createState() => _PostFormDialogState();
}

class _PostFormDialogState extends State<PostFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _sortController;
  late final TextEditingController _remarkController;
  late int _status;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.post?.name ?? '');
    _codeController = TextEditingController(text: widget.post?.code ?? '');
    _sortController = TextEditingController(text: (widget.post?.sort ?? 0).toString());
    _remarkController = TextEditingController(text: widget.post?.remark ?? '');
    _status = widget.post?.status ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _sortController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty || _codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseFillRequired)),
      );
      return;
    }

    final postData = Post(
      id: widget.post?.id,
      name: _nameController.text,
      code: _codeController.text,
      sort: int.tryParse(_sortController.text) ?? 0,
      status: _status,
      remark: _remarkController.text.isEmpty ? null : _remarkController.text,
    );

    try {
      final postApi = widget.ref.read(postApiProvider);
      ApiResponse<void> response;

      if (widget.post == null) {
        response = await postApi.createPost(postData);
      } else {
        response = await postApi.updatePost(postData);
      }

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.post == null ? S.current.addSuccess : S.current.editSuccess)),
          );
          widget.onSuccess();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg ?? S.current.operationFailed)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.operationFailed}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.post == null ? S.current.addPost : S.current.editPost),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${S.current.postName} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: '${S.current.postCode} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _sortController,
                decoration: InputDecoration(
                  labelText: S.current.postSort,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _status,
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
                    setState(() => _status = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _remarkController,
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
          onPressed: _submit,
          child: Text(S.current.confirm),
        ),
      ],
    );
  }
}

/// 显示岗位表单对话框的便捷方法
void showPostFormDialog(
  BuildContext context, {
  Post? post,
  required WidgetRef ref,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (context) => PostFormDialog(
      post: post,
      ref: ref,
      onSuccess: onSuccess,
    ),
  );
}