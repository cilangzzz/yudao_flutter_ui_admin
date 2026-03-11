import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_param.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/system/role.dart';

/// 角色管理 API
class RoleApi {
  final ApiClient _client;

  RoleApi(this._client);

  /// 分页查询角色
  Future<ApiResponse<PageResult<Role>>> getRolePage(PageParam params) async {
    return _client.get<PageResult<Role>>(
      '/system/role/page',
      queryParameters: params.toJson(),
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => Role.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询角色详情
  Future<ApiResponse<Role>> getRole(int id) async {
    return _client.get<Role>(
      '/system/role/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => Role.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增角色
  Future<ApiResponse<void>> createRole(Role data) async {
    return _client.post<void>(
      '/system/role/create',
      data: data.toJson(),
    );
  }

  /// 修改角色
  Future<ApiResponse<void>> updateRole(Role data) async {
    return _client.put<void>(
      '/system/role/update',
      data: data.toJson(),
    );
  }

  /// 删除角色
  Future<ApiResponse<void>> deleteRole(int id) async {
    return _client.delete<void>(
      '/system/role/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除角色
  Future<ApiResponse<void>> deleteRoleList(List<int> ids) async {
    return _client.delete<void>(
      '/system/role/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 获取精简角色列表
  Future<ApiResponse<List<Role>>> getSimpleRoleList() async {
    return _client.get<List<Role>>(
      '/system/role/simple-list',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// RoleApi 提供者
final roleApiProvider = Provider<RoleApi>((ref) {
  return RoleApi(ref.watch(apiClientProvider));
});