import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 部门搜索表单组件
class DeptSearchForm extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearch;
  final VoidCallback onReset;

  const DeptSearchForm({
    super.key,
    required this.searchController,
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
          SizedBox(
            width: 220,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: S.current.searchDeptName,
                prefixIcon: const Icon(Icons.search, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          ElevatedButton.icon(
            onPressed: onSearch,
            icon: const Icon(Icons.search, size: 20),
            label: Text(S.current.search),
          ),
          OutlinedButton.icon(
            onPressed: () {
              searchController.clear();
              onReset();
            },
            icon: const Icon(Icons.refresh, size: 20),
            label: Text(S.current.reset),
          ),
        ],
      ),
    );
  }
}