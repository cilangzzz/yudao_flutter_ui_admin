import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/system/dept.dart';

/// 部门管理 API
class DeptApi {
  final ApiClient _client;

  DeptApi(this._client);

  /// 查询部门列表
  Future<ApiResponse<List<Dept>>> getDeptList() async {
    return _client.get<List<Dept>>(
      '/system/dept/list',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => Dept.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 查询部门详情
  Future<ApiResponse<Dept>> getDept(int id) async {
    return _client.get<Dept>(
      '/system/dept/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => Dept.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增部门
  Future<ApiResponse<void>> createDept(Dept data) async {
    return _client.post<void>(
      '/system/dept/create',
      data: data.toJson(),
    );
  }

  /// 修改部门
  Future<ApiResponse<void>> updateDept(Dept data) async {
    return _client.put<void>(
      '/system/dept/update',
      data: data.toJson(),
    );
  }

  /// 删除部门
  Future<ApiResponse<void>> deleteDept(int id) async {
    return _client.delete<void>(
      '/system/dept/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除部门
  Future<ApiResponse<void>> deleteDeptList(List<int> ids) async {
    return _client.delete<void>(
      '/system/dept/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 获取精简部门列表
  Future<ApiResponse<List<SimpleDept>>> getSimpleDeptList() async {
    return _client.get<List<SimpleDept>>(
      '/system/dept/simple-list',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => SimpleDept.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// DeptApi 提供者
final deptApiProvider = Provider<DeptApi>((ref) {
  return DeptApi(ref.watch(apiClientProvider));
});