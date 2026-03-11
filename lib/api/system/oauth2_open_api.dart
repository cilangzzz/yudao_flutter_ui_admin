import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/system/oauth2_open.dart';

/// OAuth2.0 开放接口 API
class OAuth2OpenApi {
  final ApiClient _client;

  OAuth2OpenApi(this._client);

  /// 获得授权信息
  Future<ApiResponse<OAuth2AuthorizeInfo>> getAuthorize(String clientId) async {
    return _client.get<OAuth2AuthorizeInfo>(
      '/system/oauth2/authorize',
      queryParameters: {'clientId': clientId},
      fromJsonT: (json) =>
          OAuth2AuthorizeInfo.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 发起授权
  Future<ApiResponse<String>> authorize({
    required String responseType,
    required String clientId,
    required String redirectUri,
    required String state,
    required bool autoApprove,
    required List<String> checkedScopes,
    required List<String> uncheckedScopes,
  }) async {
    // 构建 scopes
    final Map<String, bool> scopes = {};
    for (final scope in checkedScopes) {
      scopes[scope] = true;
    }
    for (final scope in uncheckedScopes) {
      scopes[scope] = false;
    }

    return _client.post<String>(
      '/system/oauth2/authorize',
      queryParameters: {
        'response_type': responseType,
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'state': state,
        'auto_approve': autoApprove,
      },
      data: {'scope': scopes},
      fromJsonT: (json) => json as String,
    );
  }
}

/// OAuth2OpenApi 提供者
final oauth2OpenApiProvider = Provider<OAuth2OpenApi>((ref) {
  return OAuth2OpenApi(ref.watch(apiClientProvider));
});