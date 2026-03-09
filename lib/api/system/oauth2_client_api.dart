import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/common/api_response.dart';
import '../../models/common/page_result.dart';
import '../../models/system/oauth2_client.dart';

/// OAuth2.0 客户端管理 API
class OAuth2ClientApi {
  final ApiClient _client;

  OAuth2ClientApi(this._client);

  /// 查询 OAuth2.0 客户端列表
  Future<ApiResponse<PageResult<OAuth2Client>>> getOAuth2ClientPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<OAuth2Client>>(
      '/system/oauth2-client/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => OAuth2Client.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询 OAuth2.0 客户端详情
  Future<ApiResponse<OAuth2Client>> getOAuth2Client(int id) async {
    return _client.get<OAuth2Client>(
      '/system/oauth2-client/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => OAuth2Client.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增 OAuth2.0 客户端
  Future<ApiResponse<void>> createOAuth2Client(OAuth2Client data) async {
    return _client.post<void>(
      '/system/oauth2-client/create',
      data: data.toJson(),
    );
  }

  /// 修改 OAuth2.0 客户端
  Future<ApiResponse<void>> updateOAuth2Client(OAuth2Client data) async {
    return _client.put<void>(
      '/system/oauth2-client/update',
      data: data.toJson(),
    );
  }

  /// 删除 OAuth2.0 客户端
  Future<ApiResponse<void>> deleteOAuth2Client(int id) async {
    return _client.delete<void>(
      '/system/oauth2-client/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除 OAuth2.0 客户端
  Future<ApiResponse<void>> deleteOAuth2ClientList(List<int> ids) async {
    return _client.delete<void>(
      '/system/oauth2-client/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }
}

/// OAuth2ClientApi 提供者
final oauth2ClientApiProvider = Provider<OAuth2ClientApi>((ref) {
  return OAuth2ClientApi(ref.watch(apiClientProvider));
});