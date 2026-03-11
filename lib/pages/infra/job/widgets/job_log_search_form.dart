import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 任务日志搜索表单组件
class JobLogSearchForm extends StatelessWidget {
  final TextEditingController handlerNameController;
  final int? selectedStatus;
  final void Function(int? status) onStatusChanged;
  final VoidCallback onSearch;
  final VoidCallback onReset;

  const JobLogSearchForm({
    super.key,
    required this.handlerNameController,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onSearch,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);
    final screenWidth = DeviceUIMode.widthOf(context);

    // 响应式字段宽度
    double fieldWidth = isMobile ? screenWidth - 32 : 220;
    double statusFieldWidth = isMobile ? screenWidth - 32 : 160;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Wrap(
        spacing: isMobile ? 8 : 12,
        runSpacing: isMobile ? 12 : 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // 处理器名称搜索
          SizedBox(
            width: fieldWidth,
            child: TextField(
              controller: handlerNameController,
              decoration: InputDecoration(
                hintText: S.current.handlerName,
                prefixIcon: const Icon(Icons.search, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          // 状态筛选
          SizedBox(
            width: statusFieldWidth,
            child: DropdownButtonFormField<int?>(
              value: selectedStatus,
              decoration: InputDecoration(
                hintText: S.current.status,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(S.current.all)),
                DropdownMenuItem(value: 0, child: Text(S.current.jobLogStatusSuccess)),
                DropdownMenuItem(value: 1, child: Text(S.current.jobLogStatusFailure)),
              ],
              onChanged: onStatusChanged,
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