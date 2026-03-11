import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/models/system/menu.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/menu_icon_helper.dart';

/// 菜单表单对话框
/// 用于新增/编辑菜单
class MenuFormDialog extends StatefulWidget {
  /// 要编辑的菜单，为 null 时表示新增
  final Menu? menu;

  /// 父菜单ID，用于新增子菜单
  final int? parentId;

  /// 菜单树数据，用于上级菜单下拉选择
  final List<Menu> menuTree;

  /// 菜单创建回调
  final Future<bool> Function(Menu menu) onCreate;

  /// 菜单更新回调
  final Future<bool> Function(Menu menu) onUpdate;

  const MenuFormDialog({
    super.key,
    this.menu,
    this.parentId,
    required this.menuTree,
    required this.onCreate,
    required this.onUpdate,
  });

  @override
  State<MenuFormDialog> createState() => _MenuFormDialogState();
}

class _MenuFormDialogState extends State<MenuFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _pathController;
  late final TextEditingController _componentController;
  late final TextEditingController _componentNameController;
  late final TextEditingController _permissionController;
  late final TextEditingController _iconController;
  late final TextEditingController _sortController;

  int? _selectedParentId;
  late int _menuType;
  late int _status;
  late bool _visible;
  late bool _keepAlive;
  late bool _alwaysShow;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menu?.name ?? '');
    _pathController = TextEditingController(text: widget.menu?.path ?? '');
    _componentController = TextEditingController(text: widget.menu?.component ?? '');
    _componentNameController = TextEditingController(text: widget.menu?.componentName ?? '');
    _permissionController = TextEditingController(text: widget.menu?.permission ?? '');
    _iconController = TextEditingController(text: widget.menu?.icon ?? '');
    _sortController = TextEditingController(text: (widget.menu?.sort ?? 0).toString());

    _selectedParentId = widget.menu?.parentId ?? widget.parentId;
    _menuType = widget.menu?.type ?? 1;
    _status = widget.menu?.status ?? 0;
    _visible = widget.menu?.visible ?? true;
    _keepAlive = widget.menu?.keepAlive ?? false;
    _alwaysShow = widget.menu?.alwaysShow ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pathController.dispose();
    _componentController.dispose();
    _componentNameController.dispose();
    _permissionController.dispose();
    _iconController.dispose();
    _sortController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseFillRequired)),
      );
      return;
    }

    final menuData = Menu(
      id: widget.menu?.id,
      name: _nameController.text,
      parentId: _selectedParentId,
      type: _menuType,
      path: _pathController.text.isEmpty ? null : _pathController.text,
      component: _componentController.text.isEmpty ? null : _componentController.text,
      componentName: _componentNameController.text.isEmpty ? null : _componentNameController.text,
      permission: _permissionController.text.isEmpty ? null : _permissionController.text,
      icon: _iconController.text.isEmpty ? null : _iconController.text,
      sort: int.tryParse(_sortController.text) ?? 0,
      status: _status,
      visible: _visible,
      keepAlive: _keepAlive,
      alwaysShow: _alwaysShow,
    );

    try {
      final success = widget.menu == null
          ? await widget.onCreate(menuData)
          : await widget.onUpdate(menuData);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.menu == null ? S.current.addSuccess : S.current.editSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.operationFailed}: $e')),
        );
      }
    }
  }

  List<DropdownMenuItem<int?>> _buildMenuDropdownItems(List<Menu> menus, int level, [int? excludeId]) {
    final items = <DropdownMenuItem<int?>>[];
    for (final menu in menus) {
      if (menu.id == excludeId) continue;

      items.add(DropdownMenuItem(
        value: menu.id,
        child: Padding(
          padding: EdgeInsets.only(left: 16.0 * level),
          child: Row(
            children: [
              if (menu.icon != null && menu.icon!.isNotEmpty)
                Icon(MenuIconHelper.getIconData(menu.icon), size: 16)
              else
                const Icon(Icons.folder, size: 16),
              const SizedBox(width: 8),
              Text(menu.name),
            ],
          ),
        ),
      ));
      if (menu.children != null && menu.children!.isNotEmpty) {
        items.addAll(_buildMenuDropdownItems(menu.children!, level + 1, excludeId));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.menu == null ? S.current.addMenu : S.current.editMenu),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 上级菜单
              DropdownButtonFormField<int?>(
                value: _selectedParentId,
                decoration: InputDecoration(
                  labelText: S.current.parentMenu,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(S.current.topMenu),
                  ),
                  ..._buildMenuDropdownItems(widget.menuTree, 0, widget.menu?.id),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedParentId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // 菜单名称
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${S.current.menuName} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // 菜单类型
              Row(
                children: [
                  Text('${S.current.menuType}: '),
                  Radio<int>(
                    value: 1,
                    groupValue: _menuType,
                    onChanged: (value) {
                      setState(() {
                        _menuType = value!;
                      });
                    },
                  ),
                  const Text('目录'),
                  Radio<int>(
                    value: 2,
                    groupValue: _menuType,
                    onChanged: (value) {
                      setState(() {
                        _menuType = value!;
                      });
                    },
                  ),
                  const Text('菜单'),
                  Radio<int>(
                    value: 3,
                    groupValue: _menuType,
                    onChanged: (value) {
                      setState(() {
                        _menuType = value!;
                      });
                    },
                  ),
                  const Text('按钮'),
                ],
              ),
              const SizedBox(height: 16),
              // 路由地址 (目录和菜单显示)
              if (_menuType != 3) ...[
                TextField(
                  controller: _pathController,
                  decoration: InputDecoration(
                    labelText: S.current.routePath,
                    hintText: S.current.routePathHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // 组件地址 (菜单显示)
              if (_menuType == 2) ...[
                TextField(
                  controller: _componentController,
                  decoration: InputDecoration(
                    labelText: S.current.componentPath,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _componentNameController,
                  decoration: InputDecoration(
                    labelText: S.current.componentName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // 权限标识 (菜单和按钮显示)
              if (_menuType != 1) ...[
                TextField(
                  controller: _permissionController,
                  decoration: InputDecoration(
                    labelText: S.current.permission,
                    hintText: S.current.permissionHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // 图标 (目录和菜单显示)
              if (_menuType != 3) ...[
                TextField(
                  controller: _iconController,
                  decoration: InputDecoration(
                    labelText: S.current.icon,
                    hintText: S.current.iconHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: _iconController.text.isNotEmpty
                        ? Icon(MenuIconHelper.getIconData(_iconController.text))
                        : const Icon(Icons.image),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
              ],
              // 显示顺序
              TextField(
                controller: _sortController,
                decoration: InputDecoration(
                  labelText: '${S.current.sort} *',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 8),
              // 显示状态 (目录和菜单显示)
              if (_menuType != 3) ...[
                Row(
                  children: [
                    Text('${S.current.visible}: '),
                    Radio<bool>(
                      value: true,
                      groupValue: _visible,
                      onChanged: (value) {
                        setState(() {
                          _visible = value!;
                        });
                      },
                    ),
                    Text(S.current.show),
                    Radio<bool>(
                      value: false,
                      groupValue: _visible,
                      onChanged: (value) {
                        setState(() {
                          _visible = value!;
                        });
                      },
                    ),
                    Text(S.current.hide),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              // 缓存状态 (菜单显示)
              if (_menuType == 2) ...[
                Row(
                  children: [
                    Text('${S.current.cache}: '),
                    Radio<bool>(
                      value: true,
                      groupValue: _keepAlive,
                      onChanged: (value) {
                        setState(() {
                          _keepAlive = value!;
                        });
                      },
                    ),
                    Text(S.current.yes),
                    Radio<bool>(
                      value: false,
                      groupValue: _keepAlive,
                      onChanged: (value) {
                        setState(() {
                          _keepAlive = value!;
                        });
                      },
                    ),
                    Text(S.current.no),
                  ],
                ),
                const SizedBox(height: 8),
                // 总是显示
                Row(
                  children: [
                    Text('${S.current.alwaysShow}: '),
                    Radio<bool>(
                      value: true,
                      groupValue: _alwaysShow,
                      onChanged: (value) {
                        setState(() {
                          _alwaysShow = value!;
                        });
                      },
                    ),
                    Text(S.current.yes),
                    Radio<bool>(
                      value: false,
                      groupValue: _alwaysShow,
                      onChanged: (value) {
                        setState(() {
                          _alwaysShow = value!;
                        });
                      },
                    ),
                    Text(S.current.no),
                  ],
                ),
              ],
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

/// 显示菜单表单对话框的辅助函数
Future<void> showMenuFormDialog({
  required BuildContext context,
  Menu? menu,
  int? parentId,
  required List<Menu> menuTree,
  required Future<bool> Function(Menu menu) onCreate,
  required Future<bool> Function(Menu menu) onUpdate,
}) {
  return showDialog(
    context: context,
    builder: (context) => MenuFormDialog(
      menu: menu,
      parentId: parentId,
      menuTree: menuTree,
      onCreate: onCreate,
      onUpdate: onUpdate,
    ),
  );
}