import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants/app_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/log_interceptor.dart';
import '../models/common/api_response.dart';

/// Dio 客户端提供者
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'tenant-id': AppConstants.tenantId,
      },
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(ref),
    ErrorInterceptor(),
    ApiLogInterceptor(),
  ]);

  return dio;
});

/// API 客户端封装
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// JSON 请求选项
  Options get _jsonOptions => Options(
        headers: {'Content-Type': 'application/json'},
      );

  /// GET 请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
    Options? options,
  }) async {
    final response = await _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
      options: options ?? _jsonOptions,
    );
    return _handleResponse<T>(response, fromJsonT);
  }

  /// POST 请求 (JSON 格式)
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
    Options? options,
  }) async {
    // 显式将数据转为 JSON 字符串
    final jsonData = data != null ? jsonEncode(data) : null;
    final response = await _dio.post<dynamic>(
      path,
      data: jsonData,
      queryParameters: queryParameters,
      options: options ?? _jsonOptions,
    );
    return _handleResponse<T>(response, fromJsonT);
  }

  /// PUT 请求 (JSON 格式)
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
    Options? options,
  }) async {
    final jsonData = data != null ? jsonEncode(data) : null;
    final response = await _dio.put<dynamic>(
      path,
      data: jsonData,
      queryParameters: queryParameters,
      options: options ?? _jsonOptions,
    );
    return _handleResponse<T>(response, fromJsonT);
  }

  /// DELETE 请求 (JSON 格式)
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
    Options? options,
  }) async {
    final jsonData = data != null ? jsonEncode(data) : null;
    final response = await _dio.delete<dynamic>(
      path,
      data: jsonData,
      queryParameters: queryParameters,
      options: options ?? _jsonOptions,
    );
    return _handleResponse<T>(response, fromJsonT);
  }

  /// 下载文件
  Future<ApiResponse<void>> download(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? savePath,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Content-Type': 'application/json'},
        ),
        onReceiveProgress: onReceiveProgress,
      );
      // 下载成功返回空响应
      return ApiResponse(code: 0, msg: 'success', data: response.data);
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 处理响应
  ApiResponse<T> _handleResponse<T>(
    Response<dynamic> response,
    T Function(dynamic)? fromJsonT,
  ) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ApiResponse.fromJson(data, fromJsonT);
    }
    return ApiResponse(code: -1, msg: 'Invalid response format');
  }
}

/// API 客户端提供者
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});