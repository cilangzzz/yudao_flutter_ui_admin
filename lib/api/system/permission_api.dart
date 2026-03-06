import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/common/api_response.dart';
import '../../models/system/permission.dart';

/// 权限管理 API
class PermissionApi {
  final ApiClient _client;

  PermissionApi(this._client);

  /// 查询角色拥有的菜单权限
  Future<ApiResponse<List<int>>> getRoleMenuList(int roleId) async {
    return _client.get<List<int>>(
      '/system/permission/list-role-menus',
      queryParameters: {'roleId': roleId},
      fromJsonT: (json) => (json as List<dynamic>).map((e) => e as int).toList(),
    );
  }

  /// 赋予角色菜单权限
  Future<ApiResponse<void>> assignRoleMenu(AssignRoleMenuReq data) async {
    return _client.post<void>(
      '/system/permission/assign-role-menu',
      data: data.toJson(),
    );
  }

  /// 赋予角色数据权限
  Future<ApiResponse<void>> assignRoleDataScope(AssignRoleDataScopeReq data) async {
    return _client.post<void>(
      '/system/permission/assign-role-data-scope',
      data: data.toJson(),
    );
  }

  /// 查询用户拥有的角色列表
  Future<ApiResponse<List<int>>> getUserRoleList(int userId) async {
    return _client.get<List<int>>(
      '/system/permission/list-user-roles',
      queryParameters: {'userId': userId},
      fromJsonT: (json) => (json as List<dynamic>).map((e) => e as int).toList(),
    );
  }

  /// 赋予用户角色
  Future<ApiResponse<void>> assignUserRole(AssignUserRoleReq data) async {
    return _client.post<void>(
      '/system/permission/assign-user-role',
      data: data.toJson(),
    );
  }
}

/// PermissionApi 提供者
final permissionApiProvider = Provider<PermissionApi>((ref) {
  return PermissionApi(ref.watch(apiClientProvider));
});