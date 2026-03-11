import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/demo03_student_inner_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo03_student.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import '../demo03-normal/widgets/demo03_search_form.dart';
import '../demo03-normal/widgets/demo03_action_buttons.dart';
import 'dialogs/demo03_inner_form_dialog.dart';
import 'widgets/demo03_expandable_data_table.dart';

/// 学生管理页面 - Demo03 Inner模式（子表内嵌展开）
class Demo03InnerPage extends ConsumerStatefulWidget {
  const Demo03InnerPage({super.key});

  @override
  ConsumerState<Demo03InnerPage> createState() => _Demo03InnerPageState();
}

class _Demo03InnerPageState extends ConsumerState<Demo03InnerPage> {
  final _nameController = TextEditingController();
  int? _selectedSex;

  List<Demo03Student> _studentList = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;
  Set<int> _selectedIds = {};
  Set<int> _expandedRows = {};

  @override
  void initState() {
    super.initState();
    _loadStudentList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final studentApi = ref.read(demo03StudentInnerApiProvider);
      final params = <String, dynamic>{
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_nameController.text.isNotEmpty) 'name': _nameController.text,
        if (_selectedSex != null) 'sex': _selectedSex,
      };

      final response = await studentApi.getDemo03StudentPage(params);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _studentList = response.data!.list;
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
    _loadStudentList();
  }

  void _reset() {
    _nameController.clear();
    setState(() {
      _selectedSex = null;
      _currentPage = 1;
    });
    _loadStudentList();
  }

  Future<void> _deleteStudent(Demo03Student student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteItem} "${student.name}" ?'),
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
        final studentApi = ref.read(demo03StudentInnerApiProvider);
        final response = await studentApi.deleteDemo03Student(student.id!);

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadStudentList();
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

  Future<void> _deleteBatch() async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text(
            '${S.current.confirmDeleteSelected} ${_selectedIds.length} ${S.current.items}'),
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
        final studentApi = ref.read(demo03StudentInnerApiProvider);
        final response =
            await studentApi.deleteDemo03StudentList(_selectedIds.toList());

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            setState(() => _selectedIds = {});
            _loadStudentList();
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
      final studentApi = ref.read(demo03StudentInnerApiProvider);
      final params = <String, dynamic>{
        if (_nameController.text.isNotEmpty) 'name': _nameController.text,
        if (_selectedSex != null) 'sex': _selectedSex,
      };
      await studentApi.exportDemo03Student(params);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 搜索栏
          Demo03SearchForm(
            nameController: _nameController,
            selectedSex: _selectedSex,
            onSexChanged: (value) => setState(() => _selectedSex = value),
            onSearch: _search,
            onReset: _reset,
          ),
          const Divider(height: 1),

          // 工具栏
          Demo03ActionButtons(
            onAdd: () => showDemo03InnerFormDialog(
              context,
              ref: ref,
              onSuccess: _loadStudentList,
            ),
            onExport: _export,
            onDeleteBatch: _selectedIds.isNotEmpty ? _deleteBatch : null,
            hasSelection: _selectedIds.isNotEmpty,
          ),
          const Divider(height: 1),

          // 可展开的数据表格
          Expanded(
            child: Demo03ExpandableDataTable(
              studentList: _studentList,
              totalCount: _totalCount,
              currentPage: _currentPage,
              pageSize: _pageSize,
              isLoading: _isLoading,
              error: _error,
              onReload: _loadStudentList,
              onPageSizeChanged: (value) {
                setState(() {
                  _pageSize = value;
                  _currentPage = 1;
                });
                _loadStudentList();
              },
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                _loadStudentList();
              },
              onEdit: (student) => showDemo03InnerFormDialog(
                context,
                student: student,
                ref: ref,
                onSuccess: _loadStudentList,
              ),
              onDelete: _deleteStudent,
              selectedIds: _selectedIds,
              onSelectionChanged: (ids) => setState(() => _selectedIds = ids),
              expandedRows: _expandedRows,
              onExpandChanged: (id, isExpanded) {
                setState(() {
                  if (isExpanded) {
                    _expandedRows.add(id);
                  } else {
                    _expandedRows.remove(id);
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}