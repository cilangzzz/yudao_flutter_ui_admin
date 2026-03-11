import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 学生搜索表单组件
class Demo03SearchForm extends StatelessWidget {
  final TextEditingController nameController;
  final int? selectedSex;
  final void Function(int? sex) onSexChanged;
  final VoidCallback onSearch;
  final VoidCallback onReset;

  const Demo03SearchForm({
    super.key,
    required this.nameController,
    required this.selectedSex,
    required this.onSexChanged,
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