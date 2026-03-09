import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/common/api_response.dart';
import '../../models/common/page_result.dart';
import '../../models/system/tenant_package.dart';

/// 租户套餐管理 API
class TenantPackageApi {
  final ApiClient _client;

  TenantPackageApi(this._client);

  /// 分页查询租户套餐
  Future<ApiResponse<PageResult<TenantPackage>>> getTenantPackagePage(Map<String, dynamic> params) async {
    return _client.get<PageResult<TenantPackage>>(
      '/system/tenant-package/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => TenantPackage.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询租户套餐详情
  Future<ApiResponse<TenantPackage>> getTenantPackage(int id) async {
    return _client.get<TenantPackage>(
      '/system/tenant-package/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => TenantPackage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增租户套餐
  Future<ApiResponse<void>> createTenantPackage(TenantPackage data) async {
    return _client.post<void>(
      '/system/tenant-package/create',
      data: data.toJson(),
    );
  }

  /// 修改租户套餐
  Future<ApiResponse<void>> updateTenantPackage(TenantPackage data) async {
    return _client.put<void>(
      '/system/tenant-package/update',
      data: data.toJson(),
    );
  }

  /// 删除租户套餐
  Future<ApiResponse<void>> deleteTenantPackage(int id) async {
    return _client.delete<void>(
      '/system/tenant-package/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除租户套餐
  Future<ApiResponse<void>> deleteTenantPackageList(List<int> ids) async {
    return _client.delete<void>(
      '/system/tenant-package/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 获取租户套餐精简信息列表
  Future<ApiResponse<List<TenantPackage>>> getTenantPackageSimpleList() async {
    return _client.get<List<TenantPackage>>(
      '/system/tenant-package/get-simple-list',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => TenantPackage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// TenantPackageApi 提供者
final tenantPackageApiProvider = Provider<TenantPackageApi>((ref) {
  return TenantPackageApi(ref.watch(apiClientProvider));
});