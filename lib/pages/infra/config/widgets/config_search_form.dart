import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 参数配置搜索表单组件
class ConfigSearchForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController keyController;
  final int? selectedType;
  final DateTimeRange? createTimeRange;
  final void Function(int? type) onTypeChanged;
  final void Function(DateTimeRange?) onCreateTimeRangeChanged;
  final VoidCallback onSearch;
  final VoidCallback onReset;

  const ConfigSearchForm({
    super.key,
    required this.nameController,
    required this.keyController,
    required this.selectedType,
    required this.createTimeRange,
    required this.onTypeChanged,
    required this.onCreateTimeRangeChanged,
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
    double dateFieldWidth = isMobile ? screenWidth - 32 : 280;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Wrap(
        spacing: isMobile ? 8 : 12,
        runSpacing: isMobile ? 12 : 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // 参数名称搜索
          SizedBox(
            width: fieldWidth,
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: S.current.configName,
                prefixIcon: const Icon(Icons.search, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          // 参数键名搜索
          SizedBox(
            width: fieldWidth,
            child: TextField(
              controller: keyController,
              decoration: InputDecoration(
                hintText: S.current.configKey,
                prefixIcon: const Icon(Icons.vpn_key, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          // 系统内置筛选
          SizedBox(
            width: typeFieldWidth,
            child: DropdownButtonFormField<int?>(
              value: selectedType,
              decoration: InputDecoration(
                hintText: S.current.configType,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(S.current.all)),
                DropdownMenuItem(value: 1, child: Text(S.current.systemBuiltIn)),
                DropdownMenuItem(value: 2, child: Text(S.current.custom)),
              ],
              onChanged: onTypeChanged,
            ),
          ),
          // 创建时间范围
          SizedBox(
            width: dateFieldWidth,
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