import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/demo02_category_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo02_category.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 示例分类表单对话框（新增/编辑）
class Demo02FormDialog extends StatefulWidget {
  final Demo02Category? category;
  final int? parentId;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const Demo02FormDialog({
    super.key,
    this.category,
    this.parentId,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<Demo02FormDialog> createState() => _Demo02FormDialogState();
}

class _Demo02FormDialogState extends State<Demo02FormDialog> {
  late final TextEditingController _nameController;
  late int _parentId;
  List<Demo02Category> _categoryOptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _parentId = widget.category?.parentId ?? widget.parentId ?? 0;
    _loadCategoryOptions();
  }

  Future<void> _loadCategoryOptions() async {
    try {
      final categoryApi = widget.ref.read(demo02CategoryApiProvider);
      final response = await categoryApi.getDemo02CategoryList({});
      if (response.isSuccess && response.data != null) {
        setState(() {
          _categoryOptions = [
            Demo02Category(id: 0, name: S.current.topLevel, parentId: 0),
            ...response.data!,
          ];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseFillRequired)),
      );
      return;
    }

    final categoryData = Demo02Category(
      id: widget.category?.id,
      name: _nameController.text,
      parentId: _parentId,
    );

    try {
      final categoryApi = widget.ref.read(demo02CategoryApiProvider);
      ApiResponse<void> response;

      if (widget.category == null) {
        response = await categoryApi.createDemo02Category(categoryData);
      } else {
        response = await categoryApi.updateDemo02Category(categoryData);
      }

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.category == null ? S.current.addSuccess : S.current.editSuccess)),
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
      title: Text(widget.category == null
        ? '${S.current.add}${S.current.demo02Category}'
        : '${S.current.edit}${S.current.demo02Category}'),
      content: SizedBox(
        width: 400,
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: _parentId,
                  decoration: InputDecoration(
                    labelText: S.current.parentCategory,
                    border: const OutlineInputBorder(),
                  ),
                  items: _buildDropdownItems(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _parentId = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '${S.current.name} *',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
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

  List<DropdownMenuItem<int>> _buildDropdownItems() {
    return _categoryOptions.map((category) {
      return DropdownMenuItem(
        value: category.id ?? 0,
        child: Text(category.name),
      );
    }).toList();
  }
}

/// 显示示例分类表单对话框的便捷方法
void showDemo02FormDialog(
  BuildContext context, {
  Demo02Category? category,
  int? parentId,
  required WidgetRef ref,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (context) => Demo02FormDialog(
      category: category,
      parentId: parentId,
      ref: ref,
      onSuccess: onSuccess,
    ),
  );
}