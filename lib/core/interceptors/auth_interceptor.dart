import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../../stores/access_store.dart';

/// 认证拦截器
class AuthInterceptor extends Interceptor {
  final Ref _ref;

  AuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 添加 Token
    final accessToken = _ref.read(accessStoreProvider).accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    // 确保有租户ID
    options.headers['tenant-id'] ??= AppConstants.tenantId;

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 错误处理 - Token 过期
    if (err.response?.statusCode == 401) {
      // 可以在这里实现 Token 刷新逻辑
      // 目前简单清除登录状态
      _ref.read(accessStoreProvider.notifier).clearAccess();
    }

    handler.next(err);
  }
}