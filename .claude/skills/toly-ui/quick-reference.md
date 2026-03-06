# TolyUI 快速参考

## 导入依赖

```yaml
# pubspec.yaml
dependencies:
  tolyui: 0.0.2+19
  tolyui_text:
    path: modules/basic/tolyui_text
  tolyui_table:
    path: modules/data/tolyui_table
  # ... 其他模块
```

## 常用代码片段

### 创建新组件 Demo

```dart
import 'package:flutter/material.dart';
import 'package:tolyui/tolyui.dart';
import '../../display_nodes/display_nodes.dart';

@DisplayNode(
  title: '组件标题',
  desc: '组件描述说明',
)
class YourDemo1 extends StatelessWidget {
  const YourDemo1({super.key});

  @override
  Widget build(BuildContext context) {
    return YourWidget();
  }
}
```

### 响应式布局

```dart
// 方式1: WindowRespondBuilder
WindowRespondBuilder(
  builder: (_, r) {
    if (r.index > 1) return DesktopUI();
    return MobileUI();
  },
)

// 方式2: Padding$
Padding$(
  padding: (r) => switch (r) {
    Rx.xs => EdgeInsets.all(12),
    Rx.md => EdgeInsets.all(24),
    Rx.xl => EdgeInsets.all(48),
    _ => EdgeInsets.all(16),
  },
  child: YourWidget(),
)

// 方式3: 条件渲染
WindowRespondBuilder(
  builder: (_, r) => Row(
    children: [
      if (r.index > 1) SideMenu(),  // 仅桌面端显示
      Expanded(child: Content()),
    ],
  ),
)
```

### 主题切换

```dart
// 获取当前主题模式
ThemeMode mode = context.watch<AppLogic>().state.themeMode;

// 切换主题
context.read<AppLogic>().toggleThemeModel(isDark);
```

### 路由导航

```dart
// 声明式跳转
context.go('/widgets/basic/button');

// 通过枚举跳转
AppRoute.home.go(context);

// 获取路由参数
GoRouterState state = GoRouterState.of(context);
String? id = state.uri.queryParameters['id'];
```

### 状态管理

```dart
// 定义状态
class YourState extends Equatable {
  final int count;
  const YourState({this.count = 0});

  @override
  List<Object?> get props => [count];

  YourState copyWith({int? count}) =>
      YourState(count: count ?? this.count);
}

// 定义逻辑
class YourLogic extends Cubit<YourState> {
  YourLogic() : super(YourState());

  void increment() => emit(state.copyWith(count: state.count + 1));
}

// 使用
context.read<YourLogic>().increment();
int count = context.watch<YourState>().count;
```

### 消息提示

```dart
$message.success(message: '操作成功!');
$message.error(message: '操作失败!');
$message.warning(message: '警告信息');
$message.info(message: '提示信息');
```

### 折叠面板

```dart
// 基础用法
TolyCollapse(
  title: Text('标题'),
  content: YourContent(),
)

// 外部控制
final controller = CollapseController();
TolyCollapse(
  controller: controller,
  title: Text('标题'),
  content: YourContent(),
);
// 控制
controller.toggle();
controller.open();
controller.close();
```

### 树形组件

```dart
TolyTree<String>(
  nodes: [
    TreeNode(id: '1', data: '根节点', children: [
      TreeNode(id: '1-1', data: '子节点'),
    ]),
  ],
  nodeBuilder: (node) => Text(node.data),
  onTap: (node) => print('点击: ${node.id}'),
  showConnectingLines: true,
)
```

### 表格组件

```dart
TolyTableV1<User>(
  columns: [
    TableColumn(title: '姓名', dataIndex: (u) => u.name),
    TableColumn(title: '年龄', dataIndex: (u) => u.age),
  ],
  dataSource: users,
  bordered: true,
)
```

### 水印组件

```dart
TolyWatermark(
  content: '机密文档',
  child: YourContent(),
)
```

### 骨架屏

```dart
TolySkeleton(
  loading: isLoading,
  active: true,
  avatar: true,
  child: YourContent(),
)
```

### 轮播图

```dart
TolyCarousel(
  children: [Widget1(), Widget2()],
  autoplay: true,
  dots: true,
)
```

### 时间线

```dart
TolyTimeline(
  items: [
    TimelineItemData(title: Text('步骤1'), content: '描述'),
    TimelineItemData(title: Text('步骤2'), content: '描述'),
  ],
)
```

### 高亮文本

```dart
HighlightText.withArg(
  '搜索结果中高亮显示关键词',
  arg: '关键词',
  highlightStyle: TextStyle(color: Colors.blue),
)
```

## 菜单结构

```dart
Map<String, dynamic> get yourMenus => {
  'path': '/widgets/your-category',
  'label': 'Your Category',
  'children': [
    {'path': '/your-component', 'label': 'YourComponent'},
  ],
};
```

## 路由注册

```dart
// 在 widgets_route.dart 中添加
GoRoute(
  path: 'your-category',
  routes: [
    _customRoute('your-component'),
  ],
),
```

## 常见问题

### Q: 如何添加新组件分类？
1. 在 `lib/navigation/menu/` 创建菜单文件
2. 在 `lib/view/widgets/` 创建对应目录
3. 在 `widget_menus.dart` 中导入菜单
4. 在 `widgets_route.dart` 中添加路由

### Q: 如何保持页面状态？
使用 `AutomaticKeepAliveClientMixin`：
```dart
class _YourPageState extends State<YourPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
}
```

### Q: 如何实现响应式导航？
```dart
WindowRespondBuilder(
  builder: (_, r) => Scaffold(
    drawer: r.index <= 1 ? Drawer(child: Menu()) : null,
    body: Row(
      children: [
        if (r.index > 1) Menu(),  // 桌面端侧边栏
        Expanded(child: content),
      ],
    ),
  ),
)
```