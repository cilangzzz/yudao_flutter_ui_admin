import 'package:flutter/material.dart';
import '../../../i18n/i18n.dart';

/// 代码生成搜索表单组件
class CodegenSearchForm extends StatelessWidget {
  final TextEditingController tableNameController;
  final TextEditingController tableCommentController;
  final VoidCallback onSearch;
  final VoidCallback onReset;

  const CodegenSearchForm({
    super.key,
    required this.tableNameController,
    required this.tableCommentController,
    required this.onSearch,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: tableNameController,
              decoration: InputDecoration(
                labelText: S.current.tableName,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: tableCommentController,
              decoration: InputDecoration(
                labelText: S.current.tableComment,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: onSearch,
            icon: const Icon(Icons.search),
            label: Text(S.current.search),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh),
            label: Text(S.current.reset),
          ),
        ],
      ),
    );
  }
}