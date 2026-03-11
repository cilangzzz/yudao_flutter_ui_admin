import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/models/system/user.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 用户操作按钮组件
class UserActionButtons extends StatelessWidget {
  final User user;
  final void Function(User) onEdit;
  final Future<void> Function(User) onDelete;
  final void Function(User) onResetPassword;
  final void Function(User) onAssignRole;

  const UserActionButtons({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
    required this.onResetPassword,
    required this.onAssignRole,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => onEdit(user),
          child: Text(S.current.edit),
        ),
        PopupMenuButton<String>(
          tooltip: S.current.more,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'resetPassword',
              child: Row(
                children: [
                  const Icon(Icons.lock_reset, size: 18),
                  const SizedBox(width: 8),
                  Text(S.current.resetPassword),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'assignRole',
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings, size: 18),
                  const SizedBox(width: 8),
                  Text(S.current.assignRole),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(S.current.delete, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'resetPassword':
                onResetPassword(user);
                break;
              case 'assignRole':
                onAssignRole(user);
                break;
              case 'delete':
                onDelete(user);
                break;
            }
          },
        ),
      ],
    );
  }
}