import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 应用日志工具类
///
/// 提供统一的日志管理，支持不同环境和日志级别的配置。
/// 在开发环境下输出详细日志，生产环境下可选择关闭或减少日志输出。
class AppLog {
  AppLog._();

  /// 全局 Logger 实例
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 100,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: kDebugMode ? Level.all : Level.warning,
  );

  /// 简洁输出的 Logger 实例（用于不需要堆栈跟踪的场景）
  static final Logger _simpleLogger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: kDebugMode ? Level.all : Level.warning,
  );

  /// 是否启用日志
  static bool _enabled = kDebugMode;

  /// 设置日志开关
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// 获取日志开关状态
  static bool get isEnabled => _enabled;

  /// 输出调试级别日志
  ///
  /// 用于开发调试信息，生产环境默认不输出
  static void debug(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// 输出信息级别日志
  ///
  /// 用于一般性信息输出
  static void info(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// 输出警告级别日志
  ///
  /// 用于警告信息，表示可能存在问题但不影响程序运行
  static void warning(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// 输出错误级别日志
  ///
  /// 用于错误信息，表示发生了影响程序正常运行的问题
  static void error(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// 输出致命错误级别日志
  ///
  /// 用于严重错误，可能导致程序崩溃或无法继续运行
  static void fatal(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// 输出跟踪级别日志
  ///
  /// 用于详细的程序执行流程跟踪
  static void trace(
    dynamic message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// 简洁的调试日志（不显示方法堆栈）
  ///
  /// 适用于简单的日志输出场景
  static void d(dynamic message) {
    if (!_enabled) return;
    _simpleLogger.d(message);
  }

  /// 简洁的信息日志（不显示方法堆栈）
  ///
  /// 适用于简单的日志输出场景
  static void i(dynamic message) {
    if (!_enabled) return;
    _simpleLogger.i(message);
  }

  /// 简洁的警告日志（不显示方法堆栈）
  ///
  /// 适用于简单的日志输出场景
  static void w(dynamic message) {
    if (!_enabled) return;
    _simpleLogger.w(message);
  }

  /// 简洁的错误日志（不显示方法堆栈）
  ///
  /// 适用于简单的日志输出场景
  static void e(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _simpleLogger.e(message, error: error, stackTrace: stackTrace);
  }

  /// 输出带标签的日志
  ///
  /// 方便在日志中标识来源模块
  static void tagged(
    String tag,
    dynamic message, {
    Level level = Level.debug,
  }) {
    if (!_enabled) return;
    final formattedMessage = '[$tag] $message';
    switch (level) {
      case Level.debug:
        _simpleLogger.d(formattedMessage);
        break;
      case Level.info:
        _simpleLogger.i(formattedMessage);
        break;
      case Level.warning:
        _simpleLogger.w(formattedMessage);
        break;
      case Level.error:
        _simpleLogger.e(formattedMessage);
        break;
      case Level.fatal:
        _simpleLogger.f(formattedMessage);
        break;
      case Level.trace:
        _simpleLogger.t(formattedMessage);
        break;
      default:
        _simpleLogger.d(formattedMessage);
    }
  }

  /// 输出网络请求日志
  ///
  /// 专门用于网络请求的日志格式化输出
  static void network(
    String method,
    String url, {
    Map<String, dynamic>? headers,
    dynamic body,
    int? statusCode,
    dynamic response,
    bool isError = false,
  }) {
    if (!_enabled && !isError) return;

    final buffer = StringBuffer();
    buffer.writeln('┌────────────────────────────────────────────────────────────────');
    buffer.writeln('│ ${isError ? "❌" : "🚀"} NETWORK: $method $url');
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('│ Headers: $headers');
    }
    if (body != null) {
      buffer.writeln('│ Body: ${_truncate(body.toString())}');
    }
    if (statusCode != null) {
      buffer.writeln('│ Status: $statusCode');
    }
    if (response != null) {
      buffer.writeln('│ Response: ${_truncate(response.toString())}');
    }
    buffer.writeln('└────────────────────────────────────────────────────────────────');

    if (isError) {
      _simpleLogger.e(buffer.toString());
    } else {
      _simpleLogger.d(buffer.toString());
    }
  }

  /// 截断过长的字符串
  static String _truncate(String text, {int maxLength = 500}) {
    if (text.length > maxLength) {
      return '${text.substring(0, maxLength)}... (truncated)';
    }
    return text;
  }
}