import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/common/api_response.dart';
import '../../models/common/page_result.dart';
import '../../models/system/social_user.dart';

/// 社交用户管理 API
class SocialUserApi {
  final ApiClient _client;

  SocialUserApi(this._client);

  /// 查询社交用户列表
  Future<ApiResponse<PageResult<SocialUser>>> getSocialUserPage(Map<String, dynamic> params) async {
    return _client.get<PageResult<SocialUser>>(
      '/system/social-user/page',
      queryParameters: params,
      fromJsonT: (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        (e) => SocialUser.fromJson(e as Map<String, dynamic>),
      ),
    );
  }

  /// 查询社交用户详情
  Future<ApiResponse<SocialUser>> getSocialUser(int id) async {
    return _client.get<SocialUser>(
      '/system/social-user/get',
      queryParameters: {'id': id},
      fromJsonT: (json) => SocialUser.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 社交绑定，使用 code 授权码
  Future<ApiResponse<bool>> socialBind(SocialUserBindReq data) async {
    return _client.post<bool>(
      '/system/social-user/bind',
      data: data.toJson(),
      fromJsonT: (json) => json as bool,
    );
  }

  /// 取消社交绑定
  Future<ApiResponse<bool>> socialUnbind(SocialUserUnbindReq data) async {
    return _client.delete<bool>(
      '/system/social-user/unbind',
      data: data.toJson(),
      fromJsonT: (json) => json as bool,
    );
  }

  /// 获得绑定社交用户列表
  Future<ApiResponse<List<SocialUser>>> getBindSocialUserList() async {
    return _client.get<List<SocialUser>>(
      '/system/social-user/get-bind-list',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => SocialUser.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// SocialUserApi 提供者
final socialUserApiProvider = Provider<SocialUserApi>((ref) {
  return SocialUserApi(ref.watch(apiClientProvider));
});