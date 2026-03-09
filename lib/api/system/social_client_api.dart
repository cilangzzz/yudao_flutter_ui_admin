import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/common/api_response.dart';
import '../../models/common/page_result.dart';
import '../../models/system/social_client.dart';

/// 社交客户端管理 API
class SocialClientApi {
  final ApiClient _client;

  SocialClientApi(this._client);

  /// 查询社交客户端列表
  Future<ApiResponse<PageResult<SocialClient>>> getSocialClientPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<SocialClient>>(
      '/system/social-client/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => SocialClient.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询社交客户端详情
  Future<ApiResponse<SocialClient>> getSocialClient(int id) async {
    return _client.get<SocialClient>(
      '/system/social-client/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => SocialClient.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 新增社交客户端
  Future<ApiResponse<void>> createSocialClient(SocialClient data) async {
    return _client.post<void>(
      '/system/social-client/create',
      data: data.toJson(),
    );
  }

  /// 修改社交客户端
  Future<ApiResponse<void>> updateSocialClient(SocialClient data) async {
    return _client.put<void>(
      '/system/social-client/update',
      data: data.toJson(),
    );
  }

  /// 删除社交客户端
  Future<ApiResponse<void>> deleteSocialClient(int id) async {
    return _client.delete<void>(
      '/system/social-client/delete',
      queryParameters: {'id': id},
    );
  }

  /// 批量删除社交客户端
  Future<ApiResponse<void>> deleteSocialClientList(List<int> ids) async {
    return _client.delete<void>(
      '/system/social-client/delete-list',
      queryParameters: {'ids': ids.join(',')},
    );
  }
}

/// SocialClientApi 提供者
final socialClientApiProvider = Provider<SocialClientApi>((ref) {
  return SocialClientApi(ref.watch(apiClientProvider));
});