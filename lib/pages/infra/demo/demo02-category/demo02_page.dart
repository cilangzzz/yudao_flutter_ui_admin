import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/demo02_category_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo02_category.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'widgets/demo02_search_form.dart';
import 'widgets/demo02_action_buttons.dart';
import 'widgets/demo02_tree_table.dart';
import 'dialogs/demo02_form_dialog.dart';

/// 示例分类管理页面 - Demo02 (树形结构)
class Demo02Page extends ConsumerStatefulWidget {
  const Demo02Page({super.key});

  @override
  ConsumerState<Demo02Page> createState() => _Demo02PageState();
}

class _Demo02PageState extends ConsumerState<Demo02Page> {
  final _nameController = TextEditingController();

  List<Demo02Category> _categoryList = [];
  bool _isLoading = true;
  String? _error;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadCategoryList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final categoryApi = ref.read(demo02CategoryApiProvider);
      final params = <String, dynamic>{
        if (_nameController.text.isNotEmpty) 'name': _nameController.text,
      };

      final response = await categoryApi.getDemo02CategoryList(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _categoryList = _buildTree(response.data!);
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

  /// 构建树形结构
  List<Demo02Category> _buildTree(List<Demo02Category> categories) {
    final Map<int, Demo02Category> categoryMap = {};
    final List<Demo02Category> rootCategories = [];

    // 创建映射
    for (final category in categories) {
      categoryMap[category.id!] = category;
    }

    // 构建树
    for (final category in categories) {
      if (category.parentId == 0) {
        rootCategories.add(category);
      } else {
        final parent = categoryMap[category.parentId];
        if (parent != null) {
          parent.children ??= [];
          parent.children!.add(category);
        }
      }
    }

    return rootCategories;
  }

  void _search() {
    _loadCategoryList();
  }

  void _reset() {
    _nameController.clear();
    _loadCategoryList();
  }

  Future<void> _deleteCategory(Demo02Category category) async {
    // 检查是否有子节点
    if (category.children != null && category.children!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.cannotDeleteWithChildren)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteItem} "${category.name}" ?'),
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
        final categoryApi = ref.read(demo02CategoryApiProvider);
        final response = await categoryApi.deleteDemo02Category(category.id!);

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadCategoryList();
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

  Future<void> _export() async {
    try {
      final categoryApi = ref.read(demo02CategoryApiProvider);
      final params = <String, dynamic>{
        if (_nameController.text.isNotEmpty) 'name': _nameController.text,
      };
      await categoryApi.exportDemo02Category(params);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.exportSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.exportFailed}: $e')),
        );
      }
    }
  }

  void _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 搜索栏
          Demo02SearchForm(
            nameController: _nameController,
            onSearch: _search,
            onReset: _reset,
          ),
          const Divider(height: 1),

          // 工具栏
          Demo02ActionButtons(
            onAdd: () => showDemo02FormDialog(
              context,
              ref: ref,
              onSuccess: _loadCategoryList,
            ),
            onExpand: _toggleExpand,
            onExport: _export,
            isExpanded: _isExpanded,
          ),
          const Divider(height: 1),

          // 树形表格
          Expanded(
            child: Demo02TreeTable(
              categoryList: _categoryList,
              isLoading: _isLoading,
              error: _error,
              onReload: _loadCategoryList,
              onEdit: (category) => showDemo02FormDialog(
                context,
                category: category,
                ref: ref,
                onSuccess: _loadCategoryList,
              ),
              onDelete: _deleteCategory,
              onAddChild: (category) => showDemo02FormDialog(
                context,
                parentId: category.id,
                ref: ref,
                onSuccess: _loadCategoryList,
              ),
              onExpandAll: (expanded) => setState(() => _isExpanded = expanded),
              isExpanded: _isExpanded,
            ),
          ),
        ],
      ),
    );
  }
}