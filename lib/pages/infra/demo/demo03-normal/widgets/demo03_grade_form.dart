import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo03_student.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 学生班级子表组件
class Demo03GradeForm extends StatefulWidget {
  final Demo03Grade? grade;
  final Function(Demo03Grade) onChanged;
  final bool enabled;

  const Demo03GradeForm({
    super.key,
    this.grade,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<Demo03GradeForm> createState() => _Demo03GradeFormState();
}

class _Demo03GradeFormState extends State<Demo03GradeForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _teacherController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.grade?.name ?? '');
    _teacherController = TextEditingController(text: widget.grade?.teacher ?? '');

    _nameController.addListener(_onChanged);
    _teacherController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onChanged);
    _teacherController.removeListener(_onChanged);
    _nameController.dispose();
    _teacherController.dispose();
    super.dispose();
  }

  void _onChanged() {
    widget.onChanged(Demo03Grade(
      id: widget.grade?.id,
      studentId: widget.grade?.studentId,
      name: _nameController.text,
      teacher: _teacherController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.current.gradeInfo, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nameController,
                enabled: widget.enabled,
                decoration: InputDecoration(
                  labelText: '${S.current.gradeName} *',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _teacherController,
                enabled: widget.enabled,
                decoration: InputDecoration(
                  labelText: '${S.current.teacher} *',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}