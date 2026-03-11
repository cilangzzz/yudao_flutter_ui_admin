import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 确认删除对话框
///
/// 通用的删除确认对话框组件，提供统一的删除确认界面
///
/// 使用示例：
/// ```dart
/// final confirmed = await showConfirmDeleteDialog(
///   context: context,
///   message: '确定要删除用户 "张三" 吗？',
/// );
/// if (confirmed == true) {
///   // 执行删除操作
/// }
/// ```
class ConfirmDeleteDialog extends StatelessWidget {
  /// 对话框标题
  final String title;

  /// 提示消息
  final String message;

  /// 取消按钮文本
  final String cancelText;

  /// 确认按钮文本
  final String confirmText;

  const ConfirmDeleteDialog({
    super.key,
    this.title = '',
    required this.message,
    this.cancelText = '',
    this.confirmText = '',
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // 响应式对话框宽度
    final dialogWidth = isMobile
        ? screenWidth * 0.9 // 移动端使用90%宽度
        : (screenWidth * 0.4).clamp(300.0, 400.0); // 桌面端40%宽度，限制在300-400之间

    return AlertDialog(
      title: Text(
        title.isNotEmpty ? title : S.current.confirmDelete,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth / textScaleFactor,
        ),
        child: Text(
          message,
          overflow: TextOverflow.ellipsis,
          maxLines: 5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText.isNotEmpty ? cancelText : S.current.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text(confirmText.isNotEmpty ? confirmText : S.current.delete),
        ),
      ],
      actionsAlignment: MainAxisAlignment.end,
      actionsOverflowAlignment: OverflowBarAlignment.end,
    );
  }
}

/// 显示确认删除对话框
///
/// [context] BuildContext
/// [title] 对话框标题，默认使用国际化的"确认删除"
/// [message] 提示消息
/// [itemName] 要删除的项目名称（可选，会自动拼接引号）
/// [cancelText] 取消按钮文本
/// [confirmText] 确认按钮文本
///
/// 返回 `true` 表示用户确认删除，`false` 或 `null` 表示取消
Future<bool?> showConfirmDeleteDialog({
  required BuildContext context,
  String? title,
  required String message,
  String? itemName,
  String? cancelText,
  String? confirmText,
}) {
  String displayMessage = message;
  if (itemName != null) {
    displayMessage = '$message "$itemName" ?';
  }

  return showDialog<bool>(
    context: context,
    builder: (context) => ConfirmDeleteDialog(
      title: title ?? S.current.confirmDelete,
      message: displayMessage,
      cancelText: cancelText ?? S.current.cancel,
      confirmText: confirmText ?? S.current.delete,
    ),
  );
}

/// 显示确认对话框（通用）
///
/// 用于需要用户确认的操作，不限于删除
///
/// [context] BuildContext
/// [title] 对话框标题
/// [message] 提示消息
/// [cancelText] 取消按钮文本
/// [confirmText] 确认按钮文本
/// [isDestructive] 是否为破坏性操作（如删除），如果是则确认按钮显示为红色
///
/// 返回 `true` 表示用户确认，`false` 或 `null` 表示取消
Future<bool?> showConfirmDialog({
  required BuildContext context,
  String? title,
  required String message,
  String? cancelText,
  String? confirmText,
  bool isDestructive = false,
}) {
  final isMobile = DeviceUIMode.isMobile(context);
  final screenWidth = MediaQuery.of(context).size.width;
  final textScaleFactor = MediaQuery.of(context).textScaleFactor;

  // 响应式对话框宽度
  final dialogWidth = isMobile
      ? screenWidth * 0.9
      : (screenWidth * 0.4).clamp(300.0, 400.0);

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        title ?? S.current.confirm,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth / textScaleFactor,
        ),
        child: Text(
          message,
          overflow: TextOverflow.ellipsis,
          maxLines: 5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText ?? S.current.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: isDestructive
              ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
              : null,
          child: Text(confirmText ?? S.current.confirm),
        ),
      ],
      actionsAlignment: MainAxisAlignment.end,
      actionsOverflowAlignment: OverflowBarAlignment.end,
    ),
  );
}

/// 批量删除确认对话框
///
/// 用于批量删除操作的确认
class BatchDeleteDialog extends StatelessWidget {
  /// 删除数量
  final int count;

  /// 自定义消息（可选）
  final String? customMessage;

  const BatchDeleteDialog({
    super.key,
    required this.count,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // 响应式对话框宽度
    final dialogWidth = isMobile
        ? screenWidth * 0.9
        : (screenWidth * 0.4).clamp(300.0, 400.0);

    return AlertDialog(
      title: Text(
        S.current.confirmDelete,
        overflow: TextOverflow.ellipsis,
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth / textScaleFactor,
        ),
        child: Text(
          customMessage ?? '${S.current.confirmDeleteSelected} ($count) ?',
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(S.current.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text(S.current.delete),
        ),
      ],
      actionsAlignment: MainAxisAlignment.end,
      actionsOverflowAlignment: OverflowBarAlignment.end,
    );
  }
}

/// 显示批量删除确认对话框
Future<bool?> showBatchDeleteDialog({
  required BuildContext context,
  required int count,
  String? customMessage,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => BatchDeleteDialog(
      count: count,
      customMessage: customMessage,
    ),
  );
}