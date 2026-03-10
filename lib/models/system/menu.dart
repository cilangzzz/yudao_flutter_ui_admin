/// 菜单模型
class Menu {
  final int? id;
  final String name;
  final String? permission;
  final int? type;
  final int? sort;
  final int? parentId;
  final String? path;
  final String? icon;
  final String? component;
  final String? componentName;
  final int? status;
  final bool? visible;
  final bool? keepAlive;
  final bool? alwaysShow;
  final DateTime? createTime;
  final List<Menu>? children;

  const Menu({
    this.id,
    required this.name,
    this.permission,
    this.type,
    this.sort,
    this.parentId,
    this.path,
    this.icon,
    this.component,
    this.componentName,
    this.status,
    this.visible,
    this.keepAlive,
    this.alwaysShow,
    this.createTime,
    this.children,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      permission: json['permission'] as String?,
      type: json['type'] as int?,
      sort: json['sort'] as int?,
      parentId: json['parentId'] as int?,
      path: json['path'] as String?,
      icon: json['icon'] as String?,
      component: json['component'] as String?,
      componentName: json['componentName'] as String?,
      status: json['status'] as int?,
      visible: json['visible'] as bool?,
      keepAlive: json['keepAlive'] as bool?,
      alwaysShow: json['alwaysShow'] as bool?,
      createTime: json['createTime'] != null
          ? DateTime.tryParse(json['createTime'] as String)
          : null,
      children: json['children'] != null
          ? (json['children'] as List<dynamic>)
              .map((e) => Menu.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (permission != null) 'permission': permission,
      if (type != null) 'type': type,
      if (sort != null) 'sort': sort,
      if (parentId != null) 'parentId': parentId,
      if (path != null) 'path': path,
      if (icon != null) 'icon': icon,
      if (component != null) 'component': component,
      if (componentName != null) 'componentName': componentName,
      if (status != null) 'status': status,
      if (visible != null) 'visible': visible,
      if (keepAlive != null) 'keepAlive': keepAlive,
      if (alwaysShow != null) 'alwaysShow': alwaysShow,
      if (createTime != null) 'createTime': createTime?.toIso8601String(),
      if (children != null) 'children': children!.map((e) => e.toJson()).toList(),
    };
  }

  Menu copyWith({
    int? id,
    String? name,
    String? permission,
    int? type,
    int? sort,
    int? parentId,
    String? path,
    String? icon,
    String? component,
    String? componentName,
    int? status,
    bool? visible,
    bool? keepAlive,
    bool? alwaysShow,
    DateTime? createTime,
    List<Menu>? children,
  }) {
    return Menu(
      id: id ?? this.id,
      name: name ?? this.name,
      permission: permission ?? this.permission,
      type: type ?? this.type,
      sort: sort ?? this.sort,
      parentId: parentId ?? this.parentId,
      path: path ?? this.path,
      icon: icon ?? this.icon,
      component: component ?? this.component,
      componentName: componentName ?? this.componentName,
      status: status ?? this.status,
      visible: visible ?? this.visible,
      keepAlive: keepAlive ?? this.keepAlive,
      alwaysShow: alwaysShow ?? this.alwaysShow,
      createTime: createTime ?? this.createTime,
      children: children ?? this.children,
    );
  }
}

/// 精简菜单信息（用于下拉选择）
class SimpleMenu {
  final int id;
  final String name;
  final int? parentId;

  const SimpleMenu({
    required this.id,
    required this.name,
    this.parentId,
  });

  factory SimpleMenu.fromJson(Map<String, dynamic> json) {
    return SimpleMenu(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      parentId: json['parentId'] as int?,
    );
  }
}