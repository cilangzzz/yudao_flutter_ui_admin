import 'package:flutter/material.dart';

/// 应用主题配置
class AppTheme {
  AppTheme._();

  /// 主色调
  static const Color primaryColor = Color(0xFF1890FF);

  /// 成功色
  static const Color successColor = Color(0xFF52C41A);

  /// 警告色
  static const Color warningColor = Color(0xFFFAAD14);

  /// 错误色
  static const Color errorColor = Color(0xFFF5222D);

  /// 信息色
  static const Color infoColor = Color(0xFF1890FF);

  /// 浅色主题
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    // 使用系统默认字体以支持中文显示
    // fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
      dataRowMinHeight: 48,
      dataRowMaxHeight: 64,
    ),
  );

  /// 深色主题
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    // 使用系统默认字体以支持中文显示
    // fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStateProperty.all(Colors.grey[900]),
      dataRowMinHeight: 48,
      dataRowMaxHeight: 64,
    ),
  );
}