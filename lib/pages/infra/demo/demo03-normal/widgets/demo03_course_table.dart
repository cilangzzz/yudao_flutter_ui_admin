import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo03_student.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 学生课程子表组件
class Demo03CourseTable extends StatefulWidget {
  final List<Demo03Course>? courses;
  final Function(List<Demo03Course>) onChanged;
  final bool enabled;

  const Demo03CourseTable({
    super.key,
    this.courses,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<Demo03CourseTable> createState() => _Demo03CourseTableState();
}

class _Demo03CourseTableState extends State<Demo03CourseTable> {
  late List<Demo03Course> _courses;

  @override
  void initState() {
    super.initState();
    _courses = List.from(widget.courses ?? []);
  }

  void _addCourse() {
    setState(() {
      _courses.add(Demo03Course(name: '', score: 0));
    });
    widget.onChanged(_courses);
  }

  void _removeCourse(int index) {
    setState(() {
      _courses.removeAt(index);
    });
    widget.onChanged(_courses);
  }

  void _updateCourse(int index, {String? name, int? score}) {
    setState(() {
      _courses[index] = _courses[index].copyWith(
        name: name,
        score: score,
      );
    });
    widget.onChanged(_courses);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(S.current.courseList, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (widget.enabled)
              TextButton.icon(
                onPressed: _addCourse,
                icon: const Icon(Icons.add, size: 18),
                label: Text(S.current.add),
              ),
          ],
        ),
        const SizedBox(height: 8),
        DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 400,
          headingRowColor: WidgetStateProperty.resolveWith(
            (states) => Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          columns: [
            DataColumn2(label: Text(S.current.courseName), size: ColumnSize.L),
            DataColumn2(label: Text(S.current.score), size: ColumnSize.M),
            if (widget.enabled)
              DataColumn2(label: Text(S.current.operation), size: ColumnSize.S),
          ],
          rows: _courses.asMap().entries.map((entry) {
            final index = entry.key;
            final course = entry.value;
            return DataRow2(
              cells: [
                DataCell(widget.enabled
                  ? TextField(
                      controller: TextEditingController(text: course.name),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (value) => _updateCourse(index, name: value),
                    )
                  : Text(course.name)),
                DataCell(widget.enabled
                  ? TextField(
                      controller: TextEditingController(text: course.score.toString()),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _updateCourse(index, score: int.tryParse(value) ?? 0),
                    )
                  : Text(course.score.toString())),
                if (widget.enabled)
                  DataCell(IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeCourse(index),
                  )),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}