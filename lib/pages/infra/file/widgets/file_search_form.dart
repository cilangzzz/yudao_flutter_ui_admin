import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/pages/system/common/widgets/date_range_picker.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

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
    final isMobile = DeviceUIMode.isMobile(context);
    final screenWidth = DeviceUIMode.widthOf(context);

    // 响应式字段宽度
    double fieldWidth = isMobile ? screenWidth - 32 : 220;
    double typeFieldWidth = isMobile ? screenWidth - 32 : 180;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Wrap(
        spacing: isMobile ? 8 : 12,
        runSpacing: isMobile ? 12 : 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // 文件路径搜索
          SizedBox(
            width: fieldWidth,
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
            width: typeFieldWidth,
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