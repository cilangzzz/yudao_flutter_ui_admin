import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/demo03_student_normal_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo03_student.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import '../widgets/demo03_course_table.dart';
import '../widgets/demo03_grade_form.dart';

/// 学生表单对话框（新增/编辑，包含主子表）
class Demo03FormDialog extends StatefulWidget {
  final Demo03Student? student;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const Demo03FormDialog({
    super.key,
    this.student,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<Demo03FormDialog> createState() => _Demo03FormDialogState();
}

class _Demo03FormDialogState extends State<Demo03FormDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final TextEditingController _nameController;
  late int _sex;
  DateTime? _birthday;
  late final TextEditingController _descriptionController;

  List<Demo03Course> _courses = [];
  Demo03Grade? _grade;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _sex = widget.student?.sex ?? 1;
    if (widget.student?.birthday != null) {
      _birthday = DateTime.fromMillisecondsSinceEpoch(widget.student!.birthday!);
    }
    _descriptionController = TextEditingController(text: widget.student?.description ?? '');
    _courses = List.from(widget.student?.demo03Courses ?? []);
    _grade = widget.student?.demo03Grade;

    // 如果是编辑模式，加载完整数据
    if (widget.student?.id != null) {
      _loadStudentDetail();
    }
  }

  Future<void> _loadStudentDetail() async {
    setState(() => _isLoading = true);
    try {
      final studentApi = widget.ref.read(demo03StudentNormalApiProvider);
      final response = await studentApi.getDemo03Student(widget.student!.id!);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _courses = List.from(response.data!.demo03Courses ?? []);
          _grade = response.data!.demo03Grade;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseFillRequired)),
      );
      return;
    }

    if (_grade == null || _grade!.name.isEmpty || _grade!.teacher.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseFillGradeInfo)),
      );
      _tabController.animateTo(1);
      return;
    }

    final studentData = Demo03Student(
      id: widget.student?.id,
      name: _nameController.text,
      sex: _sex,
      birthday: _birthday?.millisecondsSinceEpoch,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      demo03Grade: _grade,
      demo03Courses: _courses,
    );

    try {
      final studentApi = widget.ref.read(demo03StudentNormalApiProvider);
      ApiResponse<void> response;

      if (widget.student == null) {
        response = await studentApi.createDemo03Student(studentData);
      } else {
        response = await studentApi.updateDemo03Student(studentData);
      }

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.student == null ? S.current.addSuccess : S.current.editSuccess)),
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
      title: Text(widget.student == null
        ? '${S.current.add}${S.current.student}'
        : '${S.current.edit}${S.current.student}'),
      content: SizedBox(
        width: 700,
        height: 600,
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 基本信息
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.current.basicInfo, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: '${S.current.name} *',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _sex,
                                decoration: InputDecoration(
                                  labelText: S.current.sex,
                                  border: const OutlineInputBorder(),
                                ),
                                items: [
                                  DropdownMenuItem(value: 1, child: Text(S.current.male)),
                                  DropdownMenuItem(value: 2, child: Text(S.current.female)),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _sex = value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _birthday ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => _birthday = date);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: S.current.birthday,
                              border: const OutlineInputBorder(),
                            ),
                            child: Text(
                              _birthday != null
                                ? '${_birthday!.year}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}'
                                : S.current.selectDate,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: S.current.description,
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),

                        // 子表 Tab
                        TabBar(
                          controller: _tabController,
                          tabs: [
                            Tab(text: S.current.courseList),
                            Tab(text: S.current.gradeInfo),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 250,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // 课程列表
                              Demo03CourseTable(
                                courses: _courses,
                                onChanged: (courses) => _courses = courses,
                              ),
                              // 班级信息
                              Demo03GradeForm(
                                grade: _grade,
                                onChanged: (grade) => _grade = grade,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
}

/// 显示学生表单对话框的便捷方法
void showDemo03FormDialog(
  BuildContext context, {
  Demo03Student? student,
  required WidgetRef ref,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (context) => Demo03FormDialog(
      student: student,
      ref: ref,
      onSuccess: onSuccess,
    ),
  );
}