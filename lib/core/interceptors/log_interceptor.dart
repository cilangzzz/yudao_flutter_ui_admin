import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// 日志拦截器
class ApiLogInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('''
┌────────────────────────────────────────────────────────────────
│ 🚀 REQUEST: ${options.method} ${options.uri}
│ Headers: ${options.headers}
│ Data: ${options.data}
└────────────────────────────────────────────────────────────────
''');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i('''
┌────────────────────────────────────────────────────────────────
│ ✅ RESPONSE: ${response.requestOptions.method} ${response.requestOptions.uri}
│ Status: ${response.statusCode}
│ Data: ${_truncateData(response.data)}
└────────────────────────────────────────────────────────────────
''');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('''
┌────────────────────────────────────────────────────────────────
│ ❌ ERROR: ${err.requestOptions.method} ${err.requestOptions.uri}
│ Message: ${err.message}
│ Response: ${err.response?.data}
└────────────────────────────────────────────────────────────────
''');
    handler.next(err);
  }

  String _truncateData(dynamic data) {
    final str = data.toString();
    if (str.length > 500) {
      return '${str.substring(0, 500)}... (truncated)';
    }
    return str;
  }
}