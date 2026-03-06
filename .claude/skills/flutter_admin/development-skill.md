# Flutter Admin 开发技能指南

本文档作为后续开发的skill参考，包含常用开发模式和代码模板。

## 一、新增功能模块开发流程

### 1.1 完整开发步骤

```
1. 创建数据模型 → lib/models/xxx.dart
2. 创建API接口 → lib/api/xxx_api.dart
3. 创建列表页面 → lib/pages/xxx/xxx_list.dart
4. 创建编辑页面 → lib/pages/xxx/xxx_edit.dart
5. 注册路由 → lib/common/routes.dart
6. 添加菜单 → 后台配置或本地数据
```

### 1.2 文件模板

#### 数据模型模板 (lib/models/xxx.dart)

```dart
class Xxx {
  String? id;
  String? name;
  String? description;
  // ... 其他字段

  Xxx({this.id, this.name, this.description});

  Xxx copyWith({
    String? id,
    String? name,
    String? description,
  }) {
    return Xxx(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory Xxx.fromMap(Map<String, dynamic> map) {
    return Xxx(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Xxx && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
```

#### API接口模板 (lib/api/xxx_api.dart)

```dart
import 'package:cry/cry.dart';
import 'package:flutter_admin/models/xxx.dart';

class XxxApi {
  /// 分页查询
  static Future<ResponseBodyApi> page(Map<String, dynamic> data) =>
    HttpUtil.post('/xxx/page', data: data);

  /// 根据ID查询
  static Future<ResponseBodyApi> getById(String id) =>
    HttpUtil.get('/xxx/$id');

  /// 保存或更新
  static Future<ResponseBodyApi> saveOrUpdate(Xxx xxx) =>
    HttpUtil.post('/xxx/saveOrUpdate', data: xxx.toMap());

  /// 批量删除
  static Future<ResponseBodyApi> removeByIds(List<String> ids) =>
    HttpUtil.post('/xxx/removeByIds', data: ids);
}
```

#### 列表页面模板 (lib/pages/xxx/xxx_list.dart)

```dart
import 'package:flutter/material.dart';
import 'package:cry/cry.dart';
import 'package:flutter_admin/api/xxx_api.dart';
import 'package:flutter_admin/models/xxx.dart';
import 'package:flutter_admin/pages/xxx/xxx_edit.dart';

class XxxList extends StatefulWidget {
  const XxxList({Key? key}) : super(key: key);

  @override
  State<XxxList> createState() => _XxxListState();
}

class _XxxListState extends State<XxxList> {
  final GlobalKey<CryDataTableState> tableKey = GlobalKey();
  int page = 1;
  int rowsPerPage = 10;
  String? searchName;

  @override
  void initState() {
    super.initState();
    _query();
  }

  _query() async {
    RequestBodyApi requestBodyApi = RequestBodyApi();
    requestBodyApi.page = page;
    requestBodyApi.size = rowsPerPage;
    if (searchName != null && searchName!.isNotEmpty) {
      requestBodyApi.condition = {'name': searchName};
    }

    ResponseBodyApi responseBodyApi = await XxxApi.page(requestBodyApi.toMap());
    PageModel pageModel = PageModel.fromMap(responseBodyApi.data);

    setState(() {
      tableKey.currentState?.loadData(pageModel);
    });
  }

  _add() {
    CryUtil.pushNamed('/xxxEdit', arguments: Xxx());
  }

  _edit(Xxx xxx) {
    CryUtil.pushNamed('/xxxEdit', arguments: xxx);
  }

  _delete(Xxx xxx) async {
    await XxxApi.removeByIds([xxx.id!]);
    _query();
  }

  _batchDelete(List<dynamic> selected) async {
    List<String> ids = selected.map((e) => Xxx.fromMap(e).id!).toList();
    await XxxApi.removeByIds(ids);
    _query();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('XXX管理'),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _add),
        ],
      ),
      body: Column(
        children: [
          // 搜索条件
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: CryInput(
                    label: '名称',
                    value: searchName,
                    onChanged: (v) => searchName = v,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  child: Text('查询'),
                  onPressed: _query,
                ),
              ],
            ),
          ),
          // 数据表格
          Expanded(
            child: CryDataTable(
              key: tableKey,
              onPageChanged: (firstRowIndex) {
                page = (firstRowIndex ~/ rowsPerPage) + 1;
                _query();
              },
              onRowsPerPageChanged: (int? size) {
                rowsPerPage = size ?? 10;
                _query();
              },
              columns: [
                DataColumn(label: Text('名称')),
                DataColumn(label: Text('描述')),
                DataColumn(label: Text('操作')),
              ],
              getCells: (m) {
                Xxx xxx = Xxx.fromMap(m);
                return [
                  DataCell(Text(xxx.name ?? '')),
                  DataCell(Text(xxx.description ?? '')),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _edit(xxx),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _delete(xxx),
                      ),
                    ],
                  )),
                ];
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 编辑页面模板 (lib/pages/xxx/xxx_edit.dart)

```dart
import 'package:flutter/material.dart';
import 'package:cry/cry.dart';
import 'package:flutter_admin/api/xxx_api.dart';
import 'package:flutter_admin/models/xxx.dart';

class XxxEdit extends StatefulWidget {
  final Xxx xxx;

  const XxxEdit({Key? key, required this.xxx}) : super(key: key);

  @override
  State<XxxEdit> createState() => _XxxEditState();
}

class _XxxEditState extends State<XxxEdit> {
  final GlobalKey<FormState> formKey = GlobalKey();
  late Xxx _xxx;

  @override
  void initState() {
    super.initState();
    _xxx = widget.xxx.copyWith();
  }

  _save() async {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();

    await XxxApi.saveOrUpdate(_xxx);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_xxx.id == null ? '新增XXX' : '编辑XXX'),
        actions: [
          TextButton(
            child: Text('保存', style: TextStyle(color: Colors.white)),
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              CryInput(
                label: '名称',
                value: _xxx.name,
                onSaved: (v) => _xxx.name = v,
                validator: (v) => v?.isEmpty ?? true ? '必填' : null,
              ),
              SizedBox(height: 16),
              CryInput(
                label: '描述',
                value: _xxx.description,
                onSaved: (v) => _xxx.description = v,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 1.3 注册路由

在 `lib/common/routes.dart` 中添加：

```dart
static Map<String, Widget> layoutPagesMap = {
  // ... 已有路由
  '/xxxList': XxxList(),
  '/xxxEddit': XxxEdit(xxx: Xxx()),
};
```

## 二、树形数据处理

### 2.1 树形模型

```dart
class Dept extends TreeData {
  String? id;
  String? pid;
  String? name;
  List<Dept>? children;

  Dept({this.id, this.pid, this.name, this.children});

  @override
  List<TreeData>? getSubNodes() => children;

  @override
  void setSubNodes(List<TreeData>? list) {
    children = list?.cast<Dept>();
  }
}
```

### 2.2 树形选择器

```dart
// 使用CryTree
CryTree<Dept>(
  data: deptList,
  onSelect: (dept) {
    // 处理选择
  },
)
```

## 三、常用组件使用

### 3.1 表格组件 (CryDataTable)

```dart
CryDataTable(
  key: tableKey,
  // 分页
  onPageChanged: (firstRowIndex) { },
  onRowsPerPageChanged: (size) { },
  // 选择
  onSelectAll: (selected) { },
  onSelect: (selected, index, data) { },
  // 列定义
  columns: [
    DataColumn(label: Text('列名')),
  ],
  // 单元格渲染
  getCells: (m) => [
    DataCell(Text('内容')),
  ],
)
```

### 3.2 表单输入

```dart
// 文本输入
CryInput(
  label: '标签',
  value: '初始值',
  hint: '提示文字',
  onSaved: (v) { },
  validator: (v) => v?.isEmpty ?? true ? '必填' : null,
  onChanged: (v) { },
)

// 下拉选择
CrySelect(
  label: '标签',
  value: selectedValue,
  items: [
    DropdownMenuItem(value: '1', child: Text('选项1')),
    DropdownMenuItem(value: '2', child: Text('选项2')),
  ],
  onChanged: (v) { },
)

// 日期选择
CryDatePicker(
  label: '日期',
  value: selectedDate,
  onChanged: (v) { },
)
```

### 3.3 按钮和操作

```dart
// 主要按钮
ElevatedButton(
  child: Text('保存'),
  onPressed: _save,
)

// 次要按钮
TextButton(
  child: Text('取消'),
  onPressed: () => Navigator.pop(context),
)

// 图标按钮
IconButton(
  icon: Icon(Icons.edit),
  onPressed: _edit,
)

// 确认对话框
CryUtil.confirm(
  context,
  title: '确认删除',
  content: '删除后无法恢复，确定要删除吗？',
  onConfirm: () => _delete(),
)
```

## 四、状态管理模式

### 4.1 StatefulWidget + setState

适用于页面内部状态：

```dart
class _XxxListState extends State<XxxList> {
  List<Xxx> dataList = [];

  _loadData() async {
    var result = await XxxApi.page({});
    setState(() {
      dataList = result.data;
    });
  }
}
```

### 4.2 GetX控制器

适用于全局/跨页面状态：

```dart
// 定义控制器
class XxxController extends GetxController {
  List<Xxx> dataList = [];

  void loadData() async {
    var result = await XxxApi.page({});
    dataList = result.data;
    update();
  }
}

// 注册控制器
Get.put(XxxController());

// 使用控制器
GetBuilder<XxxController>(
  builder: (controller) => ListView.builder(
    itemCount: controller.dataList.length,
    itemBuilder: (context, index) => ListTile(...),
  ),
)
```

## 五、错误处理

### 5.1 API错误处理

```dart
try {
  var result = await XxxApi.save(data);
  if (result.success) {
    CryUtil.message('保存成功');
    Navigator.pop(context);
  } else {
    CryUtil.message(result.message ?? '保存失败');
  }
} catch (e) {
  CryUtil.message('网络错误，请重试');
}
```

### 5.2 表单验证

```dart
_save() {
  if (!formKey.currentState!.validate()) return;
  formKey.currentState!.save();
  // ... 保存逻辑
}

// 验证规则
CryInput(
  validator: (v) {
    if (v == null || v.isEmpty) return '必填';
    if (v.length < 3) return '至少3个字符';
    return null;
  },
)
```

## 六、文件上传

### 6.1 图片上传

```dart
CryUploadImage(
  onUploaded: (url) {
    setState(() {
      imageUrl = url;
    });
  },
)
```

### 6.2 文件上传

```dart
CryUploadFile(
  allowedExtensions: ['pdf', 'doc', 'docx'],
  onUploaded: (fileInfo) {
    // fileInfo包含文件路径、名称等信息
  },
)
```

## 七、常用工具方法

### 7.1 消息提示

```dart
// 普通消息
CryUtil.message('操作成功');

// 错误消息
CryUtil.message('操作失败', type: MessageType.error);

// 警告消息
CryUtil.message('请注意', type: MessageType.warning);
```

### 7.2 路由跳转

```dart
// 普通跳转
CryUtil.pushNamed('/xxxList');

// 带参数跳转
CryUtil.pushNamed('/xxxEddit', arguments: xxx);

// 替换当前页面
CryUtil.pushNamedAndRemove('/login');

// 返回
Navigator.pop(context);
Navigator.pop(context, result);
```

### 7.3 本地存储

```dart
// 存储
await StoreUtil.write(Constant.KEY_XXX, value);

// 读取
var value = StoreUtil.read<String>(Constant.KEY_XXX);

// 删除
await StoreUtil.remove(Constant.KEY_XXX);
```

## 八、国际化

### 8.1 添加新的国际化文本

1. 在 `l10n/intl_zh.arb` 中添加：
```json
{
  "xxx_name": "XXX名称",
  "@xxx_name": {
    "description": "XXX名称"
  }
}
```

2. 在代码中使用：
```dart
Text(S.of(context).xxx_name)
```

## 九、最佳实践

1. **命名规范**
   - 文件名：小写下划线 `xxx_list.dart`
   - 类名：大驼峰 `XxxList`
   - 变量：小驼峰 `dataList`

2. **代码组织**
   - 每个模块独立目录
   - API与UI分离
   - 模型与逻辑分离

3. **性能优化**
   - 使用 `const` 构造函数
   - 大列表使用 `ListView.builder`
   - 避免不必要的 `setState`

4. **安全考虑**
   - 敏感数据不存储本地
   - Token过期自动登出
   - 输入验证必不可少