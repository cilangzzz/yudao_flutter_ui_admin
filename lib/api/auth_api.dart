import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../models/common/api_response.dart';
import '../../stores/stores.dart';

/// 认证 API (使用 httpbin.org 测试)
class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  /// 登录 - 使用 httpbin /anything 端点模拟
  Future<ApiResponse<LoginResult>> login({
    required String username,
    required String password,
  }) async {
    return _client.post<LoginResult>(
      'anything/login',
      data: {
        'accessToken': 'test_token_${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken': 'test_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        'expiresTime': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
        'username': username,
      },
      fromJsonT: (json) => LoginResult.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 获取用户信息 - 使用 httpbin /bearer 端点验证 token
  Future<ApiResponse<UserInfo>> getUserInfo() async {
    return _client.get<UserInfo>(
      'bearer',
      fromJsonT: (json) => UserInfo(
        id: 1,
        username: 'test_user',
        nickname: '测试用户',
        email: 'test@example.com',
        avatar: '',
        roles: ['admin'],
      ),
    );
  }

  /// 登出 - 使用 httpbin /anything 端点模拟
  Future<ApiResponse<void>> logout() async {
    return _client.post<void>('anything/logout');
  }

  /// 刷新 Token - 使用 httpbin /anything 端点模拟
  Future<ApiResponse<LoginResult>> refreshToken(String refreshToken) async {
    return _client.post<LoginResult>(
      'anything/refresh-token',
      data: {
        'accessToken': 'test_token_${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken': refreshToken,
        'expiresTime': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      },
      fromJsonT: (json) => LoginResult.fromJson(json as Map<String, dynamic>),
    );
  }
}

/// 登录结果
class LoginResult {
  final String accessToken;
  final String? refreshToken;
  final String? expiresTime;

  const LoginResult({
    required this.accessToken,
    this.refreshToken,
    this.expiresTime,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
      expiresTime: json['expiresTime'] as String?,
    );
  }
}

/// Auth API 提供者
final authApiProvider = Provider<AuthApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthApi(client);
});

/// 登录状态提供者
final loginProvider =
    StateNotifierProvider<LoginNotifier, AsyncValue<void>>((ref) {
  return LoginNotifier(ref);
});

class LoginNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  LoginNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final authApi = _ref.read(authApiProvider);
      final response = await authApi.login(
        username: username,
        password: password,
      );

      if (response.isSuccess && response.data != null) {
        // 保存 Token
        await _ref.read(accessStoreProvider.notifier).setAccess(
              accessToken: response.data!.accessToken,
              refreshToken: response.data!.refreshToken,
            );

        // 获取用户信息
        final userResponse = await authApi.getUserInfo();
        if (userResponse.isSuccess && userResponse.data != null) {
          await _ref.read(userStoreProvider.notifier).setUserInfo(userResponse.data!);
        }

        state = const AsyncValue.data(null);
        return true;
      }

      state = AsyncValue.error(response.msg, StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _ref.read(authApiProvider).logout();
    } finally {
      await _ref.read(accessStoreProvider.notifier).clearAccess();
      await _ref.read(userStoreProvider.notifier).clearUser();
    }
  }
}