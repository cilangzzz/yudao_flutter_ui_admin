import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo02_category.dart';

/// 示例分类 API - Demo02 (树形结构)
class Demo02CategoryApi {
  final ApiClient _client;

  Demo02CategoryApi(this._client);

  /// 查询示例分类列表
  Future<ApiResponse<List<Demo02Category>>> getDemo02CategoryList(Map<String, dynamic> params) async {
    return _client.get<List<Demo02Category>>(
      '/infra/demo02-category/list',
      queryParameters: params,
      fromJsonT: (json) => (json as List).map((e) => Demo02Category.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// 查询示例分类详情
  Future<ApiResponse<Demo02Category>> getDemo02Category(int id) async {
    return _client.get<Demo02Category>(
      '/infra/demo02-category/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => Demo02Category.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增示例分类
  Future<ApiResponse<void>> createDemo02Category(Demo02Category data) async {
    return _client.post<void>(
      '/infra/demo02-category/create',
      data: data.toJson(),
    );
  }

  /// 修改示例分类
  Future<ApiResponse<void>> updateDemo02Category(Demo02Category data) async {
    return _client.put<void>(
      '/infra/demo02-category/update',
      data: data.toJson(),
    );
  }

  /// 删除示例分类
  Future<ApiResponse<void>> deleteDemo02Category(int id) async {
    return _client.delete<void>(
      '/infra/demo02-category/delete',
      queryParameters: {'id': id},
    );
  }

  /// 导出示例分类
  Future<ApiResponse<dynamic>> exportDemo02Category(Map<String, dynamic> params) async {
    return _client.get<dynamic>(
      '/infra/demo02-category/export-excel',
      queryParameters: params,
    );
  }
}

/// Demo02CategoryApi 提供者
final demo02CategoryApiProvider = Provider<Demo02CategoryApi>((ref) {
  return Demo02CategoryApi(ref.watch(apiClientProvider));
});