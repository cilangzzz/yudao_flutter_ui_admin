import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'router/app_router.dart' show initializeRouter;

void main() {
  // 初始化路由系统
  // initializeRouter();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}