import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/models/system/user.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/api/system/user_api.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 重置密码对话框
class ResetPasswordDialog extends StatefulWidget {
  final User user;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const ResetPasswordDialog({
    super.key,
    required this.user,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.passwordRequired)),
      );
      return;
    }

    try {
      final userApi = widget.ref.read(userApiProvider);
      final response = await userApi.resetUserPassword(widget.user.id!, _passwordController.text);

      if (response.isSuccess) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.current.operationSuccess)),
          );
          widget.onSuccess();
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.operationFailed)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.operationFailed}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.current.resetPassword),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${S.current.username}: ${widget.user.username}'),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '${S.current.newPassword} *',
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.current.cancel),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: Text(S.current.confirm),
        ),
      ],
    );
  }
}

/// 显示重置密码对话框
void showResetPasswordDialog({
  required BuildContext context,
  required User user,
  required WidgetRef ref,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (context) => ResetPasswordDialog(
      user: user,
      ref: ref,
      onSuccess: onSuccess,
    ),
  );
}