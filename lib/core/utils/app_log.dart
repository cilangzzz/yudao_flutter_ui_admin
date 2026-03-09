import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 自定义日志打印器，支持显示调用位置
class _CallerPrinter extends LogPrinter {
  final PrettyPrinter _prettyPrinter;
  final int methodCount;

  _CallerPrinter({
    this.methodCount = 0,
    int errorMethodCount = 5,
    int lineLength = 80,
    bool colors = true,
    bool printEmojis = true,
  }) : _prettyPrinter = PrettyPrinter(
          methodCount: methodCount,
          errorMethodCount: errorMethodCount,
          lineLength: lineLength,
          colors: colors,
          printEmojis: printEmojis,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        );

  @override
  List<String> log(LogEvent event) {
    // 获取调用位置信息
    final callerInfo = _getCallerInfo();

    // 创建带有调用位置的消息
    final originalMessage = event.message;
    final newMessage = '$originalMessage\n📍 $callerInfo';

    // 使用新的消息创建新的 LogEvent
    final newEvent = LogEvent(
      event.level,
      newMessage,
      time: event.time,
      error: event.error,
      stackTrace: event.stackTrace,
    );

    return _prettyPrinter.log(newEvent);
  }

  /// 获取调用者信息（文件名和行号）
  String _getCallerInfo() {
    try {
      // 获取当前堆栈跟踪
      final stackTrace = StackTrace.current.toString();
      final lines = stackTrace.split('\n');

      // 查找调用 AppLog 的位置
      // 堆栈结构通常是：
      // 0: _getCallerInfo
      // 1: log (Printer)
      // 2: AppLog 的某个方法
      // 3+: 实际调用位置
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        // 跳过 logger 内部和 AppLog 内部的调用
        if (line.contains('app_log.dart') ||
            line.contains('logger.dart') ||
            line.contains('_CallerPrinter') ||
            line.contains('log (LogEvent') ||
            line.contains('package:logger')) {
          continue;
        }
        // 找到第一个非 logger/AppLog 的调用
        if (line.contains('.dart')) {
          return _parseStackTraceLine(line);
        }
      }
    } catch (e) {
      // 解析失败时返回空
    }
    return 'unknown';
  }

  /// 解析堆栈行，提取文件名和行号
  String _parseStackTraceLine(String line) {
    // Dart 堆栈格式示例：
    // #2  main (package:my_app/main.dart:5:3)
    // 或
    // #2  main (package:my_app/main.dart:5)

    final regex = RegExp(
      r'\((package:[^:]+\.dart):(\d+)(?::\d+)?\)',
    );
    final match = regex.firstMatch(line);

    if (match != null) {
      final filePath = match.group(1) ?? '';
      final lineNumber = match.group(2) ?? '';

      // 提取简洁的文件名（只保留 lib/ 后面的部分）
      final shortPath = _shortenPath(filePath);
      return '$shortPath:$lineNumber';
    }

    // 备用解析方式
    final simpleRegex = RegExp(r'(\w+\.dart):(\d+)');
    final simpleMatch = simpleRegex.firstMatch(line);
    if (simpleMatch != null) {
      return '${simpleMatch.group(1)}:${simpleMatch.group(2)}';
    }

    return line.trim();
  }

  /// 缩短文件路径，只保留 lib/ 之后的部分
  String _shortenPath(String path) {
    if (path.startsWith('package:')) {
      // package:my_app/lib/main.dart -> lib/main.dart
      final parts = path.split('/');
      // 找到 lib 目录的位置
      final libIndex = parts.indexOf('lib');
      if (libIndex >= 0 && libIndex < parts.length - 1) {
        return parts.sublist(libIndex).join('/');
      }
      // 如果没有 lib，返回 package 后的最后几部分
      if (parts.length > 2) {
        return parts.sublist(parts.length - 2).join('/');
      }
    }
    return path;
  }
}

/// 应用日志工具类
///
/// 提供统一的日志管理，支持不同环境和日志级别的配置。
/// 在开发环境下输出详细日志，生产环境下可选择关闭或减少日志输出。
///
/// 特性：
/// - 自动显示调用位置（文件名:行号）
/// - 支持 Debug/Release 模式自动切换
/// - 支持多种日志级别
/// - 支持带标签的日志输出
/// - 支持网络请求专用格式
class AppLog {
  AppLog._();

  /// 全局 Logger 实例（带调用位置和堆栈）
  static final Logger _logger = Logger(
    printer: _CallerPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 100,
      colors: true,
      printEmojis: true,
    ),
    level: kDebugMode ? Level.all : Level.warning,
  );

  /// 简洁输出的 Logger 实例（只显示调用位置，不显示堆栈）
  static final Logger _simpleLogger = Logger(
    printer: _CallerPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
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

  /// 简洁的调试日志（不显示方法堆栈，只显示调用位置）
  ///
  /// 适用于简单的日志输出场景
  static void d(dynamic message) {
    if (!_enabled) return;
    _simpleLogger.d(message);
  }

  /// 简洁的信息日志（不显示方法堆栈，只显示调用位置）
  ///
  /// 适用于简单的日志输出场景
  static void i(dynamic message) {
    if (!_enabled) return;
    _simpleLogger.i(message);
  }

  /// 简洁的警告日志（不显示方法堆栈，只显示调用位置）
  ///
  /// 适用于简单的日志输出场景
  static void w(dynamic message) {
    if (!_enabled) return;
    _simpleLogger.w(message);
  }

  /// 简洁的错误日志（不显示方法堆栈，只显示调用位置）
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

    final callerInfo = _getCallerInfoSimple();
    final buffer = StringBuffer();
    buffer.writeln('┌────────────────────────────────────────────────────────────────');
    buffer.writeln('│ ${isError ? "❌" : "🚀"} NETWORK: $method $url');
    buffer.writeln('│ 📍 $callerInfo');
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

  /// 简单获取调用者信息（用于 network 方法）
  static String _getCallerInfoSimple() {
    try {
      final stackTrace = StackTrace.current.toString();
      final lines = stackTrace.split('\n');

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.contains('app_log.dart') ||
            line.contains('_getCallerInfoSimple') ||
            line.contains('network (')) {
          continue;
        }
        if (line.contains('.dart')) {
          return _parseStackTraceLine(line);
        }
      }
    } catch (e) {
      // ignore
    }
    return 'unknown';
  }

  /// 解析堆栈行，提取文件名和行号
  static String _parseStackTraceLine(String line) {
    final regex = RegExp(
      r'\((package:[^:]+\.dart):(\d+)(?::\d+)?\)',
    );
    final match = regex.firstMatch(line);

    if (match != null) {
      final filePath = match.group(1) ?? '';
      final lineNumber = match.group(2) ?? '';
      final shortPath = _shortenPath(filePath);
      return '$shortPath:$lineNumber';
    }

    final simpleRegex = RegExp(r'(\w+\.dart):(\d+)');
    final simpleMatch = simpleRegex.firstMatch(line);
    if (simpleMatch != null) {
      return '${simpleMatch.group(1)}:${simpleMatch.group(2)}';
    }

    return line.trim();
  }

  /// 缩短文件路径
  static String _shortenPath(String path) {
    if (path.startsWith('package:')) {
      final parts = path.split('/');
      final libIndex = parts.indexOf('lib');
      if (libIndex >= 0 && libIndex < parts.length - 1) {
        return parts.sublist(libIndex).join('/');
      }
      if (parts.length > 2) {
        return parts.sublist(parts.length - 2).join('/');
      }
    }
    return path;
  }

  /// 截断过长的字符串
  static String _truncate(String text, {int maxLength = 500}) {
    if (text.length > maxLength) {
      return '${text.substring(0, maxLength)}... (truncated)';
    }
    return text;
  }
}