import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../../../models/common/api_response.dart';

/// 错误拦截器
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = '网络请求失败';

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '网络连接超时';
        break;
      case DioExceptionType.badResponse:
        final response = err.response;
        if (response != null) {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            final apiResponse = ApiResponse.fromJson(data, null);
            message = apiResponse.msg;
          } else {
            message = '服务器错误: ${response.statusCode}';
          }
        }
        break;
      case DioExceptionType.cancel:
        message = '请求已取消';
        break;
      case DioExceptionType.connectionError:
        message = '网络连接失败，请检查网络';
        break;
      default:
        message = '未知错误';
    }

    // 创建新的错误对象，附带友好消息
    final newError = DioException(
      type: err.type,
      response: err.response,
      message: message,
      requestOptions: err.requestOptions,
    );

    handler.next(newError);
  }
}