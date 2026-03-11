import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yudao_flutter_ui_admin/app/core/api_client.dart';
import 'package:yudao_flutter_ui_admin/models/common/api_response.dart';
import 'package:yudao_flutter_ui_admin/models/core/auth_models.dart';

/// 认证 API
class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  /// 登录
  Future<ApiResponse<LoginResult>> login(LoginParams data) async {
    return _client.post<LoginResult>(
      '/system/auth/login',
      data: data.toJson(),
      fromJsonT: (json) => LoginResult.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 刷新 accessToken
  Future<ApiResponse<LoginResult>> refreshToken(String refreshToken) async {
    return _client.post<LoginResult>(
      '/system/auth/refresh-token?refreshToken=$refreshToken',
      fromJsonT: (json) => LoginResult.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 退出登录
  Future<ApiResponse<void>> logout(String accessToken) async {
    return _client.post<void>(
      '/system/auth/logout',
    );
  }

  /// 获取权限信息
  Future<ApiResponse<AuthPermissionInfo>> getAuthPermissionInfo() async {
    return _client.get<AuthPermissionInfo>(
      '/system/auth/get-permission-info',
      fromJsonT: (json) =>
          AuthPermissionInfo.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 获取租户列表
  Future<ApiResponse<List<TenantResult>>> getTenantSimpleList() async {
    return _client.get<List<TenantResult>>(
      '/system/tenant/simple-list',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((e) => TenantResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 使用租户域名，获得租户信息
  Future<ApiResponse<TenantResult>> getTenantByWebsite(String website) async {
    return _client.get<TenantResult>(
      '/system/tenant/get-by-website',
      queryParameters: {'website': website},
      fromJsonT: (json) => TenantResult.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 获取验证码
  Future<ApiResponse<dynamic>> getCaptcha(Map<String, dynamic> data) async {
    return _client.post<dynamic>(
      '/system/captcha/get',
      data: data,
    );
  }

  /// 校验验证码
  Future<ApiResponse<dynamic>> checkCaptcha(Map<String, dynamic> data) async {
    return _client.post<dynamic>(
      '/system/captcha/check',
      data: data,
    );
  }

  /// 获取登录验证码
  Future<ApiResponse<void>> sendSmsCode(SmsCodeParams data) async {
    return _client.post<void>(
      '/system/auth/send-sms-code',
      data: data.toJson(),
    );
  }

  /// 短信验证码登录
  Future<ApiResponse<LoginResult>> smsLogin(SmsLoginParams data) async {
    return _client.post<LoginResult>(
      '/system/auth/sms-login',
      data: data.toJson(),
      fromJsonT: (json) => LoginResult.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 注册
  Future<ApiResponse<void>> register(RegisterParams data) async {
    return _client.post<void>(
      '/system/auth/register',
      data: data.toJson(),
    );
  }

  /// 通过短信重置密码
  Future<ApiResponse<void>> smsResetPassword(ResetPasswordParams data) async {
    return _client.post<void>(
      '/system/auth/reset-password',
      data: data.toJson(),
    );
  }

  /// 社交授权的跳转
  Future<ApiResponse<dynamic>> socialAuthRedirect(
    int type,
    String redirectUri,
  ) async {
    return _client.get<dynamic>(
      '/system/auth/social-auth-redirect',
      queryParameters: {
        'type': type,
        'redirectUri': redirectUri,
      },
    );
  }

  /// 社交快捷登录
  Future<ApiResponse<LoginResult>> socialLogin(SocialLoginParams data) async {
    return _client.post<LoginResult>(
      '/system/auth/social-login',
      data: data.toJson(),
      fromJsonT: (json) => LoginResult.fromJson(json as Map<String, dynamic>),
    );
  }
}

/// AuthApi 提供者
final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});