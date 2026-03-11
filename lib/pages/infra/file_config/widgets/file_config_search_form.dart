import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/models/infra/file_config.dart';
import 'package:yudao_flutter_ui_admin/pages/system/common/widgets/date_range_picker.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 文件配置搜索表单组件
class FileConfigSearchForm extends StatelessWidget {
  final TextEditingController nameController;
  final int? selectedStorage;
  final void Function(int?) onStorageChanged;
  final DateTimeRange? dateRange;
  final void Function(DateTimeRange?) onDateRangeChanged;
  final VoidCallback onSearch;
  final VoidCallback onReset;

  const FileConfigSearchForm({
    super.key,
    required this.nameController,
    required this.selectedStorage,
    required this.onStorageChanged,
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
    double typeFieldWidth = isMobile ? screenWidth - 32 : 160;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Wrap(
        spacing: isMobile ? 8 : 12,
        runSpacing: isMobile ? 12 : 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // 配置名搜索
          SizedBox(
            width: fieldWidth,
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: S.current.configName,
                prefixIcon: const Icon(Icons.settings, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          // 存储器筛选
          SizedBox(
            width: typeFieldWidth,
            child: DropdownButtonFormField<int?>(
              value: selectedStorage,
              decoration: InputDecoration(
                hintText: S.current.storage,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(S.current.all)),
                ...StorageType.values.map((type) => DropdownMenuItem(
                  value: type.value,
                  child: Text(type.label),
                )),
              ],
              onChanged: onStorageChanged,
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