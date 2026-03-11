import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/common/page_result.dart';
import 'package:yudao_flutter_ui_admin/models/system/oauth2_token.dart';

/// OAuth2.0 令牌管理 API
class OAuth2TokenApi {
  final ApiClient _client;

  OAuth2TokenApi(this._client);

  /// 查询 OAuth2.0 令牌列表
  Future<ApiResponse<PageResult<OAuth2Token>>> getOAuth2TokenPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<OAuth2Token>>(
      '/system/oauth2-token/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => OAuth2Token.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 删除 OAuth2.0 令牌
  Future<ApiResponse<void>> deleteOAuth2Token(String accessToken) async {
    return _client.delete<void>(
      '/system/oauth2-token/delete',
      queryParameters: {'accessToken': accessToken},
    );
  }
}

/// OAuth2TokenApi 提供者
final oauth2TokenApiProvider = Provider<OAuth2TokenApi>((ref) {
  return OAuth2TokenApi(ref.watch(apiClientProvider));
});