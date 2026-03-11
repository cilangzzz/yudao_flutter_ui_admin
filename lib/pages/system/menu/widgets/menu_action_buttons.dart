import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/models/system/menu.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 菜单操作按钮组件
class MenuActionButtons extends StatelessWidget {
  /// 菜单数据
  final Menu menu;

  /// 编辑回调
  final void Function(Menu menu) onEdit;

  /// 添加子菜单回调
  final void Function(int parentId) onAddChild;

  /// 删除回调
  final void Function(Menu menu) onDelete;

  const MenuActionButtons({
    super.key,
    required this.menu,
    required this.onEdit,
    required this.onAddChild,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => onEdit(menu),
          child: Text(S.current.edit),
        ),
        PopupMenuButton<String>(
          tooltip: S.current.more,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'add_child',
              child: Row(
                children: [
                  const Icon(Icons.add, size: 18),
                  const SizedBox(width: 8),
                  Text(S.current.addChild),
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
              case 'add_child':
                if (menu.id != null) {
                  onAddChild(menu.id!);
                }
                break;
              case 'delete':
                onDelete(menu);
                break;
            }
          },
        ),
      ],
    );
  }
}