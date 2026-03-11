import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/api/system/dept_api.dart';
import 'package:yudao_flutter_ui_admin/api/system/permission_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/role.dart';
import 'package:yudao_flutter_ui_admin/models/system/dept.dart';
import 'package:yudao_flutter_ui_admin/models/system/permission.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 扁平化的部门数据，用于展示
class _FlatDeptItem {
  final SimpleDept dept;
  final int level;
  final bool hasChildren;

  const _FlatDeptItem({
    required this.dept,
    required this.level,
    required this.hasChildren,
  });
}

/// 分配数据权限弹窗
class AssignDataScopeDialog extends StatefulWidget {
  final Role role;
  final WidgetRef ref;
  final VoidCallback onSuccess;

  const AssignDataScopeDialog({
    super.key,
    required this.role,
    required this.ref,
    required this.onSuccess,
  });

  @override
  State<AssignDataScopeDialog> createState() => _AssignDataScopeDialogState();
}

class _AssignDataScopeDialogState extends State<AssignDataScopeDialog> {
  List<SimpleDept> _deptList = [];
  List<SimpleDept> _deptTree = [];
  Set<int> _selectedDeptIds = {};
  int _dataScope = 1; // 默认全部数据权限
  bool _isLoading = true;
  bool _isAllExpanded = false;

  // 每个节点的展开状态
  final Map<int, bool> _expandedMap = {};

  // 数据权限范围选项
  List<String> get _dataScopeLabels => [
    S.current.dataScopeAll,
    S.current.dataScopeCustom,
    S.current.dataScopeDeptOnly,
    S.current.dataScopeDeptBelow,
    S.current.dataScopeSelfOnly,
  ];

  @override
  void initState() {
    super.initState();
    _dataScope = widget.role.dataScope ?? 1;
    _selectedDeptIds = (widget.role.dataScopeDeptIds ?? []).toSet();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final deptApi = widget.ref.read(deptApiProvider);
      final response = await deptApi.getSimpleDeptList();

      if (response.isSuccess && response.data != null) {
        setState(() {
          _deptList = response.data!;
          _deptTree = _buildDeptTree(_deptList);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 构建部门树结构
  List<SimpleDept> _buildDeptTree(List<SimpleDept> allDepts) {
    final rootDepts = allDepts.where((dept) => dept.parentId == null || dept.parentId == 0).toList();

    List<SimpleDept> buildChildren(int parentId) {
      return allDepts
          .where((dept) => dept.parentId == parentId)
          .map((dept) => dept.copyWith(children: buildChildren(dept.id)))
          .toList();
    }

    return rootDepts.map((dept) => dept.copyWith(children: buildChildren(dept.id))).toList();
  }

  /// 将树形数据扁平化为带层级的列表（参考menu_page.dart优化）
  List<_FlatDeptItem> _flattenDeptTree(List<SimpleDept> depts, int level) {
    final result = <_FlatDeptItem>[];
    for (final dept in depts) {
      final hasChildren = dept.children != null && dept.children!.isNotEmpty;
      final isExpanded = _expandedMap[dept.id] ?? false;
      result.add(_FlatDeptItem(dept: dept, level: level, hasChildren: hasChildren));

      if (hasChildren && isExpanded) {
        result.addAll(_flattenDeptTree(dept.children!, level + 1));
      }
    }
    return result;
  }

  /// 切换单个节点展开状态
  void _toggleExpand(int deptId) {
    setState(() {
      _expandedMap[deptId] = !(_expandedMap[deptId] ?? false);
    });
  }

  /// 切换全部展开/折叠
  void _toggleAllExpanded() {
    setState(() {
      _isAllExpanded = !_isAllExpanded;
      for (final dept in _deptList) {
        _expandedMap[dept.id] = _isAllExpanded;
      }
    });
  }

  List<int> _getAllDeptIds() {
    return _deptList.map((d) => d.id).toList();
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedDeptIds.length == _deptList.length) {
        _selectedDeptIds.clear();
      } else {
        _selectedDeptIds = _getAllDeptIds().toSet();
      }
    });
  }

  /// 选择/取消选择部门（含级联处理）
  void _toggleDeptSelection(SimpleDept dept, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedDeptIds.add(dept.id);
        // 添加所有子部门
        _addChildrenDeptIds(dept.id);
        // 添加父部门
        _addParentDeptIds(dept.parentId);
      } else {
        _selectedDeptIds.remove(dept.id);
        // 移除子部门
        _removeChildrenDeptIds(dept.id);
      }
    });
  }

  Future<void> _submit() async {
    try {
      final permissionApi = widget.ref.read(permissionApiProvider);
      final response = await permissionApi.assignRoleDataScope(
        AssignRoleDataScopeReq(
          roleId: widget.role.id!,
          dataScope: _dataScope,
          dataScopeDeptIds: _dataScope == 2 ? _selectedDeptIds.toList() : [],
        ),
      );

      if (response.isSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.current.saveSuccess)),
          );
        }
        widget.onSuccess();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.saveFailed), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.current.assignDataPermission),
      content: SizedBox(
        width: 500,
        height: 550,
        child: Column(
          children: [
            // 角色信息
            Wrap(
              spacing: 24,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${S.current.roleName}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.role.name),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${S.current.roleCode}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.role.code),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            // 数据权限范围选择
            DropdownButtonFormField<int>(
              value: _dataScope,
              decoration: InputDecoration(
                labelText: S.current.dataScope,
                border: const OutlineInputBorder(),
              ),
              items: List.generate(5, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text(_dataScopeLabels[index]),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _dataScope = value);
                }
              },
            ),
            const SizedBox(height: 16),
            // 部门选择树（仅自定义部门时显示）
            if (_dataScope == 2) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: _toggleSelectAll,
                    icon: Icon(
                      _selectedDeptIds.length == _deptList.length && _deptList.isNotEmpty
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                    label: Text(S.current.selectAll),
                  ),
                  TextButton.icon(
                    onPressed: _toggleAllExpanded,
                    icon: Icon(_isAllExpanded ? Icons.unfold_less : Icons.unfold_more),
                    label: Text(_isAllExpanded ? S.current.collapseAll : S.current.expandAll),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildDeptList(),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Text(
                    S.current.customDeptHint,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.current.cancel),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(S.current.confirm),
        ),
      ],
    );
  }

  /// 构建部门列表（扁平化渲染，优化大数据量性能）
  Widget _buildDeptList() {
    final flatDepts = _flattenDeptTree(_deptTree, 0);

    if (flatDepts.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return ListView.builder(
      itemCount: flatDepts.length,
      itemBuilder: (context, index) {
        final item = flatDepts[index];
        final dept = item.dept;
        final level = item.level;
        final hasChildren = item.hasChildren;
        final isSelected = _selectedDeptIds.contains(dept.id);
        final isExpanded = _expandedMap[dept.id] ?? false;

        return InkWell(
          onTap: () => _toggleDeptSelection(dept, !isSelected),
          child: Padding(
            padding: EdgeInsets.only(left: level * 20.0, top: 6, bottom: 6),
            child: Row(
              children: [
                // 展开/折叠按钮
                if (hasChildren)
                  InkWell(
                    onTap: () => _toggleExpand(dept.id),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isExpanded ? Icons.expand_more : Icons.chevron_right,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 26),
                // 复选框
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 20,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
                const SizedBox(width: 8),
                // 部门名称
                Expanded(child: Text(dept.name)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addChildrenDeptIds(int parentId) {
    final children = _deptList.where((d) => d.parentId == parentId);
    for (final child in children) {
      _selectedDeptIds.add(child.id);
      _addChildrenDeptIds(child.id);
    }
  }

  void _removeChildrenDeptIds(int parentId) {
    final children = _deptList.where((d) => d.parentId == parentId);
    for (final child in children) {
      _selectedDeptIds.remove(child.id);
      _removeChildrenDeptIds(child.id);
    }
  }

  void _addParentDeptIds(int? parentId) {
    if (parentId == null || parentId == 0) return;
    _selectedDeptIds.add(parentId);
    final parent = _deptList.firstWhere(
      (d) => d.id == parentId,
      orElse: () => SimpleDept(id: -1, name: '', parentId: null),
    );
    if (parent.id != -1) {
      _addParentDeptIds(parent.parentId);
    }
  }
}