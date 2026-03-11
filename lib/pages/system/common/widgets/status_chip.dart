import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 通用状态标签组件
///
/// 用于显示启用/禁用状态或其他状态标签
///
/// 使用示例：
/// ```dart
/// // 启用/禁用状态
/// StatusChip.enabled(isEnabled: user.status == 0)
///
/// // 自定义状态
/// StatusChip(
///   label: '自定义',
///   color: Colors.purple,
/// )
/// ```
class StatusChip extends StatelessWidget {
  /// 显示的文本
  final String label;

  /// 背景颜色
  final Color color;

  /// 文字颜色（可选，默认根据背景色自动计算）
  final Color? textColor;

  /// 字体大小
  final double fontSize;

  /// 内边距
  final EdgeInsetsGeometry padding;

  /// 边框圆角
  final BorderRadius borderRadius;

  /// 最大宽度限制
  final double? maxWidth;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.maxWidth,
  });

  /// 创建启用/禁用状态标签
  ///
  /// [isEnabled] 是否启用
  /// [enabledText] 启用时显示的文本，默认使用国际化文本
  /// [disabledText] 禁用时显示的文本，默认使用国际化文本
  /// [enabledColor] 启用状态的颜色，默认绿色
  /// [disabledColor] 禁用状态的颜色，默认红色
  factory StatusChip.enabled({
    Key? key,
    required bool isEnabled,
    String? enabledText,
    String? disabledText,
    Color? enabledColor,
    Color? disabledColor,
    double fontSize = 12,
    double? maxWidth,
  }) {
    final color = isEnabled ? (enabledColor ?? Colors.green) : (disabledColor ?? Colors.red);
    return StatusChip(
      key: key,
      label: isEnabled ? (enabledText ?? S.current.enabled) : (disabledText ?? S.current.disabled),
      color: color,
      fontSize: fontSize,
      maxWidth: maxWidth,
    );
  }

  /// 创建成功状态标签
  factory StatusChip.success({
    Key? key,
    String? label,
    double fontSize = 12,
    double? maxWidth,
  }) {
    return StatusChip(
      key: key,
      label: label ?? S.current.success,
      color: Colors.green,
      fontSize: fontSize,
      maxWidth: maxWidth,
    );
  }

  /// 创建失败状态标签
  factory StatusChip.failure({
    Key? key,
    String? label,
    double fontSize = 12,
    double? maxWidth,
  }) {
    return StatusChip(
      key: key,
      label: label ?? S.current.failed,
      color: Colors.red,
      fontSize: fontSize,
      maxWidth: maxWidth,
    );
  }

  /// 创建警告状态标签
  factory StatusChip.warning({
    Key? key,
    required String label,
    double fontSize = 12,
    double? maxWidth,
  }) {
    return StatusChip(
      key: key,
      label: label,
      color: Colors.orange,
      fontSize: fontSize,
      maxWidth: maxWidth,
    );
  }

  /// 创建信息状态标签
  factory StatusChip.info({
    Key? key,
    required String label,
    double fontSize = 12,
    double? maxWidth,
  }) {
    return StatusChip(
      key: key,
      label: label,
      color: Colors.blue,
      fontSize: fontSize,
      maxWidth: maxWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);
    final actualFontSize = isMobile ? fontSize * 0.9 : fontSize;
    final actualMaxWidth = maxWidth ?? (isMobile ? 80.0 : 120.0);

    return Container(
      constraints: BoxConstraints(
        maxWidth: actualMaxWidth,
      ),
      padding: isMobile
          ? EdgeInsets.symmetric(horizontal: 6, vertical: 3)
          : padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: borderRadius,
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor ?? color,
          fontSize: actualFontSize,
        ),
      ),
    );
  }
}

/// 预定义的状态类型
enum StatusType {
  /// 启用/成功
  enabled,

  /// 禁用/失败
  disabled,

  /// 警告
  warning,

  /// 信息
  info,

  /// 自定义
  custom,
}

/// 扩展的 StatusChip，支持更多状态类型
class TypedStatusChip extends StatelessWidget {
  /// 状态类型
  final StatusType type;

  /// 显示的文本
  final String label;

  /// 自定义颜色（仅当 type 为 StatusType.custom 时有效）
  final Color? customColor;

  /// 字体大小
  final double fontSize;

  /// 最大宽度限制
  final double? maxWidth;

  const TypedStatusChip({
    super.key,
    required this.type,
    required this.label,
    this.customColor,
    this.fontSize = 12,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case StatusType.enabled:
        color = Colors.green;
        break;
      case StatusType.disabled:
        color = Colors.red;
        break;
      case StatusType.warning:
        color = Colors.orange;
        break;
      case StatusType.info:
        color = Colors.blue;
        break;
      case StatusType.custom:
        color = customColor ?? Colors.grey;
        break;
    }

    return StatusChip(
      label: label,
      color: color,
      fontSize: fontSize,
      maxWidth: maxWidth,
    );
  }
}

/// 响应式状态标签
///
/// 根据屏幕宽度自动调整大小
class ResponsiveStatusChip extends StatelessWidget {
  /// 显示的文本
  final String label;

  /// 背景颜色
  final Color color;

  /// 文字颜色（可选）
  final Color? textColor;

  /// 桌面端字体大小
  final double desktopFontSize;

  /// 移动端字体大小
  final double mobileFontSize;

  /// 桌面端内边距
  final EdgeInsetsGeometry desktopPadding;

  /// 移动端内边距
  final EdgeInsetsGeometry mobilePadding;

  /// 边框圆角
  final BorderRadius borderRadius;

  const ResponsiveStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.desktopFontSize = 12,
    this.mobileFontSize = 10,
    this.desktopPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.mobilePadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);

    return Container(
      constraints: BoxConstraints(
        maxWidth: isMobile ? 80.0 : 120.0,
      ),
      padding: isMobile ? mobilePadding : desktopPadding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: borderRadius,
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor ?? color,
          fontSize: isMobile ? mobileFontSize : desktopFontSize,
        ),
      ),
    );
  }
}