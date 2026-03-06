# Flutter Admin 项目架构设计详解

## 一、目录结构

```
lib/
├── api/                    # API调用层 - 静态方法封装HTTP请求
├── common/                 # 公共组件
│   ├── cry_dio_interceptors.dart  # HTTP拦截器（Token、Loading、错误处理）
│   └── routes.dart                # 路由映射定义
├── constants/              # 常量和枚举定义
├── data/                   # 静态数据和Mock数据
├── generated/              # 国际化生成文件
├── l10n/                   # 国际化资源(arb文件)
├── models/                 # 数据模型
├── pages/                  # UI页面（按业务模块划分）
│   ├── layout/            # 主布局组件
│   ├── dash/              # 仪表板
│   ├── role/              # 角色管理
│   ├── menu/              # 菜单管理
│   ├── dept/              # 部门管理
│   ├── person/            # 人员管理
│   ├── article/           # 文章模块
│   └── ...
├── router/                 # 路由代理实现
├── utils/                 # 工具类
└── main.dart              # 应用入口
```

## 二、路由架构

### 2.1 核心组件

1. **MainRouterDelegate** - 路由代理
   - 继承自 `CryRouterDelegate`
   - 管理页面映射 `pageMap`
   - 权限验证：未登录重定向到 `/login`
   - Tab页自动管理

2. **CryRouteInformationParser** - 路由解析器
   - 解析URL路径到路由配置

3. **Routes** - 路由定义
```dart
class Routes {
  // Layout内嵌页面映射
  static Map<String, Widget> layoutPagesMap = {
    '/dashboard': Dashboard(),
    '/roleList': RoleList(),
    '/menuList': MenuList(),
    // ...
  };

  // 白名单路由（无需登录）
  static List<String> whiteRoutes = ['/register'];
}
```

### 2.2 路由跳转方式

```dart
// 方式1: 使用cry工具库
CryUtil.pushNamed('/roleList');

// 方式2: 使用GetX
Get.toNamed('/roleList');

// 方式3: 替换当前页面
CryUtil.pushNamedAndRemove('/login');
```

## 三、状态管理

### 3.1 全局控制器

```dart
// main.dart
init() async {
  await GetStorage.init();
  Get.put(LayoutController());      // 布局状态
  Get.put(LayoutMenuController());  // 菜单状态
}
```

### 3.2 控制器示例

```dart
class LayoutController extends GetxController {
  MenuDisplayType? menuDisplayType = MenuDisplayType.side;
  bool isMaximize = false;

  void toggleMaximize() {
    isMaximize = !isMaximize;
    update();  // 通知UI刷新
  }
}
```

### 3.3 UI绑定

```dart
// 方式1: GetBuilder
GetBuilder<LayoutController>(
  builder: (_) => _buildWidget()
)

// 方式2: StatefulWidget + setState
setState(() {
  // 更新状态
});
```

## 四、数据模型设计

### 4.1 标准模型结构

```dart
class Role {
  String? id;
  String? name;
  String? description;

  // 构造函数
  Role({this.id, this.name, this.description});

  // copyWith方法
  Role copyWith({String? id, String? name, String? description}) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  // 序列化
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
  };

  factory Role.fromMap(Map<String, dynamic> map) => Role(
    id: map['id'],
    name: map['name'],
    description: map['description'],
  );
}
```

### 4.2 树形数据模型

```dart
class Menu extends TreeData {
  String? id;
  String? pid;  // 父ID，用于构建树
  String? name;
  String? url;
  List<Menu>? children;

  // 转换为Tab页
  TabPage toTabPage() => TabPage(id: id, name: name, url: url);
}
```

## 五、API调用模式

### 5.1 API层设计

```dart
class RoleApi {
  // 分页查询
  static Future<ResponseBodyApi> page(data) =>
    HttpUtil.post('/role/page', data: data);

  // 保存或更新
  static Future<ResponseBodyApi> saveOrUpdate(data) =>
    HttpUtil.post('/role/saveOrUpdate', data: data);

  // 批量删除
  static Future<ResponseBodyApi> removeByIds(data) =>
    HttpUtil.post('/role/removeByIds', data: data);
}
```

### 5.2 HTTP拦截器

```dart
class CryDioInterceptors extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 1. 添加Token
    String? token = StoreUtil.read(Constant.KEY_TOKEN);
    options.headers[HttpHeaders.authorizationHeader] = token;
    // 2. 显示Loading
    CryUtil.loading();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    CryUtil.loaded();
    ResponseBodyApi responseBodyApi = ResponseBodyApi.fromMap(response.data);

    // Session过期处理
    if (responseBodyApi.code == ResponseCodeConstant.SESSION_EXPIRE_CODE) {
      Utils.logout();
      CryUtil.pushNamedAndRemove('/login');
    }
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    CryUtil.loaded();
    CryUtil.message('服务器忙，请稍后再试');
    handler.next(err);
  }
}
```

### 5.3 请求/响应模型

```dart
// 请求体
class RequestBodyApi {
  int page = 1;
  int size = 10;
  Map<String, dynamic>? condition;

  Map<String, dynamic> toMap() => {
    'page': page,
    'size': size,
    'condition': condition,
  };
}

// 响应体
class ResponseBodyApi {
  int? code;
  String? message;
  dynamic data;

  factory ResponseBodyApi.fromMap(Map<String, dynamic> map) => ...
}
```



## 七、数据流完整流程

```
┌─────────────────────────────────────────────────────────────┐
│                    完整数据流程                              │
└─────────────────────────────────────────────────────────────┘

1. 页面初始化
   ┌──────────────┐
   │ Page.initState│ ──→ _query()
   └──────────────┘

2. 构建请求
   ┌──────────────┐     ┌───────────────┐
   │ RequestBodyApi│ ──→ │ toMap()       │
   └──────────────┘     └───────────────┘

3. API调用
   ┌──────────────┐     ┌───────────────┐     ┌─────────────────┐
   │ XxxApi.page() │ ──→ │ HttpUtil.post │ ──→ │ Dio.request     │
   └──────────────┘     └───────────────┘     └─────────────────┘
                                                      │
                                        ┌─────────────▼─────────────┐
                                        │ CryDioInterceptors       │
                                        │  - 添加Token              │
                                        │  - 显示Loading            │
                                        └──────────────────────────┘

4. 后端响应
   ┌──────────────────┐     ┌─────────────────┐
   │ Response(data)   │ ──→ │ ResponseBodyApi │
   └──────────────────┘     └─────────────────┘
                               │
                 ┌─────────────▼─────────────┐
                 │ 拦截器处理:               │
                 │  - 隐藏Loading            │
                 │  - Session过期检查        │
                 │  - 错误处理               │
                 └──────────────────────────┘

5. 数据转换
   ┌─────────────────┐     ┌─────────────────┐
   │ responseBody.data│ ──→ │ Model.fromMap() │
   └─────────────────┘     └─────────────────┘

6. UI更新
   ┌─────────────────┐     ┌─────────────────┐
   │ setState()      │ ──→ │ Widget.build()  │
   └─────────────────┘     └─────────────────┘
```

## 八、本地存储

```dart
class StoreUtil {
  // 读取
  static T? read<T>(String key) => GetStorage().read<T>(key);

  // 写入
  static Future<void> write(String key, dynamic value) =>
    GetStorage().write(key, value);

  // 删除
  static Future<void> remove(String key) => GetStorage().remove(key);
}

// 常用Key
class Constant {
  static const String KEY_TOKEN = "token";
  static const String KEY_MENU_LIST = "menuList";
  static const String KEY_CURRENT_USER_INFO = "currentUserInfo";
  static const String KEY_OPENED_TAB_PAGE_LIST = "openedTabPageList";
}
```

## 九、国际化

```dart
// 使用方式
Text(S.of(context).role_name)

// arb文件定义 (l10n/intl_*.arb)
{
  "role_name": "角色名称",
  "@role_name": {
    "description": "角色名称"
  }
}
```