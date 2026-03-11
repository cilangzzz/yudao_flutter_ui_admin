import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import '../../system/common/widgets/date_range_picker.dart';

/// 文件搜索表单组件
class FileSearchForm extends StatelessWidget {
  final TextEditingController pathController;
  final TextEditingController typeController;
  final DateTimeRange? dateRange;
  final void Function(DateTimeRange?) onDateRangeChanged;
  final VoidCallback onSearch;
  final VoidCallback onReset;

  const FileSearchForm({
    super.key,
    required this.pathController,
    required this.typeController,
    required this.dateRange,
    required this.onDateRangeChanged,
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
          // 文件路径搜索
          SizedBox(
            width: 220,
            child: TextField(
              controller: pathController,
              decoration: InputDecoration(
                hintText: S.current.filePath,
                prefixIcon: const Icon(Icons.folder, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          // 文件类型搜索
          SizedBox(
            width: 180,
            child: TextField(
              controller: typeController,
              decoration: InputDecoration(
                hintText: S.current.fileType,
                prefixIcon: const Icon(Icons.description, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          // 创建时间范围
          DateRangePicker(
            initialDateRange: dateRange,
            onDateRangeChanged: onDateRangeChanged,
            hintText: S.current.createTime,
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