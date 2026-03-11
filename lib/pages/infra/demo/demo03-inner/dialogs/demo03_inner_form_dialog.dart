import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/infra/demo03_student_inner_api.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo03_student.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 学生表单对话框 - Inner模式（不包含子表，子表在展开行中显示）
class Demo03InnerFormDialog extends StatefulWidget {
  final Demo03Student? student;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const Demo03InnerFormDialog({
    super.key,
    this.student,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<Demo03InnerFormDialog> createState() => _Demo03InnerFormDialogState();
}

class _Demo03InnerFormDialogState extends State<Demo03InnerFormDialog> {
  late final TextEditingController _nameController;
  late int _sex;
  DateTime? _birthday;
  late final TextEditingController _descriptionController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _sex = widget.student?.sex ?? 1;
    if (widget.student?.birthday != null) {
      _birthday = DateTime.fromMillisecondsSinceEpoch(widget.student!.birthday!);
    }
    _descriptionController = TextEditingController(text: widget.student?.description ?? '');

    // 如果是编辑模式，加载完整数据
    if (widget.student?.id != null) {
      _loadStudentDetail();
    }
  }

  Future<void> _loadStudentDetail() async {
    setState(() => _isLoading = true);
    try {
      final studentApi = widget.ref.read(demo03StudentInnerApiProvider);
      final response = await studentApi.getDemo03Student(widget.student!.id!);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _nameController.text = response.data!.name;
          _sex = response.data!.sex;
          if (response.data!.birthday != null) {
            _birthday = DateTime.fromMillisecondsSinceEpoch(response.data!.birthday!);
          }
          _descriptionController.text = response.data!.description ?? '';
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
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

    final studentData = Demo03Student(
      id: widget.student?.id,
      name: _nameController.text,
      sex: _sex,
      birthday: _birthday?.millisecondsSinceEpoch,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
    );

    try {
      final studentApi = widget.ref.read(demo03StudentInnerApiProvider);
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
        width: 500,
        child: _isLoading
          ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
          : Column(
              mainAxisSize: MainAxisSize.min,
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

/// 显示学生表单对话框的便捷方法 - Inner模式
void showDemo03InnerFormDialog(
  BuildContext context, {
  Demo03Student? student,
  required WidgetRef ref,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (context) => Demo03InnerFormDialog(
      student: student,
      ref: ref,
      onSuccess: onSuccess,
    ),
  );
}