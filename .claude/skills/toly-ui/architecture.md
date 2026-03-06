# TolyUI 项目架构指南

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── app/                         # 核心应用模块
│   ├── logic/                   # 业务逻辑
│   │   └── app_state/           # 应用状态管理
│   │       ├── app_logic.dart   # AppLogic (Cubit)
│   │       └── app_state.dart   # AppState (状态模型)
│   ├── theme/                   # 主题配置
│   │   ├── theme.dart           # lightTheme, darkTheme
│   │   └── code_theme.dart      # 代码高亮主题
│   ├── view/                    # 应用级视图
│   │   └── app_scope.dart       # MultiBlocProvider
│   └── res/                     # 资源文件
│       └── toly_icon.dart       # 图标定义
├── components/                  # 公共组件
│   ├── code_display.dart        # 代码展示组件
│   └── node_display.dart        # 节点展示组件
├── navigation/                  # 导航系统
│   ├── router/                  # 路由配置
│   │   ├── app_router.dart      # 主路由
│   │   ├── widgets_route.dart   # 组件路由
│   │   └── guide_route.dart     # 指南路由
│   ├── menu/                    # 菜单定义
│   │   ├── basic.dart           # 基础组件菜单
│   │   ├── form.dart            # 表单组件菜单
│   │   └── ...                  # 其他分类菜单
│   └── view/                    # 导航视图
│       ├── app_navigation_scope.dart
│       └── desk_top_bar.dart
├── view/                        # 页面视图
│   ├── home_page/               # 首页
│   ├── widgets/                 # 组件展示页
│   ├── guide/                   # 指南页
│   └── sponsor/                 # 赞助页
└── incubator/                   # 实验性组件

modules/                         # 本地组件包
├── basic/                       # 基础组件
│   ├── tolyui_rx_layout/        # 响应式布局
│   └── tolyui_text/             # 高亮文本
├── data/                        # 数据展示组件
│   ├── tolyui_table/            # 表格
│   ├── tolyui_tree/             # 树形
│   ├── tolyui_watermark/        # 水印
│   └── ...
├── feedback/                    # 反馈组件
├── form/                        # 表单组件
├── navigation/                  # 导航组件
└── tolyui/                      # 主包发布
```

## 核心架构模式

### 1. 状态管理模式

项目使用 BLoC/Cubit 模式进行状态管理：

```dart
// 状态定义
class AppState extends Equatable {
  final ThemeMode themeMode;

  const AppState({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];

  AppState copyWith({ThemeMode? themeMode}) =>
      AppState(themeMode: themeMode ?? this.themeMode);
}

// 逻辑控制
class AppLogic extends Cubit<AppState> {
  AppLogic() : super(AppState(themeMode: ThemeMode.light));

  void changeThemeMode(ThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
  }

  void toggleThemeModel(bool isDark) {
    changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
```

**使用方式：**

```dart
// 提供状态
class AppScope extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppLogic>(create: (_) => AppLogic()),
      ],
      child: child,
    );
  }
}

// 消费状态
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppState state = context.watch<AppLogic>().state;
    return MaterialApp(
      themeMode: state.themeMode,
      ...
    );
  }
}
```

### 2. 路由架构

使用 GoRouter 实现声明式路由：

```dart
// 路由枚举
enum AppRoute {
  root('/', '/'),
  home('home', '/home'),
  sponsor('sponsor', '/sponsor'),
  error('404', '/404');

  final String path;
  final String name;
  const AppRoute(this.name, this.path);

  void go(BuildContext context) => context.go(path);
}

// 路由配置
RouteBase get appRoutes => GoRoute(
  path: AppRoute.root.name,
  redirect: _widgetHome,
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppNavigationScope(child: child),
      routes: [
        GoRoute(path: 'home', builder: (c, s) => HomePage()),
        GoRoute(path: 'sponsor', builder: (c, s) => SponsorPage()),
        widgetsRoute,
        guideRoute,
      ],
    ),
    GoRoute(path: '404', builder: (c, s) => Widget404()),
  ],
);
```

**ShellRoute 的作用：**
- 保持导航栏在页面切换时不重建
- 共享布局组件
- 支持嵌套路由

### 3. 响应式架构

```dart
// 响应式断点定义
enum Rx { xs, sm, md, lg, xl }

// 断点解析策略
RxParserStrategy defaultParserStrategy = (double width) {
  if (width < 768) return Rx.xs;
  if (width < 992) return Rx.sm;
  if (width < 1200) return Rx.md;
  if (width < 1920) return Rx.lg;
  return Rx.xl;
};

// 通过主题扩展配置
ThemeData(
  extensions: [
    ReParserStrategyTheme(parserStrategy: defaultParserStrategy),
  ],
)
```

### 4. 组件展示系统

```dart
// 注解标记
@DisplayNode(
  title: '填充样式',
  desc: '按钮的填充样式描述...',
)
class ButtonDemo1 extends StatelessWidget { ... }

// 生成的映射文件
Map<String, dynamic> queryDisplayNodes(String name) {
  return switch(name) {
    "button" => _buttonData,
    "input" => _inputData,
    ...
  };
}

Widget widgetDisplayMap(String key) {
  return switch(key) {
    "ButtonDemo1" => const ButtonDemo1(),
    "ButtonDemo2" => const ButtonDemo2(),
    ...
  };
}
```

### 5. 菜单配置系统

```dart
Map<String, dynamic> get basicMenus => {
  'path': '/widgets/basic',
  'icon': Icons.calendar_view_day_rounded,
  'label': 'Basic 基础组件',
  'children': [
    {
      'path': '/button',
      'label': 'Button',
      'subtitle': '按钮',
      'isFlutter': true,  // 标记为 Flutter 原生组件
    },
    {
      'path': '/action',
      'label': 'Action',
      'subtitle': '动作',
      'tag': '新',  // 标签显示
    },
  ]
};
```

## 关键设计模式

### 1. 依赖注入

```dart
// 通过 MultiBlocProvider 注入
MultiBlocProvider(
  providers: [
    BlocProvider<AppLogic>(create: (_) => AppLogic()),
    BlocProvider<OtherLogic>(create: (_) => OtherLogic()),
  ],
  child: child,
)
```

### 2. 组合模式

```dart
// NodeDisplay 组合 CodeDisplay
class NodeDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding$(
      padding: (re) => ...,
      child: Column(
        children: [
          TitleShow(title: node.title, desc: node.desc),
          CodeDisplay(display: display, code: node.code),
        ],
      ),
    );
  }
}
```

### 3. 工厂模式

```dart
// TreeNode 工厂构造
factory TreeNode.fromMap(dynamic map, {T Function(dynamic)? dataParser}) {
  return TreeNode<T>(
    id: map['id']?.toString() ?? '',
    data: dataParser != null ? dataParser(map['data']) : map['data'],
    children: (map['children'] as List)
        .map((child) => TreeNode<T>.fromMap(child, dataParser: dataParser))
        .toList(),
  );
}
```

### 4. 构建器模式

```dart
// WindowRespondBuilder
typedef RxWidgetBuilder = Widget Function(BuildContext context, Rx type);

class WindowRespondBuilder extends StatelessWidget {
  final RxWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, cts) => builder(context, strategy(cts.maxWidth)),
    );
  }
}
```

## 热重载支持

```dart
@override
void reassemble() {
  super.reassemble();
  // 保存当前路径，重建路由器以支持热重载
  final currentPath = _router.routerDelegate.currentConfiguration.uri.toString();
  _router = GoRouter(
    initialLocation: currentPath,
    routes: <RouteBase>[appRoutes],
  );
}
```

## 滚动位置保持

```dart
class _WidgetDisplayPageState extends State<WidgetDisplayPage>
    with AutomaticKeepAliveClientMixin {
  static final Map<String, double> _scrollPositions = {};
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final savedPosition = _scrollPositions[widget.name] ?? 0.0;
    _scrollController = ScrollController(initialScrollOffset: savedPosition);
    _scrollController.addListener(_saveScrollPosition);
  }

  void _saveScrollPosition() {
    if (_scrollController.hasClients) {
      _scrollPositions[widget.name] = _scrollController.offset;
    }
  }

  @override
  bool get wantKeepAlive => true;
}
```