import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/demo03_student_inner_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo03_student.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 可展开的行内容 - Inner模式
class Demo03ExpandableRow extends ConsumerStatefulWidget {
  final Demo03Student student;

  const Demo03ExpandableRow({
    super.key,
    required this.student,
  });

  @override
  ConsumerState<Demo03ExpandableRow> createState() => _Demo03ExpandableRowState();
}

class _Demo03ExpandableRowState extends ConsumerState<Demo03ExpandableRow>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Demo03Course> _courses = [];
  Demo03Grade? _grade;
  bool _isLoadingCourses = false;
  bool _isLoadingGrade = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _loadCourses();
    _loadGrade();
  }

  Future<void> _loadCourses() async {
    if (widget.student.id == null) return;

    setState(() => _isLoadingCourses = true);

    try {
      final studentApi = ref.read(demo03StudentInnerApiProvider);
      final response = await studentApi.getDemo03CourseListByStudentId(widget.student.id!);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _courses = response.data!;
          _isLoadingCourses = false;
        });
      } else {
        setState(() => _isLoadingCourses = false);
      }
    } catch (e) {
      setState(() => _isLoadingCourses = false);
    }
  }

  Future<void> _loadGrade() async {
    if (widget.student.id == null) return;

    setState(() => _isLoadingGrade = true);

    try {
      final studentApi = ref.read(demo03StudentInnerApiProvider);
      final response = await studentApi.getDemo03GradeByStudentId(widget.student.id!);

      if (response.isSuccess) {
        setState(() {
          _grade = response.data;
          _isLoadingGrade = false;
        });
      } else {
        setState(() => _isLoadingGrade = false);
      }
    } catch (e) {
      setState(() => _isLoadingGrade = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab 栏
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(text: S.current.courseList),
                Tab(text: S.current.gradeInfo),
              ],
            ),
          ),
          // Tab 内容
          SizedBox(
            height: 200,
            child: TabBarView(
              controller: _tabController,
              children: [
                // 课程列表
                _buildCourseList(),
                // 班级信息
                _buildGradeInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList() {
    if (_isLoadingCourses) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_courses.isEmpty) {
      return Center(
        child: Text(S.current.noData),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(course.name),
            subtitle: Text('${S.current.score}: ${course.score}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    // TODO: 编辑课程
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () {
                    // TODO: 删除课程
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradeInfo() {
    if (_isLoadingGrade) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_grade == null) {
      return Center(
        child: Text(S.current.noData),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${S.current.gradeName}:',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(_grade!.name),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${S.current.teacher}:',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(_grade!.teacher),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // TODO: 编辑班级
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(S.current.edit),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: 删除班级
                    },
                    icon: const Icon(Icons.delete, size: 18),
                    label: Text(S.current.delete),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}