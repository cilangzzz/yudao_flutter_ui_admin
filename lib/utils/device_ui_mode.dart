import 'package:flutter/material.dart';

/// UI 显示模式
enum UIMode {
  /// 移动端 (宽度 < 768)
  mobile,

  /// 平板 (宽度 >= 768 && < 1200)
  tablet,

  /// 桌面端 (宽度 >= 1200)
  desktop,
}

/// 响应式断点配置
class Breakpoints {
  Breakpoints._();

  /// sm: 移动端/平板分界点
  static const double sm = 768;

  /// lg: 平板/桌面分界点
  static const double lg = 1200;

  /// 判断是否为移动端
  static bool isMobile(double width) => width < sm;

  /// 判断是否为平板
  static bool isTablet(double width) => width >= sm && width < lg;

  /// 判断是否为桌面端
  static bool isDesktop(double width) => width >= lg;

  /// 根据宽度获取 UI 模式
  static UIMode getUIMode(double width) {
    if (isMobile(width)) return UIMode.mobile;
    if (isTablet(width)) return UIMode.tablet;
    return UIMode.desktop;
  }
}

/// 设备 UI 模式判断工具
///
/// 提供便捷的方法来判断当前设备需要显示的 UI 模式
/// 支持通过 BuildContext 或直接的宽度值进行判断
class DeviceUIMode {
  DeviceUIMode._();

  /// 从 BuildContext 获取当前 UI 模式
  ///
  /// ```dart
  /// final mode = DeviceUIMode.of(context);
  /// if (mode == UIMode.mobile) {
  ///   // 显示移动端布局
  /// }
  /// ```
  static UIMode of(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Breakpoints.getUIMode(width);
  }

  /// 从 BuildContext 获取当前屏幕宽度
  static double widthOf(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// 从 BuildContext 获取当前屏幕高度
  static double heightOf(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// 判断当前是否为移动端
  static bool isMobile(BuildContext context) {
    return Breakpoints.isMobile(widthOf(context));
  }

  /// 判断当前是否为平板
  static bool isTablet(BuildContext context) {
    return Breakpoints.isTablet(widthOf(context));
  }

  /// 判断当前是否为桌面端
  static bool isDesktop(BuildContext context) {
    return Breakpoints.isDesktop(widthOf(context));
  }

  /// 根据当前 UI 模式返回不同的值
  ///
  /// ```dart
  /// final columns = DeviceUIMode.select(
  ///   context,
  ///   mobile: () => 1,
  ///   tablet: () => 2,
  ///   desktop: () => 3,
  /// );
  /// ```
  static T select<T>(
    BuildContext context, {
    required T Function() mobile,
    T Function()? tablet,
    T Function()? desktop,
  }) {
    final mode = of(context);
    switch (mode) {
      case UIMode.mobile:
        return mobile();
      case UIMode.tablet:
        return tablet != null ? tablet() : mobile();
      case UIMode.desktop:
        return desktop != null ? desktop() : (tablet != null ? tablet() : mobile());
    }
  }

  /// 根据当前 UI 模式返回不同的 Widget
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return DeviceUIMode.builder(
  ///     context,
  ///     mobile: (context) => MobileLayout(),
  ///     tablet: (context) => TabletLayout(),
  ///     desktop: (context) => DesktopLayout(),
  ///   );
  /// }
  /// ```
  static Widget builder(
    BuildContext context, {
    required Widget Function(BuildContext context) mobile,
    Widget Function(BuildContext context)? tablet,
    Widget Function(BuildContext context)? desktop,
  }) {
    final mode = of(context);
    switch (mode) {
      case UIMode.mobile:
        return mobile(context);
      case UIMode.tablet:
        return tablet != null ? tablet(context) : mobile(context);
      case UIMode.desktop:
        if (desktop != null) return desktop(context);
        if (tablet != null) return tablet(context);
        return mobile(context);
    }
  }

  /// 响应式布局构建器
  ///
  /// 当屏幕尺寸变化时自动重建
  /// ```dart
  /// DeviceUIMode.layoutBuilder(
  ///   builder: (context, mode) {
  ///     return Text('当前模式: $mode');
  ///   },
  /// )
  /// ```
  static Widget layoutBuilder({
    required Widget Function(BuildContext context, UIMode mode) builder,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mode = Breakpoints.getUIMode(constraints.maxWidth);
        return builder(context, mode);
      },
    );
  }
}

/// 响应式值容器
///
/// 用于存储不同 UI 模式下的值
/// ```dart
/// final padding = ResponsiveValue(
///   mobile: EdgeInsets.all(8),
///   tablet: EdgeInsets.all(16),
///   desktop: EdgeInsets.all(24),
/// );
///
/// // 在 build 方法中使用
/// final value = padding.of(context);
/// ```
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// 根据当前 UI 模式获取对应的值
  T of(BuildContext context) {
    return DeviceUIMode.select(
      context,
      mobile: () => mobile,
      tablet: () => tablet ?? mobile,
      desktop: () => desktop ?? tablet ?? mobile,
    );
  }

  /// 根据宽度获取对应的值
  T fromWidth(double width) {
    final mode = Breakpoints.getUIMode(width);
    switch (mode) {
      case UIMode.mobile:
        return mobile;
      case UIMode.tablet:
        return tablet ?? mobile;
      case UIMode.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}