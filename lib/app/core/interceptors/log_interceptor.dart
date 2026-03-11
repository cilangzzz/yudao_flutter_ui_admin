import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../../../utils/app_log.dart';

/// 日志拦截器
class ApiLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLog.network(
      options.method,
      options.uri.toString(),
      headers: options.headers.map((k, v) => MapEntry(k, v.toString())),
      body: options.data,
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLog.network(
      response.requestOptions.method,
      response.requestOptions.uri.toString(),
      statusCode: response.statusCode,
      response: response.data,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLog.network(
      err.requestOptions.method,
      err.requestOptions.uri.toString(),
      statusCode: err.response?.statusCode,
      response: err.response?.data,
      isError: true,
    );
    handler.next(err);
  }
}