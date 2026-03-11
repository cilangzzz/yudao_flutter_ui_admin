import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/pages/system/common/widgets/date_range_picker.dart';

/// API 访问日志搜索表单组件
class ApiAccessLogSearchForm extends StatelessWidget {
  final TextEditingController userIdController;
  final TextEditingController applicationNameController;
  final TextEditingController durationController;
  final TextEditingController resultCodeController;
  final int? selectedUserType;
  final DateTimeRange? dateRange;
  final void Function(int? userType) onUserTypeChanged;
  final void Function(DateTimeRange?) onDateRangeChanged;
  final VoidCallback onSearch;
  final VoidCallback onReset;

  const ApiAccessLogSearchForm({
    super.key,
    required this.userIdController,
    required this.applicationNameController,
    required this.durationController,
    required this.resultCodeController,
    required this.selectedUserType,
    required this.dateRange,
    required this.onUserTypeChanged,
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
          // 用户编号搜索
          SizedBox(
            width: 180,
            child: TextField(
              controller: userIdController,
              decoration: InputDecoration(
                hintText: S.current.userId,
                prefixIcon: const Icon(Icons.person, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          // 用户类型筛选
          SizedBox(
            width: 160,
            child: DropdownButtonFormField<int?>(
              value: selectedUserType,
              decoration: InputDecoration(
                hintText: S.current.userType,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(S.current.all)),
                const DropdownMenuItem(value: 1, child: Text('Admin')),
                const DropdownMenuItem(value: 2, child: Text('Member')),
              ],
              onChanged: onUserTypeChanged,
            ),
          ),
          // 应用名搜索
          SizedBox(
            width: 180,
            child: TextField(
              controller: applicationNameController,
              decoration: InputDecoration(
                hintText: S.current.applicationName,
                prefixIcon: const Icon(Icons.apps, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          // 请求时间范围选择
          DateRangePicker(
            dateRange: dateRange,
            hintText: S.current.requestTime,
            onChanged: onDateRangeChanged,
          ),
          // 执行时长搜索
          SizedBox(
            width: 160,
            child: TextField(
              controller: durationController,
              decoration: InputDecoration(
                hintText: S.current.duration,
                prefixIcon: const Icon(Icons.timer, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (_) => onSearch(),
            ),
          ),
          // 结果码搜索
          SizedBox(
            width: 160,
            child: TextField(
              controller: resultCodeController,
              decoration: InputDecoration(
                hintText: S.current.resultCode,
                prefixIcon: const Icon(Icons.code, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (_) => onSearch(),
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