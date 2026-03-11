import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 详情项组件
///
/// 用于在详情对话框或页面中显示键值对信息
///
/// 使用示例：
/// ```dart
/// Column(
///   children: [
///     DetailItem(label: '用户名', value: user.username),
///     DetailItem(label: '昵称', value: user.nickname),
///     DetailItem(label: '状态', value: user.status == 0 ? '启用' : '禁用'),
///   ],
/// )
/// ```
class DetailItem extends StatelessWidget {
  /// 标签文本
  final String label;

  /// 值文本
  final String value;

  /// 标签宽度
  final double labelWidth;

  /// 是否可选中复制
  final bool selectable;

  /// 垂直内边距
  final double verticalPadding;

  /// 标签样式
  final TextStyle? labelStyle;

  /// 值样式
  final TextStyle? valueStyle;

  /// 是否使用响应式布局
  final bool responsive;

  const DetailItem({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 80,
    this.selectable = true,
    this.verticalPadding = 8,
    this.labelStyle,
    this.valueStyle,
    this.responsive = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);
    final actualLabelWidth = responsive && isMobile ? labelWidth * 0.8 : labelWidth;
    final actualVerticalPadding = responsive && isMobile ? verticalPadding * 0.75 : verticalPadding;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: actualVerticalPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 移动端使用垂直布局
          if (responsive && isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$label:',
                  style: labelStyle ??
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth,
                  ),
                  child: selectable
                      ? SelectableText(
                          value,
                          style: valueStyle ?? const TextStyle(fontSize: 13),
                        )
                      : Text(
                          value,
                          style: valueStyle ?? const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                ),
              ],
            );
          }

          // 桌面端使用水平布局
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: actualLabelWidth,
                child: Text(
                  '$label:',
                  style: labelStyle ??
                      const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth - actualLabelWidth - 8,
                  ),
                  child: selectable
                      ? SelectableText(
                          value,
                          style: valueStyle,
                        )
                      : Text(
                          value,
                          style: valueStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 详情项构建器
///
/// 用于在对话框中快速构建详情列表
class DetailItemBuilder {
  /// 标签宽度
  final double labelWidth;

  /// 是否可选中复制
  final bool selectable;

  /// 垂直内边距
  final double verticalPadding;

  /// 标签样式
  final TextStyle? labelStyle;

  /// 值样式
  final TextStyle? valueStyle;

  /// 是否使用响应式布局
  final bool responsive;

  DetailItemBuilder({
    this.labelWidth = 80,
    this.selectable = true,
    this.verticalPadding = 8,
    this.labelStyle,
    this.valueStyle,
    this.responsive = true,
  });

  /// 构建详情项
  Widget build(String label, String value) {
    return DetailItem(
      label: label,
      value: value,
      labelWidth: labelWidth,
      selectable: selectable,
      verticalPadding: verticalPadding,
      labelStyle: labelStyle,
      valueStyle: valueStyle,
      responsive: responsive,
    );
  }

  /// 构建多个详情项
  List<Widget> buildList(List<(String, String)> items) {
    return items.map((item) => build(item.$1, item.$2)).toList();
  }
}

/// 详情列表组件
///
/// 包含多个详情项的列组件
class DetailList extends StatelessWidget {
  /// 详情项列表
  final List<DetailItem> items;

  /// 详情数据列表（键值对）
  final List<(String, String)>? data;

  /// 标签宽度
  final double labelWidth;

  /// 是否可选中复制
  final bool selectable;

  /// 间距
  final double spacing;

  /// 是否使用响应式布局
  final bool responsive;

  const DetailList({
    super.key,
    this.items = const [],
    this.data,
    this.labelWidth = 80,
    this.selectable = true,
    this.spacing = 0,
    this.responsive = true,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    // 添加直接传入的详情项
    children.addAll(items);

    // 添加数据列表转换的详情项
    if (data != null) {
      for (final (label, value) in data!) {
        children.add(DetailItem(
          label: label,
          value: value,
          labelWidth: labelWidth,
          selectable: selectable,
          responsive: responsive,
        ));
      }
    }

    // 如果有间距，添加分隔
    if (spacing > 0 && children.length > 1) {
      final spacedChildren = <Widget>[];
      for (int i = 0; i < children.length; i++) {
        spacedChildren.add(children[i]);
        if (i < children.length - 1) {
          spacedChildren.add(SizedBox(height: spacing));
        }
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: spacedChildren,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

/// 详情对话框
///
/// 预设的详情显示对话框，包含标题、内容列表和关闭按钮
class DetailDialog extends StatelessWidget {
  /// 对话框标题
  final String title;

  /// 详情数据列表
  final List<(String, String)> data;

  /// 详情项组件列表
  final List<Widget>? children;

  /// 对话框宽度（桌面端）
  final double width;

  /// 标签宽度
  final double labelWidth;

  /// 关闭按钮文本
  final String? closeText;

  /// 是否使用响应式布局
  final bool responsive;

  const DetailDialog({
    super.key,
    required this.title,
    this.data = const [],
    this.children,
    this.width = 500,
    this.labelWidth = 80,
    this.closeText,
    this.responsive = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // 响应式对话框宽度
    final dialogWidth = isMobile
        ? screenWidth * 0.9
        : (width).clamp(300.0, screenWidth * 0.6);

    return AlertDialog(
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      content: SizedBox(
        width: dialogWidth / textScaleFactor,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...data.map((item) => DetailItem(
                    label: item.$1,
                    value: item.$2,
                    labelWidth: labelWidth,
                    responsive: responsive,
                  )),
              if (children != null) ...children!,
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(closeText ?? '关闭'),
        ),
      ],
    );
  }
}

/// 显示详情对话框
Future<void> showDetailDialog({
  required BuildContext context,
  required String title,
  required List<(String, String)> data,
  double width = 500,
  double labelWidth = 80,
  List<Widget>? children,
  bool responsive = true,
}) {
  return showDialog(
    context: context,
    builder: (context) => DetailDialog(
      title: title,
      data: data,
      width: width,
      labelWidth: labelWidth,
      children: children,
      responsive: responsive,
    ),
  );
}