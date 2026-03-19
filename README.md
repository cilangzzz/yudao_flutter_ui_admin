# Yudao Flutter UI Admin

芋道管理后台的 Flutter UI 实现，基于 Flutter 3.8+ 开发的跨平台后台管理系统。

## 项目简介

本项目是 [yudao-cloud](https://github.com/YunaiV/yudao-cloud) 后台管理系统的 Flutter 客户端实现，支持 Android、iOS、Web、Windows、macOS、Linux 多平台运行。

### 相关项目

- 后端项目：[yudao-cloud](https://github.com/YunaiV/yudao-cloud)
- Vue 版本：[yudao-ui-admin-vue3](https://github.com/yudaocode/yudao-ui-admin-vue3)

## 功能特性

### 系统管理

| 功能 | 说明 |
|------|------|
| 用户管理 | 用户增删改查、分配角色、重置密码 |
| 角色管理 | 角色管理、分配菜单权限、数据权限 |
| 菜单管理 | 菜单配置、权限标识、按钮权限 |
| 部门管理 | 部门树形结构管理 |
| 岗位管理 | 岗位字典管理 |
| 字典管理 | 字典类型和字典数据管理 |
| 地区管理 | 行政区划管理 |

### 租户管理

| 功能 | 说明 |
|------|------|
| 租户列表 | 多租户管理 |
| 租户套餐 | 租户套餐配置 |

### 消息管理

| 功能 | 说明 |
|------|------|
| 通知公告 | 系统公告发布与管理 |
| 站内信 | 通知模板、我的站内信 |
| 邮件管理 | 邮箱账号、邮件模板、邮件日志 |
| 短信管理 | 短信渠道、短信模板、短信日志 |

### 日志管理

| 功能 | 说明 |
|------|------|
| 登录日志 | 用户登录记录查询 |
| 操作日志 | 用户操作审计 |

### OAuth2 管理

| 功能 | 说明 |
|------|------|
| OAuth2 应用 | 客户端管理 |
| OAuth2 令牌 | Token 管理 |

### 基础设施

| 功能 | 说明 |
|------|------|
| 参数配置 | 系统参数管理 |
| 数据源配置 | 多数据源管理 |
| 文件管理 | 文件上传、文件配置 |
| 定时任务 | 定时任务管理、任务日志 |
| 代码生成 | 数据库表导入、代码预览 |
| API 日志 | 访问日志、错误日志 |

### 监控管理

| 功能 | 说明 |
|------|------|
| Druid 监控 | 数据库连接池监控 |
| Redis 监控 | Redis 状态监控 |
| 服务器监控 | 服务器状态监控 |
| Skywalking | 链路追踪 |

## 技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| 框架 | Flutter | ^3.8.0 |
| 状态管理 | Riverpod | ^2.6.1 |
| 路由 | GoRouter | ^14.6.2 |
| HTTP | Dio | ^5.7.0 |
| 本地存储 | flutter_secure_storage | ^9.2.2 |
| 本地存储 | shared_preferences | ^2.3.3 |
| 国际化 | intl | ^0.20.2 |
| JSON 序列化 | json_annotation | ^4.9.0 |
| 数据类 | freezed_annotation | ^2.4.4 |
| 日志 | logger | ^2.5.0 |
| 自适应布局 | flutter_adaptive_scaffold | ^0.3.1 |
| 数据表格 | data_table_2 | ^2.5.18 |

## 快速开始

### 环境要求

- Flutter SDK ^3.8.0
- Dart SDK ^3.8.0

### 安装与运行

```bash
# 1. 克隆项目
git clone https://github.com/your-username/yudao_flutter_ui_admin.git

# 2. 进入项目目录
cd yudao_flutter_ui_admin

# 3. 安装依赖
flutter pub get

# 4. 运行项目
flutter run
```

### 构建发布版本

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 项目结构

```
lib/
├── api/                    # API 调用层
│   ├── core/               # 核心 API (认证)
│   ├── infra/              # 基础设施 API
│   └── system/             # 系统管理 API
├── app/                    # 应用配置
│   ├── core/               # 核心配置 (常量、拦截器)
│   └── theme/              # 主题配置
├── i18n/                   # 国际化
├── layout/                 # 主布局组件
├── models/                 # 数据模型
│   ├── common/             # 通用模型 (API响应、分页)
│   ├── core/               # 核心模型 (认证相关)
│   ├── infra/              # 基础设施模型
│   └── system/             # 系统管理模型
├── pages/                  # UI 页面
│   ├── auth/               # 认证页面 (登录)
│   ├── dashboard/          # 仪表板
│   ├── infra/              # 基础设施模块
│   └── system/             # 系统管理模块
├── router/                 # 路由系统
├── stores/                 # 状态管理
│   ├── access_store.dart   # 认证状态
│   ├── user_store.dart     # 用户信息状态
│   ├── dict_store.dart     # 字典状态
│   └── tab_store.dart      # Tab 状态
└── main.dart               # 应用入口
```

## 核心架构

### 分层架构

```
┌─────────────────────────────────────────────────┐
│                    UI Layer                      │
│            (pages/ - Widget 组件)                │
├─────────────────────────────────────────────────┤
│               State Management                   │
│        (stores/ - Riverpod Provider)             │
├─────────────────────────────────────────────────┤
│                 API Layer                        │
│        (api/ - ApiClient 封装)                   │
├─────────────────────────────────────────────────┤
│               Data Models                        │
│        (models/ - 数据模型、JSON序列化)          │
├─────────────────────────────────────────────────┤
│                Core/Config                       │
│        (app/core/ - 常量、拦截器、主题)          │
└─────────────────────────────────────────────────┘
```

### 状态管理

项目使用 **Riverpod** 进行全局状态管理：

| Store | 说明 |
|-------|------|
| AccessStore | 认证状态（Token、权限、菜单） |
| UserStore | 用户信息状态 |
| DictStore | 字典数据缓存 |
| TabStore | Tab 页签管理 |

### 路由系统

使用 **GoRouter** 实现声明式路由：

- 支持 ShellRoute 实现嵌套布局
- 完整的路由守卫机制（登录验证、权限检查）
- 支持动态路由参数

### HTTP 请求

基于 **Dio** 封装的 ApiClient，包含以下拦截器：

- **AuthInterceptor** - Token 自动注入
- **ErrorInterceptor** - 统一错误处理
- **LogInterceptor** - 请求日志记录

### 权限控制

基于权限标识的路由守卫：

```dart
// 权限检查
if (accessStore.hasPermission('system:user:create')) {
  // 显示创建按钮
}
```

## 配置说明

### API 基础配置

修改 `lib/app/core/constants/api_constants.dart`：

```dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:48080/admin-api';
  static const String tenantId = '1';
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}
```

## 开发指南

### 添加新页面

1. 在 `lib/pages/` 下创建页面目录
2. 创建页面 Widget
3. 在 `lib/router/route_registry.dart` 注册路由

### 添加新 API

1. 在 `lib/models/` 下创建数据模型
2. 在 `lib/api/` 下创建 API 类
3. 运行代码生成：

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 代码生成

项目使用 `build_runner` 进行代码生成：

```bash
# 一次性生成
flutter pub run build_runner build --delete-conflicting-outputs

# 持续监听生成
flutter pub run build_runner watch --delete-conflicting-outputs
```

## 响应式布局

项目支持多端自适应：

- **移动端**：Drawer 抽屉菜单 + BottomNavigationBar
- **平板/桌面端**：NavigationRail 侧边栏 + Tab 页签

```dart
// 设备检测
final uiMode = DeviceUIMode.get(context);
if (uiMode == DeviceUIMode.mobile) {
  // 移动端布局
} else {
  // 桌面端布局
}
```

## 国际化

项目支持中文和英文，翻译文件位于 `assets/i18n/` 目录。

使用方式：

```dart
Text(S.current.login_title)
```

## 许可证

[MIT License](LICENSE)

## 致谢

- [yudao-cloud](https://github.com/YunaiV/yudao-cloud) - 后端项目
- [Flutter](https://flutter.dev) - UI 框架
- [Riverpod](https://riverpod.dev) - 状态管理
- [GoRouter](https://pub.dev/packages/go_router) - 路由管理