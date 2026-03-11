import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 示例联系人搜索表单组件
class Demo01SearchForm extends StatelessWidget {
  final TextEditingController nameController;
  final int? selectedSex;
  final DateTimeRange? createTimeRange;
  final void Function(int? sex) onSexChanged;
  final void Function(DateTimeRange?) onCreateTimeRangeChanged;
  final VoidCallback onSearch;
  final VoidCallback onReset;

  const Demo01SearchForm({
    super.key,
    required this.nameController,
    required this.selectedSex,
    required this.createTimeRange,
    required this.onSexChanged,
    required this.onCreateTimeRangeChanged,
    required this.onSearch,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // 名字搜索
          SizedBox(
            width: 220,
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: S.current.name,
                prefixIcon: const Icon(Icons.search, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          // 性别筛选
          SizedBox(
            width: 160,
            child: DropdownButtonFormField<int?>(
              value: selectedSex,
              decoration: InputDecoration(
                hintText: S.current.sex,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(S.current.all)),
                DropdownMenuItem(value: 1, child: Text(S.current.male)),
                DropdownMenuItem(value: 2, child: Text(S.current.female)),
              ],
              onChanged: onSexChanged,
            ),
          ),
          // 创建时间范围
          SizedBox(
            width: 280,
            child: InkWell(
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: createTimeRange,
                );
                onCreateTimeRangeChanged(range);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  hintText: S.current.createTime,
                  prefixIcon: const Icon(Icons.date_range, size: 20),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                child: Text(
                  createTimeRange != null
                      ? '${createTimeRange!.start.toString().substring(0, 10)} ~ ${createTimeRange!.end.toString().substring(0, 10)}'
                      : '',
                  style: TextStyle(
                    color: createTimeRange != null ? null : Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
          ),
          // 搜索按钮
          ElevatedButton.icon(
            onPressed: onSearch,
            icon: const Icon(Icons.search, size: 20),
            label: Text(S.current.search),
          ),
          // 重置按钮
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh, size: 20),
            label: Text(S.current.reset),
          ),
        ],
      ),
    );
  }
}