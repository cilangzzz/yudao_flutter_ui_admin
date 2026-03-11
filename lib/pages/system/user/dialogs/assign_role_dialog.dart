import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/models/system/user.dart';
import 'package:yudao_flutter_ui_admin/models/system/role.dart';
import 'package:yudao_flutter_ui_admin/models/system/permission.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/api/system/permission_api.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 分配角色对话框
class AssignRoleDialog extends StatefulWidget {
  final User user;
  final List<Role> roleList;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const AssignRoleDialog({
    super.key,
    required this.user,
    required this.roleList,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<AssignRoleDialog> createState() => _AssignRoleDialogState();
}

class _AssignRoleDialogState extends State<AssignRoleDialog> {
  List<int> _selectedRoleIds = [];

  @override
  void initState() {
    super.initState();
    // 可在此处加载用户当前角色
  }

  Future<void> _handleSubmit() async {
    try {
      final permissionApi = widget.ref.read(permissionApiProvider);
      final response = await permissionApi.assignUserRole(
        AssignUserRoleReq(userId: widget.user.id!, roleIds: _selectedRoleIds),
      );

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
      title: Text(S.current.assignRole),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${S.current.username}: ${widget.user.username}'),
            const SizedBox(height: 8),
            Text('${S.current.nickname}: ${widget.user.nickname}'),
            const SizedBox(height: 16),
            Text(S.current.role, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.roleList.map((role) {
                final isSelected = _selectedRoleIds.contains(role.id);
                return FilterChip(
                  label: Text(role.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedRoleIds.add(role.id!);
                      } else {
                        _selectedRoleIds.remove(role.id);
                      }
                    });
                  },
                );
              }).toList(),
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

/// 显示分配角色对话框
void showAssignRoleDialog({
  required BuildContext context,
  required User user,
  required List<Role> roleList,
  required WidgetRef ref,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (context) => AssignRoleDialog(
      user: user,
      roleList: roleList,
      ref: ref,
      onSuccess: onSuccess,
    ),
  );
}