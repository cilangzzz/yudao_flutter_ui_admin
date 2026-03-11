import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/demo03_student_erp_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo03_student.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 学生课程列表组件 - ERP模式
class Demo03CourseList extends ConsumerStatefulWidget {
  final int? studentId;

  const Demo03CourseList({
    super.key,
    this.studentId,
  });

  @override
  ConsumerState<Demo03CourseList> createState() => _Demo03CourseListState();
}

class _Demo03CourseListState extends ConsumerState<Demo03CourseList> {
  List<Demo03Course> _courseList = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = false;
  String? _error;
  Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadCourseList();
  }

  @override
  void didUpdateWidget(Demo03CourseList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.studentId != widget.studentId) {
      _currentPage = 1;
      _loadCourseList();
    }
  }

  Future<void> _loadCourseList() async {
    if (widget.studentId == null) {
      setState(() {
        _courseList = [];
        _totalCount = 0;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final studentApi = ref.read(demo03StudentErpApiProvider);
      final response = await studentApi.getDemo03CoursePage({
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        'studentId': widget.studentId,
      });

      if (response.isSuccess && response.data != null) {
        setState(() {
          _courseList = response.data!.list;
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

  Future<void> _deleteCourse(Demo03Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteItem} "${course.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(S.current.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final studentApi = ref.read(demo03StudentErpApiProvider);
        final response = await studentApi.deleteDemo03Course(course.id!);

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadCourseList();
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
              onPressed: _loadCourseList,
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
              Text('${S.current.courseList}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: 添加课程
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text(S.current.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 表格
          Expanded(
            child: _courseList.isEmpty
                ? Center(child: Text(S.current.noData))
                : DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 400,
                    headingRowColor: WidgetStateProperty.resolveWith(
                      (states) => Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    columns: [
                      DataColumn2(label: Text(S.current.id), size: ColumnSize.S),
                      DataColumn2(label: Text(S.current.courseName), size: ColumnSize.L),
                      DataColumn2(label: Text(S.current.score), size: ColumnSize.M),
                      DataColumn2(label: Text(S.current.operation), size: ColumnSize.M),
                    ],
                    rows: _courseList.map((course) {
                      return DataRow2(
                        cells: [
                          DataCell(Text(course.id?.toString() ?? '-')),
                          DataCell(Text(course.name)),
                          DataCell(Text(course.score.toString())),
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
                                onPressed: () => _deleteCourse(course),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: Text(S.current.delete),
                              ),
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
          ),
          // 分页
          if (_totalCount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text('${S.current.pageSize}: '),
                    DropdownButton<int>(
                      value: _pageSize,
                      items: [10, 20, 50, 100].map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text('$value'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _pageSize = value;
                            _currentPage = 1;
                          });
                          _loadCourseList();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _currentPage > 1
                          ? () {
                              setState(() => _currentPage--);
                              _loadCourseList();
                            }
                          : null,
                    ),
                    Text('$_currentPage / ${(_totalCount / _pageSize).ceil()}'),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _currentPage * _pageSize < _totalCount
                          ? () {
                              setState(() => _currentPage++);
                              _loadCourseList();
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}