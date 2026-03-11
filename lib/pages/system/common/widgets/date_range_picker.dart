import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

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

  /// 输入框宽度（桌面端）
  final double? width;

  /// 是否使用响应式宽度（默认true）
  final bool responsive;

  const DateRangePicker({
    super.key,
    this.initialDateRange,
    required this.onDateRangeChanged,
    this.hintText,
    this.firstDate,
    this.lastDate,
    this.width,
    this.responsive = true,
  });

  /// 获取响应式宽度
  double _getWidth(BuildContext context) {
    if (!responsive && width != null) {
      return width!;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = DeviceUIMode.isMobile(context);

    if (isMobile) {
      // 移动端使用父容器宽度或屏幕宽度的90%
      return screenWidth * 0.9;
    }

    // 桌面端/平板端：使用指定宽度或默认280
    return (width ?? 280.0).clamp(200.0, screenWidth * 0.4);
  }

  @override
  Widget build(BuildContext context) {
    final pickerWidth = _getWidth(context);
    final isMobile = DeviceUIMode.isMobile(context);
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 如果父容器宽度小于计算宽度，使用父容器宽度
        final actualWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth.clamp(200.0, pickerWidth)
            : pickerWidth;

        return SizedBox(
          width: actualWidth,
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
                prefixIcon: Icon(
                  Icons.date_range,
                  size: isMobile ? 18 : 20,
                ),
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: isMobile ? 8 : 12,
                ),
                suffixIcon: initialDateRange != null
                    ? IconButton(
                        icon: Icon(Icons.clear, size: isMobile ? 16 : 18),
                        onPressed: () => onDateRangeChanged(null),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      )
                    : null,
              ),
              child: Text(
                initialDateRange != null
                    ? '${DateFormat('yyyy-MM-dd').format(initialDateRange!.start)} ~ ${DateFormat('yyyy-MM-dd').format(initialDateRange!.end)}'
                    : '',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 响应式日期范围选择器行
///
/// 包含多个日期选择器的行，自动换行适应移动端
class ResponsiveDateRangeRow extends StatelessWidget {
  /// 日期选择器列表
  final List<Widget> children;

  /// 间距
  final double spacing;

  /// 移动端是否换行
  final bool wrapOnMobile;

  const ResponsiveDateRangeRow({
    super.key,
    required this.children,
    this.spacing = 16,
    this.wrapOnMobile = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);

    if (isMobile && wrapOnMobile) {
      return Wrap(
        spacing: spacing,
        runSpacing: 12,
        children: children,
      );
    }

    return Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) SizedBox(width: spacing),
        ],
      ],
    );
  }
}