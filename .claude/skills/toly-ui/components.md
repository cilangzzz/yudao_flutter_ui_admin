# TolyUI 组件使用指南

## 响应式布局组件

### WindowRespondBuilder
响应式布局构建器，根据窗口宽度返回不同的响应式类型。

```dart
WindowRespondBuilder(
  builder: (BuildContext context, Rx type) {
    // type: Rx.xs, Rx.sm, Rx.md, Rx.lg, Rx.xl
    return YourWidget();
  },
)
```

**断点范围:**
- `Rx.xs`: < 768px (手机)
- `Rx.sm`: 768px - 992px (小平板)
- `Rx.md`: 992px - 1200px (平板)
- `Rx.lg`: 1200px - 1920px (桌面)
- `Rx.xl`: > 1920px (大屏)

### Padding$
响应式边距组件，根据窗口尺寸自动调整边距。

```dart
Padding$(
  padding: (re) => switch (re) {
    Rx.xs => const EdgeInsets.symmetric(horizontal: 18.0),
    Rx.sm => const EdgeInsets.symmetric(horizontal: 24.0),
    Rx.md => const EdgeInsets.symmetric(horizontal: 32.0),
    Rx.lg => const EdgeInsets.symmetric(horizontal: 48.0),
    Rx.xl => const EdgeInsets.symmetric(horizontal: 64.0),
  },
  child: YourWidget(),
)
```

---

## 基础组件

### HighlightText (TolyuiText)
高亮文本组件，支持正则匹配高亮和点击事件。

```dart
// 基础用法
HighlightText(
  'Hello World',
  rules: {
    Rule(RegExp(r'Hello')): TextStyle(color: Colors.red),
  },
)

// 快捷构造 - 高亮关键词
HighlightText.withArg(
  '搜索结果中的关键词高亮',
  arg: '关键词',
  highlightStyle: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
  onTap: (match) => print('点击了: ${match.text}'),
)
```

**HighlightMatch 属性:**
- `pattern`: 匹配的正则模式
- `text`: 匹配的文本
- `start`: 开始位置
- `end`: 结束位置
- `index`: 匹配索引

### TolyCollapse
折叠面板组件，支持动画展开/收起。

```dart
TolyCollapse(
  title: Text('点击展开'),
  content: YourContentWidget(),
  duration: const Duration(milliseconds: 300),
  sizeCurve: Curves.easeInOut,
  controller: CollapseController(), // 可选，外部控制
  onOpen: () => print('打开'),
  onClose: () => print('关闭'),
)

// 自定义标题构建器
TolyCollapse(
  titleBuilder: (context, anima, ctrl) => GestureDetector(
    onTap: () => ctrl.toggle(),
    child: YourCustomTitle(),
  ),
  content: YourContentWidget(),
)
```

**CollapseController 方法:**
- `toggle()`: 切换展开/收起
- `open()`: 展开
- `close()`: 收起
- `isOpen`: 获取当前状态

---

## 数据展示组件

### TolyTree
树形组件，支持懒加载、选择、连接线。

```dart
TolyTree<String>(
  nodes: [
    TreeNode(
      id: '1',
      data: '节点1',
      isExpanded: true,
      children: [
        TreeNode(id: '1-1', data: '子节点1-1'),
      ],
    ),
  ],
  nodeBuilder: (node) => Text(node.data),
  onTap: (node) => print('点击: ${node.data}'),
  onExpand: (node) => print('展开: ${node.data}'),
  // 懒加载
  loadData: (node) async {
    return [TreeNode(id: 'new', data: '新加载的节点')];
  },
  indent: 24.0,
  showConnectingLines: true,
  connectingLineColor: Colors.grey,
)
```

**TreeNode 属性:**
- `id`: 唯一标识
- `data`: 节点数据
- `children`: 子节点列表
- `isExpanded`: 是否展开
- `isSelected`: 是否选中
- `selectable`: 是否可选中
- `isLeaf`: 是否叶子节点
- `isLoading`: 是否加载中

### TolyTable
表格组件，支持多级表头、选择、分页。

```dart
TolyTableV1<User>(
  columns: [
    TableColumn<User>(
      title: '姓名',
      dataIndex: (user) => user.name,
      width: 120,
    ),
    TableColumn<User>(
      title: '操作',
      render: (user, index) => TextButton(
        onPressed: () => edit(user),
        child: Text('编辑'),
      ),
    ),
  ],
  dataSource: users,
  rowSelection: TableRowSelection(
    type: RowSelectionType.checkbox,
    onChange: (keys, rows) => print('选中: $keys'),
  ),
  pagination: TablePagination(
    pageSize: 10,
    onChange: (page, size) => loadData(page),
  ),
  bordered: true,
  size: TableSize.middle,
)
```

**TableColumn 属性:**
- `title`: 列标题
- `dataIndex`: 数据提取函数
- `render`: 自定义渲染
- `width`: 列宽
- `align`: 对齐方式
- `sortable`: 是否可排序
- `children`: 子列（多级表头）

### TolyWatermark
水印组件。

```dart
TolyWatermark(
  content: '机密文档',
  child: YourContent(),
  rotate: -22,
  color: Color(0x26000000),
  fontSize: 16,
  gapX: 100,
  gapY: 100,
)

// 多行水印
TolyWatermark(
  contents: ['张三', '2024-01-01'],
  child: YourContent(),
)
```

### TolySkeleton
骨架屏组件。

```dart
// 基础骨架屏
TolySkeleton(
  loading: isLoading,
  active: true, // 显示动画
  avatar: true, // 显示头像
  title: true,  // 显示标题
  paragraphRows: 3, // 段落行数
  child: YourContent(),
)

// 单独使用子组件
SkeletonAvatar(size: 40, circle: true)
SkeletonButton(width: 80, height: 32)
SkeletonInput(width: 200, height: 32)
SkeletonImage(width: 100, height: 100)
```

### TolyTimeline
时间线组件。

```dart
TolyTimeline(
  items: [
    TimelineItemData(
      title: Text('创建时间'),
      content: '2024-01-01 10:00',
      color: Colors.blue,
      icon: Icon(Icons.check_circle, size: 16),
    ),
    TimelineItemData(
      title: Text('审核中'),
      content: '等待审核...',
      loading: true,
    ),
  ],
  mode: TimelineMode.start, // start | end | alternate
  reverse: false,
)
```

**TimelineMode:**
- `start`: 左侧时间轴
- `end`: 右侧时间轴
- `alternate`: 交替显示

### TolyCarousel
轮播图组件。

```dart
TolyCarousel(
  children: [
    Image.network('url1'),
    Image.network('url2'),
  ],
  autoplay: true,
  autoplaySpeed: 3000,
  dots: true,
  dotPlacement: DotPlacement.bottom,
  arrows: true,
  infinite: true,
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  effect: CarouselEffect.scroll, // scroll | fade
  onChanged: (index) => print('切换到: $index'),
)
```

**控制器方法 (通过 GlobalKey 获取):**
- `goTo(int index)`: 跳转到指定页
- `next()`: 下一页
- `prev()`: 上一页

---

## 反馈组件

### TolyTooltip
工具提示组件。

```dart
TolyTooltip(
  message: '提示内容',
  placement: TooltipPlacement.top,
  child: IconButton(icon: Icon(Icons.info), onPressed: () {}),
)
```

### TolyPopover
气泡弹出框组件。

```dart
TolyPopover(
  content: YourContentWidget(),
  placement: TooltipPlacement.bottom,
  child: ElevatedButton(child: Text('点击'), onPressed: () {}),
)
```

### 消息提示 ($message)
全局消息提示。

```dart
$message.success(message: '操作成功!');
$message.error(message: '操作失败!');
$message.warning(message: '警告信息');
$message.info(message: '提示信息');
```

---

## 开发最佳实践

### 1. 组件命名规范
- 组件类名以 `Toly` 前缀命名 (如 `TolyTree`, `TolyCollapse`)
- 私有组件以 `_` 开头

### 2. 响应式设计
始终使用 `WindowRespondBuilder` 或 `Padding$` 适配不同屏幕尺寸：

```dart
WindowRespondBuilder(
  builder: (_, r) {
    if (r.index > 1) return DesktopLayout();
    return MobileLayout();
  },
)
```

### 3. 状态管理
使用 `flutter_bloc` 进行状态管理：

```dart
class AppLogic extends Cubit<AppState> {
  void toggleTheme(bool isDark) {
    emit(state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
  }
}
```

### 4. 路由配置
使用 `GoRouter` 和 `ShellRoute` 实现嵌套导航：

```dart
ShellRoute(
  builder: (context, state, child) => NavigationShell(child: child),
  routes: [
    GoRoute(path: 'home', builder: (c, s) => HomePage()),
  ],
)
```

### 5. 组件展示 Demo
使用 `@DisplayNode` 注解标记展示组件：

```dart
@DisplayNode(
  title: '基础用法',
  desc: '组件的基础使用方式',
)
class ButtonDemo1 extends StatelessWidget { ... }
```