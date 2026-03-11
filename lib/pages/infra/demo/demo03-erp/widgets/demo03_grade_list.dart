import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/demo03_student_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo03_student.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 学生班级列表组件 - ERP模式
class Demo03GradeList extends ConsumerStatefulWidget {
  final int? studentId;

  const Demo03GradeList({
    super.key,
    this.studentId,
  });

  @override
  ConsumerState<Demo03GradeList> createState() => _Demo03GradeListState();
}

class _Demo03GradeListState extends ConsumerState<Demo03GradeList> {
  Demo03Grade? _grade;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGradeList();
  }

  @override
  void didUpdateWidget(Demo03GradeList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.studentId != widget.studentId) {
      _loadGradeList();
    }
  }

  Future<void> _loadGradeList() async {
    if (widget.studentId == null) {
      setState(() {
        _grade = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final studentApi = ref.read(demo03StudentApiProvider);
      final response = await studentApi.getDemo03GradeByStudentId(widget.studentId!);

      if (response.isSuccess) {
        setState(() {
          _grade = response.data;
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

  @override
  Widget build(BuildContext context) {
    if (widget.studentId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              S.current.pleaseSelectStudent,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${S.current.loadFailed}: $_error',
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadGradeList,
              child: Text(S.current.retry),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 工具栏
          Row(
            children: [
              Text('${S.current.gradeInfo}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: 添加班级
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text(S.current.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 表格
          Expanded(
            child: _grade == null
                ? Center(child: Text(S.current.noData))
                : DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 400,
                    headingRowColor: WidgetStateProperty.resolveWith(
                      (states) =>
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    columns: [
                      DataColumn2(label: Text(S.current.id), size: ColumnSize.S),
                      DataColumn2(
                          label: Text(S.current.gradeName), size: ColumnSize.L),
                      DataColumn2(
                          label: Text(S.current.teacher), size: ColumnSize.M),
                      DataColumn2(
                          label: Text(S.current.operation), size: ColumnSize.M),
                    ],
                    rows: [
                      DataRow2(
                        cells: [
                          DataCell(Text(_grade!.id?.toString() ?? '-')),
                          DataCell(Text(_grade!.name)),
                          DataCell(Text(_grade!.teacher)),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () {
                                  // TODO: 编辑
                                },
                                child: Text(S.current.edit),
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: 删除
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: Text(S.current.delete),
                              ),
                            ],
                          )),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}