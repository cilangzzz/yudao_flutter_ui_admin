import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 日期范围选择器组件
///
/// 用于选择日期范围的通用组件，包含：
/// - 日期范围选择对话框
/// - 已选择日期范围的显示
/// - 清除按钮
///
/// 使用示例：
/// ```dart
/// DateRangePicker(
///   initialDateRange: _dateRange,
///   onDateRangeChanged: (range) {
///     setState(() => _dateRange = range);
///   },
/// )
/// ```
class DateRangePicker extends StatelessWidget {
  /// 初始日期范围
  final DateTimeRange? initialDateRange;

  /// 日期范围改变回调
  final void Function(DateTimeRange?) onDateRangeChanged;

  /// 提示文本
  final String? hintText;

  /// 最早可选日期
  final DateTime? firstDate;

  /// 最晚可选日期
  final DateTime? lastDate;

  /// 输入框宽度
  final double width;

  const DateRangePicker({
    super.key,
    this.initialDateRange,
    required this.onDateRangeChanged,
    this.hintText,
    this.firstDate,
    this.lastDate,
    this.width = 280,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: () async {
          final now = DateTime.now();
          final defaultFirstDate = DateTime(now.year - 10, 1, 1);
          final defaultLastDate = DateTime(now.year + 10, 12, 31);
          final range = await showDateRangePicker(
            context: context,
            firstDate: firstDate ?? defaultFirstDate,
            lastDate: lastDate ?? defaultLastDate,
            initialDateRange: initialDateRange,
          );
          if (range != null) {
            onDateRangeChanged(range);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            hintText: hintText ?? S.current.common_selectTimeRange,
            prefixIcon: const Icon(Icons.date_range, size: 20),
            border: const OutlineInputBorder(),
            isDense: true,
            suffixIcon: initialDateRange != null
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => onDateRangeChanged(null),
                  )
                : null,
          ),
          child: Text(
            initialDateRange != null
                ? '${DateFormat('yyyy-MM-dd').format(initialDateRange!.start)} ~ ${DateFormat('yyyy-MM-dd').format(initialDateRange!.end)}'
                : '',
          ),
        ),
      ),
    );
  }
}