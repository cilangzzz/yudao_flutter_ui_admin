# Flutter Admin 项目记忆

## 项目概述
这是一个基于Flutter实现的Web管理端项目，位于 `h:\basePlatform\flutter_admin\flutter_admin`

## 核心技术栈
- **Flutter 3.29**
- **状态管理**: GetX
- **路由**: Navigator 2.0 + GetX混合方案
- **HTTP**: Dio + 自定义拦截器
- **本地存储**: GetStorage
- **核心依赖**: cry (自研工具库)

## 架构文件索引
详细架构设计请参考: [architecture.md](architecture.md)

## 快速开发指南
详见: [development-skill.md](development-skill.md)

## 关键目录
- `lib/api/` - API调用层
- `lib/models/` - 数据模型
- `lib/pages/` - UI页面（按业务模块划分）
- `lib/common/` - 公共组件（路由、拦截器）
- `lib/utils/` - 工具类
- `lib/router/` - 路由代理

## 开发约定
1. 新增页面需在 `Routes.layoutPagesMap` 中注册
2. API调用统一使用 `XxxApi` 静态方法
3. 数据模型需实现 `toMap/fromMap` 序列化
4. 状态更新使用 `GetBuilder` 或 `setState`