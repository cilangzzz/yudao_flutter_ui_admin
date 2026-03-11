import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 角色搜索表单组件
class RoleSearchForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController codeController;
  final int? selectedStatus;
  final void Function(int? status) onStatusChanged;
  final VoidCallback onSearch;
  final VoidCallback onReset;

  const RoleSearchForm({
    super.key,
    required this.nameController,
    required this.codeController,
    required this.selectedStatus,
    required this.onStatusChanged,
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
          SizedBox(
            width: 220,
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: S.current.roleName,
                prefixIcon: const Icon(Icons.search, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          SizedBox(
            width: 220,
            child: TextField(
              controller: codeController,
              decoration: InputDecoration(
                hintText: S.current.roleCode,
                prefixIcon: const Icon(Icons.code, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          SizedBox(
            width: 160,
            child: DropdownButtonFormField<int>(
              value: selectedStatus,
              decoration: InputDecoration(
                hintText: S.current.status,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(S.current.all)),
                DropdownMenuItem(value: 0, child: Text(S.current.enabled)),
                DropdownMenuItem(value: 1, child: Text(S.current.disabled)),
              ],
              onChanged: onStatusChanged,
            ),
          ),
          ElevatedButton.icon(
            onPressed: onSearch,
            icon: const Icon(Icons.search, size: 20),
            label: Text(S.current.search),
          ),
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