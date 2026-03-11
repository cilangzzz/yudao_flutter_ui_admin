import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/models/system/user.dart';
import 'package:yudao_flutter_ui_admin/models/system/dept.dart';
import 'package:yudao_flutter_ui_admin/models/system/post.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/api/system/user_api.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 用户编辑对话框
class UserEditDialog extends StatefulWidget {
  final User? user;
  final List<Dept> deptTree;
  final List<Post> postList;
  final int? defaultDeptId;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const UserEditDialog({
    super.key,
    this.user,
    required this.deptTree,
    required this.postList,
    this.defaultDeptId,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog> {
  final _usernameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _remarkController = TextEditingController();

  int? _selectedDeptId;
  List<int> _selectedPostIds = [];
  int _sex = 1;
  int _status = 0;

  @override
  void initState() {
    super.initState();
    _initFormData();
  }

  void _initFormData() {
    final user = widget.user;
    _usernameController.text = user?.username ?? '';
    _nicknameController.text = user?.nickname ?? '';
    _mobileController.text = user?.mobile ?? '';
    _emailController.text = user?.email ?? '';
    _remarkController.text = user?.remark ?? '';
    _selectedDeptId = user?.deptId ?? widget.defaultDeptId;
    _selectedPostIds = user?.postIds ?? [];
    _sex = user?.sex ?? 1;
    _status = user?.status ?? 0;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nicknameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<int?>> _buildDeptDropdownItems(List<Dept> depts, int level) {
    final items = <DropdownMenuItem<int?>>[];
    for (final dept in depts) {
      items.add(DropdownMenuItem(
        value: dept.id,
        child: Padding(
          padding: EdgeInsets.only(left: 16.0 * level),
          child: Text(dept.name),
        ),
      ));
      if (dept.children != null && dept.children!.isNotEmpty) {
        items.addAll(_buildDeptDropdownItems(dept.children!, level + 1));
      }
    }
    return items;
  }

  Future<void> _handleSubmit() async {
    if (_usernameController.text.isEmpty || _nicknameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseFillRequired)),
      );
      return;
    }

    if (widget.user == null && _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.passwordRequired)),
      );
      return;
    }

    final userData = User(
      id: widget.user?.id,
      username: _usernameController.text,
      nickname: _nicknameController.text,
      deptId: _selectedDeptId,
      postIds: _selectedPostIds,
      mobile: _mobileController.text.isEmpty ? null : _mobileController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      sex: _sex,
      status: _status,
      remark: _remarkController.text.isEmpty ? null : _remarkController.text,
    );

    try {
      final userApi = widget.ref.read(userApiProvider);
      ApiResponse<void> response;

      if (widget.user == null) {
        response = await userApi.createUser(userData);
      } else {
        response = await userApi.updateUser(userData);
      }

      if (response.isSuccess) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.user == null ? S.current.addSuccess : S.current.editSuccess)),
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
      title: Text(widget.user == null ? S.current.addUser : S.current.editUser),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: '${S.current.username} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.user == null)
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '${S.current.password} *',
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              if (widget.user == null) const SizedBox(height: 16),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: '${S.current.nickname} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // 部门选择
              DropdownButtonFormField<int?>(
                value: _selectedDeptId,
                decoration: InputDecoration(
                  labelText: S.current.department,
                  border: const OutlineInputBorder(),
                ),
                items: _buildDeptDropdownItems(widget.deptTree, 0),
                onChanged: (value) {
                  setState(() {
                    _selectedDeptId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // 岗位选择
              DropdownButtonFormField<int>(
                value: _selectedPostIds.isNotEmpty ? _selectedPostIds.first : null,
                decoration: InputDecoration(
                  labelText: S.current.post,
                  border: const OutlineInputBorder(),
                ),
                items: widget.postList.map((post) => DropdownMenuItem(
                  value: post.id,
                  child: Text(post.name),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPostIds = value != null ? [value] : [];
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _mobileController,
                decoration: InputDecoration(
                  labelText: S.current.mobile,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: S.current.email,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // 性别
              Row(
                children: [
                  Text('${S.current.sex}: '),
                  Radio<int>(
                    value: 1,
                    groupValue: _sex,
                    onChanged: (value) {
                      setState(() {
                        _sex = value!;
                      });
                    },
                  ),
                  Text(S.current.male),
                  Radio<int>(
                    value: 2,
                    groupValue: _sex,
                    onChanged: (value) {
                      setState(() {
                        _sex = value!;
                      });
                    },
                  ),
                  Text(S.current.female),
                ],
              ),
              const SizedBox(height: 8),
              // 状态
              Row(
                children: [
                  Text('${S.current.status}: '),
                  Radio<int>(
                    value: 0,
                    groupValue: _status,
                    onChanged: (value) {
                      setState(() {
                        _status = value!;
                      });
                    },
                  ),
                  Text(S.current.enabled),
                  Radio<int>(
                    value: 1,
                    groupValue: _status,
                    onChanged: (value) {
                      setState(() {
                        _status = value!;
                      });
                    },
                  ),
                  Text(S.current.disabled),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _remarkController,
                decoration: InputDecoration(
                  labelText: S.current.remark,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
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

/// 显示用户编辑对话框
void showUserEditDialog({
  required BuildContext context,
  User? user,
  required List<Dept> deptTree,
  required List<Post> postList,
  int? defaultDeptId,
  required WidgetRef ref,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (context) => UserEditDialog(
      user: user,
      deptTree: deptTree,
      postList: postList,
      defaultDeptId: defaultDeptId,
      ref: ref,
      onSuccess: onSuccess,
    ),
  );
}