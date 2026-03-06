# Flutter 多环境配置切换 Skill

## 功能描述

为 Flutter 项目实现类似 Spring Boot Profile 风格的多环境配置切换机制，支持：
- 主配置文件指定激活环境
- 环境特定配置文件
- 变量占位符 `${variable}` 语法

## 实现方案

### 1. 配置文件结构

```
config/
├── application.yaml          # 主配置文件
├── application-dev.yaml      # 开发环境
├── application-test.yaml     # 测试环境
└── application-prod.yaml     # 生产环境
```

### 2. 主配置文件示例 (application.yaml)

```yaml
cry:
  profiles:
    active: dev    # 切换环境：dev/test/prod
  api:
    baseUrl: ${api.baseUrl}
    connectTimeout: 10000
    receiveTimeout: 3000
  logger:
    level: ${logger.level}
```

### 3. 环境配置文件示例 (application-dev.yaml)

```yaml
api.baseUrl: http://dev.example.com/api/
logger.level: debug
```

### 4. pubspec.yaml 配置

```yaml
flutter:
  assets:
    - config/
```

### 5. 核心实现代码

```dart
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class ApplicationContext {
  ApplicationContext._();
  static ApplicationContext? _instance;
  static ApplicationContext get instance => _getInstance();

  static ApplicationContext _getInstance() {
    _instance ??= ApplicationContext._();
    return _instance!;
  }

  Map beanMap = {};
  late YamlMap yamlMap;
  late Map variableMap;

  init() async {
    await loadApplication();
    parseCryProperties();
  }

  /// 加载主配置文件
  loadApplication() async {
    var yamlStr = await rootBundle.loadString('config/application.yaml');
    yamlMap = loadYaml(yamlStr);
  }

  /// 解析配置属性
  parseCryProperties() async {
    YamlMap cry = yamlMap.nodes['cry']!.value;
    Map profiles = cry['profiles'].value;
    String? profilesActive = profiles['active'];

    // 加载环境特定配置
    if (profilesActive != null) {
      var profilesStr = await rootBundle.loadString(
        'config/application-$profilesActive.yaml',
      );
      variableMap = loadYaml(profilesStr);
    }

    // 解析配置并替换占位符
    // ... 具体解析逻辑
  }

  /// 变量占位符转换 ${variable} -> value
  MapEntry convertVariable(key, value) {
    var match = RegExp(r'\$\{(.*)\}').firstMatch(value.toString());
    if (match != null) {
      var value2 = variableMap[match.group(1)];
      return MapEntry(key, value2);
    }
    return MapEntry(key, value);
  }

  addBean(String key, object) => beanMap[key] = object;
  getBean(String key) => beanMap[key];
}
```

### 6. 使用方式

```dart
void main() async {
  await ApplicationContext.instance.init();
  // 配置已加载完成
  runApp(MyApp());
}
```

## 切换环境

修改 `application.yaml` 中的 `cry.profiles.active` 值：
- `dev` - 开发环境
- `test` - 测试环境
- `prod` - 生产环境

## 依赖

```yaml
dependencies:
  yaml: ^3.1.0
```

## 参考实现

- cry 包：https://pub.dev/packages/cry
- 源码：https://github.com/cairuoyu/cry