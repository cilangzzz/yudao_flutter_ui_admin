/// 分配用户角色请求
class AssignUserRoleReq {
  final int userId;
  final List<int> roleIds;

  const AssignUserRoleReq({
    required this.userId,
    required this.roleIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'roleIds': roleIds,
    };
  }
}

/// 分配角色菜单请求
class AssignRoleMenuReq {
  final int roleId;
  final List<int> menuIds;

  const AssignRoleMenuReq({
    required this.roleId,
    required this.menuIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'menuIds': menuIds,
    };
  }
}

/// 分配角色数据权限请求
class AssignRoleDataScopeReq {
  final int roleId;
  final int dataScope;
  final List<int> dataScopeDeptIds;

  const AssignRoleDataScopeReq({
    required this.roleId,
    required this.dataScope,
    required this.dataScopeDeptIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'dataScope': dataScope,
      'dataScopeDeptIds': dataScopeDeptIds,
    };
  }
}