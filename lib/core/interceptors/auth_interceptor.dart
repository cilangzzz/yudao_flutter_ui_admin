import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../../stores/access_store.dart';
import '../../api/core/auth_api.dart';
import '../../core/api_client.dart';

/// 认证拦截器
class AuthInterceptor extends Interceptor {
  final Ref _ref;
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

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
      final refreshToken = _ref.read(accessStoreProvider).refreshToken;

      // 没有 refreshToken，直接清除登录状态
      if (refreshToken == null || refreshToken.isEmpty) {
        _ref.read(accessStoreProvider.notifier).clearAccess();
        handler.next(err);
        return;
      }

      // 如果正在刷新，将请求加入等待队列
      if (_isRefreshing) {
        _pendingRequests.add(_PendingRequest(err.requestOptions, handler));
        return;
      }

      _isRefreshing = true;

      try {
        // 调用刷新 token API
        final authApi = _ref.read(authApiProvider);
        final response = await authApi.refreshToken(refreshToken);

        if (response.isSuccess && response.data?.accessToken != null) {
          final newToken = response.data!.accessToken;

          // 更新 accessToken
          await _ref
              .read(accessStoreProvider.notifier)
              .setAccessToken(newToken);

          // 重试当前请求
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await _retry(err.requestOptions);
          handler.resolve(retryResponse);

          // 重试所有等待的请求
          for (final pending in _pendingRequests) {
            try {
              pending.options.headers['Authorization'] = 'Bearer $newToken';
              final pendingResponse = await _retry(pending.options);
              pending.handler.resolve(pendingResponse);
            } catch (e) {
              pending.handler.next(err);
            }
          }
        } else {
          // 刷新失败，清除登录状态
          await _ref.read(accessStoreProvider.notifier).clearAccess();
          handler.next(err);
          for (final pending in _pendingRequests) {
            pending.handler.next(err);
          }
        }
      } catch (e) {
        // 刷新失败，清除登录状态
        await _ref.read(accessStoreProvider.notifier).clearAccess();
        handler.next(err);
        for (final pending in _pendingRequests) {
          pending.handler.next(err);
        }
      } finally {
        _isRefreshing = false;
        _pendingRequests.clear();
      }
    } else {
      handler.next(err);
    }
  }

  /// 重试请求
  Future<Response<dynamic>> _retry(RequestOptions options) async {
    final dio = _ref.read(dioProvider);
    return dio.fetch(options);
  }
}

/// 等待队列中的请求
class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;

  _PendingRequest(this.options, this.handler);
}