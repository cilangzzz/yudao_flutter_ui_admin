import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/infra/demo01_contact.dart';

/// 示例联系人 API - Demo01
class Demo01ContactApi {
  final ApiClient _client;

  Demo01ContactApi(this._client);

  /// 分页查询示例联系人
  Future<ApiResponse<PageResult<Demo01Contact>>> getDemo01ContactPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<Demo01Contact>>(
      '/infra/demo01-contact/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => Demo01Contact.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询示例联系人详情
  Future<ApiResponse<Demo01Contact>> getDemo01Contact(int id) async {
    return _client.get<Demo01Contact>(
      '/infra/demo01-contact/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => Demo01Contact.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增示例联系人
  Future<ApiResponse<void>> createDemo01Contact(Demo01Contact data) async {
    return _client.post<void>(
      '/infra/demo01-contact/create',
      data: data.toJson(),
    );
  }

  /// 修改示例联系人
  Future<ApiResponse<void>> updateDemo01Contact(Demo01Contact data) async {
    return _client.put<void>(
      '/infra/demo01-contact/update',
      data: data.toJson(),
    );
  }

  /// 删除示例联系人
  Future<ApiResponse<void>> deleteDemo01Contact(int id) async {
    return _client.delete<void>(
      '/infra/demo01-contact/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除示例联系人
  Future<ApiResponse<void>> deleteDemo01ContactList(List<int> ids) async {
    return _client.delete<void>(
      '/infra/demo01-contact/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }

  /// 导出示例联系人
  Future<ApiResponse<dynamic>> exportDemo01Contact(Map<String, dynamic> params) async {
    return _client.get<dynamic>(
      '/infra/demo01-contact/export-excel',
      queryParameters: params,
    );
  }
}

/// Demo01ContactApi 提供者
final demo01ContactApiProvider = Provider<Demo01ContactApi>((ref) {
  return Demo01ContactApi(ref.watch(apiClientProvider));
});