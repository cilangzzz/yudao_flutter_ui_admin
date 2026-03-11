import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/system/tenant.dart';

/// 租户管理 API
class TenantApi {
  final ApiClient _client;

  TenantApi(this._client);

  /// 分页查询租户
  Future<ApiResponse<PageResult<Tenant>>> getTenantPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<Tenant>>(
      '/system/tenant/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => Tenant.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询租户详情
  Future<ApiResponse<Tenant>> getTenant(int id) async {
    return _client.get<Tenant>(
      '/system/tenant/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => Tenant.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增租户
  Future<ApiResponse<void>> createTenant(Tenant data) async {
    return _client.post<void>(
      '/system/tenant/create',
      data: data.toJson(),
    );
  }

  /// 修改租户
  Future<ApiResponse<void>> updateTenant(Tenant data) async {
    return _client.put<void>(
      '/system/tenant/update',
      data: data.toJson(),
    );
  }

  /// 删除租户
  Future<ApiResponse<void>> deleteTenant(int id) async {
    return _client.delete<void>(
      '/system/tenant/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除租户
  Future<ApiResponse<void>> deleteTenantList(List<int> ids) async {
    return _client.delete<void>(
      '/system/tenant/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 获取租户精简信息列表
  Future<ApiResponse<List<Tenant>>> getTenantSimpleList() async {
    return _client.get<List<Tenant>>(
      '/system/tenant/simple-list',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => Tenant.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// TenantApi 提供者
final tenantApiProvider = Provider<TenantApi>((ref) {
  return TenantApi(ref.watch(apiClientProvider));
});