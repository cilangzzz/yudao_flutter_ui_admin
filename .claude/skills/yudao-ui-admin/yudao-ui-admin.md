# Yudao UI Admin Vben 项目迁移 Skill

> 基于 Vben 5.0 + Vue 3 + Vite + Ant Design Vue + TypeScript 的芋道管理后台项目，用于 Flutter 迁移参考。

## 项目结构

```
yudao-ui-admin-vben/
├── apps/                          # 应用实例
│   └── web-antd/                  # 主应用 (Ant Design Vue)
│       ├── src/
│       │   ├── api/               # API 层
│       │   ├── store/             # 状态管理 (auth.ts)
│       │   ├── views/             # 页面组件
│       │   ├── router/            # 路由配置
│       │   ├── components/        # 业务组件
│       │   └── adapter/           # 组件适配器
│       └── .env                   # 环境配置
├── packages/                      # 共享包
│   ├── @core/                     # 核心 UI Kit
│   ├── effects/                   # 效果包 (access, request, hooks)
│   ├── stores/                    # Pinia stores (access, user, dict)
│   ├── utils/                     # 工具函数
│   ├── types/                     # TypeScript 类型
│   └── constants/                 # 常量定义
└── internal/                       # 内部工具
```

---

## 核心模式

### 1. API 层实现

#### 请求客户端配置
位置: `apps/web-antd/src/api/request.ts`

```typescript
// 基于 Axios 的请求客户端
const requestClient = createRequestClient(apiURL, {
  responseReturn: 'data',  // 只返回 data 字段
});

// 请求拦截器
- Authorization: Bearer ${token}
- tenant-id: 租户ID
- visit-tenant-id: 访问租户ID
- Accept-Language: 语言

// 响应拦截器
- API 解密
- code === 0 判断成功
- Token 刷新逻辑
- 错误消息处理
```

#### API 模块定义
位置: `apps/web-antd/src/api/system/user/index.ts`

```typescript
// TypeScript 命名空间定义类型
export namespace SystemUserApi {
  export interface User {
    id?: number;
    username: string;
    nickname: string;
    deptId?: number;
    postIds?: number[];
    roleIds?: number[];
    email?: string;
    mobile?: string;
    sex?: number;
    status?: number;
    avatar?: string;
  }
}

// CRUD API 函数
export function getUserPage(params: PageParam) {
  return requestClient.get<PageResult<SystemUserApi.User>>('/system/user/page', { params });
}

export function getUser(id: number) {
  return requestClient.get<SystemUserApi.User>(`/system/user/get?id=${id}`);
}

export function createUser(data: SystemUserApi.User) {
  return requestClient.post('/system/user/create', data);
}

export function updateUser(data: SystemUserApi.User) {
  return requestClient.put('/system/user/update', data);
}

export function deleteUser(id: number) {
  return requestClient.delete(`/system/user/delete?id=${id}`);
}
```

#### Flutter 迁移模板

```dart
// lib/api/system/user_api.dart
import 'package:dio/dio.dart';
import '../../models/system/user.dart';
import '../../models/common/page_result.dart';
import '../../models/common/page_param.dart';
import '../../core/api_client.dart';

class UserApi {
  static Future<PageResult<User>> getUserPage(PageParam params) async {
    final response = await ApiClient.get<Map<String, dynamic>>(
      '/system/user/page',
      queryParameters: params.toJson(),
    );
    return PageResult<User>.fromJson(
      response,
      (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<User> getUser(int id) async {
    final response = await ApiClient.get<Map<String, dynamic>>(
      '/system/user/get',
      queryParameters: {'id': id},
    );
    return User.fromJson(response);
  }

  static Future<void> createUser(User user) async {
    await ApiClient.post('/system/user/create', data: user.toJson());
  }

  static Future<void> updateUser(User user) async {
    await ApiClient.put('/system/user/update', data: user.toJson());
  }

  static Future<void> deleteUser(int id) async {
    await ApiClient.delete('/system/user/delete', queryParameters: {'id': id});
  }
}
```

---

### 2. 状态管理

#### Access Store (认证状态)
位置: `packages/stores/src/modules/access.ts`

```typescript
interface AccessState {
  accessToken: AccessToken;        // 访问令牌
  refreshToken: AccessToken;        // 刷新令牌
  accessCodes: string[];            // 权限码列表
  accessMenus: MenuRecordRaw[];     // 动态菜单
  accessRoutes: RouteRecordRaw[];   // 动态路由
  isAccessChecked: boolean;         // 权限检查状态
  tenantId: null | number;          // 租户ID
  loginExpired: boolean;            // 登录过期标志
}
```

#### User Store (用户信息)
位置: `packages/stores/src/modules/user.ts`

```typescript
interface UserState {
  userInfo: BasicUserInfo | null;  // 用户信息
  userRoles: string[];             // 角色列表
}

interface BasicUserInfo {
  userId: string;
  username: string;
  nickname: string;
  avatar: string;
  homePath?: string;
}
```

#### Dict Store (字典缓存)
位置: `packages/stores/src/modules/dict.ts`

```typescript
interface DictState {
  dictCache: Dict;  // Record<string, DictItem[]>
}

// 字典项
interface DictItem {
  label: string;
  value: string | number;
  colorType?: string;  // 颜色类型
  cssClass?: string;   // CSS 类
}

// 方法
getDictData(dictType: string, value: any)  // 获取字典标签
getDictOptions(dictType: string)           // 获取字典选项
setDictCacheByApi(api, params)            // 从 API 加载
```

#### Flutter 迁移模板 (Riverpod)

```dart
// lib/stores/access_store.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'access_store.g.dart';

@riverpod
class AccessStore extends _$AccessStore {
  @override
  AccessState build() => AccessState.initial();

  void setAccessToken(String? token) {
    state = state.copyWith(accessToken: token);
    if (token != null) {
      _secureStorage.write(key: 'accessToken', value: token);
    } else {
      _secureStorage.delete(key: 'accessToken');
    }
  }

  void setAccessCodes(List<String> codes) {
    state = state.copyWith(accessCodes: codes);
  }

  void setAccessMenus(List<Menu> menus) {
    state = state.copyWith(accessMenus: menus);
  }

  bool hasPermission(String code) {
    return state.accessCodes.contains(code);
  }

  bool hasAnyPermission(List<String> codes) {
    return codes.any((code) => state.accessCodes.contains(code));
  }
}

// lib/stores/dict_store.dart
@riverpod
class DictStore extends _$DictStore {
  @override
  DictState build() => DictState.initial();

  Future<void> loadDict(String dictType) async {
    if (state.dictCache.containsKey(dictType)) return;

    final items = await DictApi.getDictItems(dictType);
    state = state.copyWith(
      dictCache: {...state.dictCache, dictType: items},
    );
  }

  String? getDictLabel(String dictType, dynamic value) {
    final items = state.dictCache[dictType];
    if (items == null) return null;
    return items.firstWhere(
      (item) => item.value == value,
      orElse: () => DictItem(label: '', value: value),
    ).label;
  }
}
```

---

### 3. 认证流程

#### 登录流程
位置: `apps/web-antd/src/store/auth.ts`

```typescript
// 1. 登录 API 调用
const { accessToken, refreshToken } = await loginApi(params);

// 2. 存储 Token
accessStore.setAccessToken(accessToken);
accessStore.setRefreshToken(refreshToken);

// 3. 获取用户信息和权限
const authPermissionInfo = await getAuthPermissionInfoApi();
userStore.setUserInfo(authPermissionInfo.user);
userStore.setUserRoles(authPermissionInfo.roles);
accessStore.setAccessMenus(authPermissionInfo.menus);
accessStore.setAccessCodes(authPermissionInfo.permissions);

// 4. 导航到首页
await router.push(userInfo.homePath || defaultHomePath);
```

#### 权限检查
位置: `packages/effects/access/src/use-access.ts`

```typescript
// 权限码检查
function hasAccessByCodes(codes: string[]) {
  const userCodesSet = new Set(accessStore.accessCodes);
  return codes.some((code) => userCodesSet.has(code));
}

// 角色检查
function hasAccessByRoles(roles: string[]) {
  const userRoleSet = new Set(userStore.userRoles);
  return roles.some((role) => userRoleSet.has(role));
}

// 使用示例
const canEdit = hasAccessByCodes(['system:user:update']);
const isAdmin = hasAccessByRoles(['admin']);
```

#### Flutter 迁移模板

```dart
// lib/services/auth_service.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
class AuthService extends _$AuthService {
  @override
  AsyncValue<AuthState> build() => AsyncValue.loading();

  Future<void> login(LoginParams params) async {
    state = AsyncValue.loading();

    try {
      // 1. 调用登录 API
      final tokens = await AuthApi.login(params);

      // 2. 存储 Token
      final accessStore = ref.read(accessStoreProvider.notifier);
      accessStore.setAccessToken(tokens.accessToken);
      accessStore.setRefreshToken(tokens.refreshToken);

      // 3. 获取用户信息和权限
      final permissionInfo = await AuthApi.getPermissionInfo();
      ref.read(userStoreProvider.notifier).setUserInfo(permissionInfo.user);
      ref.read(userStoreProvider.notifier).setRoles(permissionInfo.roles);
      accessStore.setAccessMenus(permissionInfo.menus);
      accessStore.setAccessCodes(permissionInfo.permissions);

      state = AsyncValue.data(AuthState.authenticated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await AuthApi.logout();
    ref.read(accessStoreProvider.notifier).clear();
    ref.read(userStoreProvider.notifier).clear();
  }
}

// 路由守卫中间件
class AuthGuard extends GoRouteGuard {
  @override
  String? redirect(GoRouterState state) {
    final accessState = ref.read(accessStoreProvider);
    final isAuthenticated = accessState.accessToken != null;

    final isAuthRoute = state.matchedLocation.startsWith('/auth');

    if (!isAuthenticated && !isAuthRoute) {
      return '/auth/login';
    }

    if (isAuthenticated && isAuthRoute) {
      return '/';
    }

    return null;
  }
}
```

---

### 4. 表单模式

#### 表单 Schema 定义
位置: `apps/web-antd/src/views/system/user/data.ts`

```typescript
export function useFormSchema(): VbenFormSchema[] {
  return [
    {
      component: 'Input',
      fieldName: 'id',
      dependencies: { show: () => false },  // 隐藏字段
    },
    {
      fieldName: 'username',
      label: '用户名称',
      component: 'Input',
      componentProps: {
        placeholder: '请输入用户名称',
      },
      rules: 'required',
    },
    {
      fieldName: 'deptId',
      label: '归属部门',
      component: 'ApiTreeSelect',
      componentProps: {
        api: async () => {
          const data = await getDeptList();
          return handleTree(data);
        },
        labelField: 'name',
        valueField: 'id',
        childrenField: 'children',
      },
    },
    {
      fieldName: 'sex',
      label: '用户性别',
      component: 'RadioGroup',
      componentProps: {
        options: getDictOptions(DICT_TYPE.SYSTEM_USER_SEX, 'number'),
        buttonStyle: 'solid',
        optionType: 'button',
      },
      rules: z.number().default(1),
    },
    {
      fieldName: 'status',
      label: '状态',
      component: 'Switch',
      componentProps: {
        checkedChildren: '开',
        unCheckedChildren: '关',
      },
    },
    {
      fieldName: 'remark',
      label: '备注',
      component: 'Textarea',
      componentProps: {
        rows: 4,
        placeholder: '请输入备注',
      },
    },
  ];
}
```

#### 表单组件使用
位置: `apps/web-antd/src/views/system/user/modules/form.vue`

```typescript
const [Form, formApi] = useVbenForm({
  commonConfig: {
    componentProps: { class: 'w-full' },
    formItemClass: 'col-span-2',
    labelWidth: 80,
  },
  layout: 'horizontal',
  schema: useFormSchema(),
  showDefaultActions: false,
});

const [Modal, modalApi] = useVbenModal({
  async onConfirm() {
    const { valid } = await formApi.validate();
    if (!valid) return;

    const data = await formApi.getValues();
    await (formData.value?.id ? updateUser(data) : createUser(data));
    emit('success');
  },
  async onOpenChange(isOpen: boolean) {
    if (!isOpen) return;
    const data = modalApi.getData<SystemUserApi.User>();
    if (data?.id) {
      formData.value = await getUser(data.id);
      await formApi.setValues(formData.value);
    }
  },
});
```

#### Flutter 迁移模板

```dart
// lib/models/form_field_config.dart
enum FormComponentType {
  input,
  inputNumber,
  select,
  radioGroup,
  checkboxGroup,
  switch_,
  datePicker,
  textarea,
  upload,
  treeSelect,
  apiSelect,
  apiTreeSelect,
}

class FormFieldConfig {
  final String fieldName;
  final String label;
  final FormComponentType component;
  final Map<String, dynamic>? componentProps;
  final String? rules;
  final bool Function(Map<String, dynamic> values)? showIf;
  final List<OptionItem>? options;

  const FormFieldConfig({
    required this.fieldName,
    required this.label,
    required this.component,
    this.componentProps,
    this.rules,
    this.showIf,
    this.options,
  });
}

// lib/widgets/schema_form.dart
class SchemaForm extends StatelessWidget {
  final List<FormFieldConfig> schema;
  final Map<String, dynamic> initialValues;
  final void Function(Map<String, dynamic> values) onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: schema.map((field) => _buildField(field)).toList(),
      ),
    );
  }

  Widget _buildField(FormFieldConfig field) {
    switch (field.component) {
      case FormComponentType.input:
        return _InputField(config: field);
      case FormComponentType.select:
        return _SelectField(config: field);
      case FormComponentType.radioGroup:
        return _RadioGroupField(config: field);
      case FormComponentType.switch_:
        return _SwitchField(config: field);
      // ... 其他组件
    }
  }
}

// 使用示例
class UserForm extends StatelessWidget {
  final User? user;

  List<FormFieldConfig> _buildSchema() {
    return [
      FormFieldConfig(
        fieldName: 'username',
        label: '用户名称',
        component: FormComponentType.input,
        componentProps: {'placeholder': '请输入用户名称'},
        rules: 'required',
      ),
      FormFieldConfig(
        fieldName: 'deptId',
        label: '归属部门',
        component: FormComponentType.apiTreeSelect,
        componentProps: {
          'api': getDeptList,
          'labelField': 'name',
          'valueField': 'id',
        },
      ),
      FormFieldConfig(
        fieldName: 'sex',
        label: '用户性别',
        component: FormComponentType.radioGroup,
        options: DictStore.getOptions(DictType.systemUserSex),
      ),
    ];
  }
}
```

---

### 5. 表格/列表模式

#### Grid 配置
位置: `apps/web-antd/src/views/system/user/index.vue`

```typescript
const [Grid, gridApi] = useVbenVxeGrid({
  formOptions: {
    schema: useGridFormSchema(),  // 搜索表单
  },
  gridOptions: {
    columns: useGridColumns(handleStatusChange),
    height: 'auto',
    keepSource: true,
    proxyConfig: {
      ajax: {
        query: async ({ page }, formValues) => {
          return await getUserPage({
            pageNo: page.currentPage,
            pageSize: page.pageSize,
            ...formValues,
            deptId: searchDeptId.value,
          });
        },
      },
    },
    rowConfig: {
      keyField: 'id',
      isHover: true,
    },
    toolbarConfig: {
      refresh: true,
      search: true,
    },
  },
  gridEvents: {
    checkboxAll: handleRowCheckboxChange,
    checkboxChange: handleRowCheckboxChange,
  },
});
```

#### 列定义
位置: `apps/web-antd/src/views/system/user/data.ts`

```typescript
export function useGridColumns(onStatusChange): VxeTableGridOptions['columns'] {
  return [
    { type: 'checkbox', width: 40 },
    { field: 'id', title: '用户编号', minWidth: 100 },
    { field: 'username', title: '用户名称', minWidth: 120 },
    { field: 'nickname', title: '用户昵称', minWidth: 120 },
    {
      field: 'deptName',
      title: '部门',
      minWidth: 150,
    },
    {
      field: 'status',
      title: '状态',
      minWidth: 100,
      cellRender: {
        name: 'CellSwitch',
        attrs: { beforeChange: onStatusChange },
        props: {
          checkedValue: CommonStatusEnum.ENABLE,
          unCheckedValue: CommonStatusEnum.DISABLE,
        },
      },
    },
    {
      field: 'createTime',
      title: '创建时间',
      minWidth: 180,
      formatter: 'formatDateTime',
    },
    {
      title: '操作',
      width: 180,
      fixed: 'right',
      slots: { default: 'actions' },
    },
  ];
}
```

#### TableAction 权限控制
```vue
<TableAction
  :actions="[
    {
      label: '编辑',
      type: 'link',
      icon: 'edit',
      auth: ['system:user:update'],
      onClick: handleEdit.bind(null, row),
    },
    {
      label: '删除',
      type: 'link',
      danger: true,
      icon: 'delete',
      auth: ['system:user:delete'],
      popConfirm: {
        title: `确认删除 ${row.username} 吗？`,
        confirm: handleDelete.bind(null, row),
      },
    },
  ]"
/>
```

#### Flutter 迁移模板

```dart
// lib/widgets/data_table/schema_table.dart
class SchemaTable<T> extends StatefulWidget {
  final Future<PageResult<T>> Function(int page, int pageSize, Map<String, dynamic> params) fetchData;
  final List<TableColumnConfig<T>> columns;
  final List<TableActionConfig<T>>? actions;
  final Widget? searchForm;
  final void Function(T item)? onRowClick;

  @override
  State<SchemaTable<T>> createState() => _SchemaTableState<T>();
}

class TableColumnConfig<T> {
  final String field;
  final String label;
  final double? width;
  final Widget Function(T item)? cellBuilder;
  final String Function(T item)? valueGetter;
  final bool sortable;
  final bool fixed;

  const TableColumnConfig({
    required this.field,
    required this.label,
    this.width,
    this.cellBuilder,
    this.valueGetter,
    this.sortable = false,
    this.fixed = false,
  });
}

class TableActionConfig<T> {
  final String label;
  final IconData? icon;
  final List<String>? auth;  // 权限码
  final void Function(T item) onTap;
  final bool Function(T item)? showIf;
  final bool danger;
  final String? confirmTitle;  // 确认提示

  const TableActionConfig({
    required this.label,
    this.icon,
    this.auth,
    required this.onTap,
    this.showIf,
    this.danger = false,
    this.confirmTitle,
  });
}

// 使用示例
class UserTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SchemaTable<User>(
      fetchData: (page, pageSize, params) => UserApi.getUserPage(
        PageParam(pageNo: page, pageSize: pageSize, params: params),
      ),
      columns: [
        TableColumnConfig(field: 'id', label: '用户编号', width: 100),
        TableColumnConfig(field: 'username', label: '用户名称', width: 120),
        TableColumnConfig(field: 'nickname', label: '用户昵称', width: 120),
        TableColumnConfig<User>(
          field: 'status',
          label: '状态',
          width: 100,
          cellBuilder: (user) => StatusSwitch(
            value: user.status == 1,
            onChanged: (v) => _handleStatusChange(user, v),
          ),
        ),
        TableColumnConfig<User>(
          field: 'createTime',
          label: '创建时间',
          width: 180,
          valueGetter: (user) => formatDateTime(user.createTime),
        ),
      ],
      actions: [
        TableActionConfig(
          label: '编辑',
          icon: Icons.edit,
          auth: ['system:user:update'],
          onTap: (user) => _handleEdit(user),
        ),
        TableActionConfig(
          label: '删除',
          icon: Icons.delete,
          auth: ['system:user:delete'],
          danger: true,
          confirmTitle: '确认删除该用户吗？',
          onTap: (user) => _handleDelete(user),
        ),
      ],
    );
  }
}
```

---

### 6. 路由和权限控制

#### 核心路由配置
位置: `apps/web-antd/src/router/routes/core.ts`

```typescript
const coreRoutes: RouteRecordRaw[] = [
  {
    component: BasicLayout,
    name: 'Root',
    path: '/',
    redirect: preferences.app.defaultHomePath,
    children: [],
  },
  {
    component: AuthPageLayout,
    name: 'Authentication',
    path: '/auth',
    children: [
      { name: 'Login', path: 'login', component: Login },
      { name: 'Register', path: 'register', component: Register },
      { name: 'ForgotPassword', path: 'forgot-password', component: ForgotPassword },
    ],
  },
];
```

#### 动态路由生成
位置: `apps/web-antd/src/router/access.ts`

```typescript
async function generateAccess(options) {
  const pageMap: ComponentRecordType = import.meta.glob('../views/**/*.vue');

  return await generateAccessible(preferences.app.accessMode, {
    fetchMenuListAsync: async () => {
      const accessMenus = accessStore.accessMenus as AppRouteRecordRaw[];
      return convertServerMenuToRouteRecordStringComponent(accessMenus);
    },
    forbiddenComponent,
    layoutMap: { BasicLayout, IFrameView },
    pageMap,
  });
}
```

#### 路由守卫
位置: `apps/web-antd/src/router/guard.ts`

```typescript
// 1. 检查是否为核心路由（无需认证）
if (isInCoreRoutes(to)) return next();

// 2. 检查 Token
if (!accessToken) {
  return redirectLogin();
}

// 3. 加载字典数据（非阻塞）
dictStore.loadDict();

// 4. 获取用户信息
if (!isAccessChecked) {
  await fetchUserInfo();
  await generateRoutes();
  return next(to.fullPath);
}

// 5. 检查页面权限
if (!hasPagePermission(to)) {
  return redirectForbidden();
}
```

#### Flutter 迁移模板 (go_router)

```dart
// lib/router/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final accessStore = ref.watch(accessStoreProvider);

  return GoRouter(
    routes: [
      // 核心路由（无需认证）
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthLayout(),
        routes: [
          GoRoute(path: 'login', builder: (context, state) => const LoginPage()),
          GoRoute(path: 'register', builder: (context, state) => const RegisterPage()),
        ],
      ),
      // 需要认证的路由
      ShellRoute(
        builder: (context, state, child) => BasicLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomePage(),
          ),
          // 动态路由将通过代码生成添加
          ..._buildDynamicRoutes(accessStore.accessMenus),
        ],
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = accessStore.accessToken != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isAuthenticated && !isAuthRoute) {
        return '/auth/login?redirect=${state.matchedLocation}';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/';
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(ref),
  );
}

// 动态路由生成
List<GoRoute> _buildDynamicRoutes(List<Menu> menus) {
  return menus.map((menu) {
    return GoRoute(
      path: menu.path,
      name: menu.name,
      builder: (context, state) {
        // 根据组件名动态加载页面
        return PageFactory.create(menu.component);
      },
    );
  }).toList();
}
```

---

### 7. 字典系统

#### 字典类型定义
位置: `packages/constants/src/dict.ts`

```typescript
export const DICT_TYPE = {
  // 系统字典
  SYSTEM_USER_SEX: 'system_user_sex',
  SYSTEM_STATUS: 'system_status',
  // 业务字典
  BPM_MODEL_FORM_TYPE: 'bpm_model_form_type',
  // ...
} as const;
```

#### 字典使用方式

```typescript
// 获取字典选项
const options = getDictOptions(DICT_TYPE.SYSTEM_USER_SEX);
// [{ label: '男', value: 1 }, { label: '女', value: 2 }]

// 获取字典标签
const label = getDictLabel(DICT_TYPE.SYSTEM_USER_SEX, 1);
// '男'

// 获取带颜色的标签
<DictTag :type="DICT_TYPE.SYSTEM_USER_SEX" :value="row.sex" />
```

#### Flutter 迁移模板

```dart
// lib/constants/dict_type.dart
class DictType {
  static const String systemUserSex = 'system_user_sex';
  static const String systemStatus = 'system_status';
  static const String bpmModelFormType = 'bpm_model_form_type';
  // ...
}

// lib/widgets/dict_tag.dart
class DictTag extends ConsumerWidget {
  final String dictType;
  final dynamic value;
  final TextStyle? style;

  const DictTag({
    required this.dictType,
    required this.value,
    this.style,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictStore = ref.watch(dictStoreProvider);
    final item = dictStore.getDictItem(dictType, value);

    if (item == null) return Text('-');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor(item.colorType),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        item.label,
        style: style ?? const TextStyle(fontSize: 12),
      ),
    );
  }

  Color _getColor(String? colorType) {
    switch (colorType) {
      case 'success': return Colors.green;
      case 'warning': return Colors.orange;
      case 'danger': return Colors.red;
      case 'info': return Colors.blue;
      default: return Colors.grey;
    }
  }
}

// 使用示例
DictTag(dictType: DictType.systemUserSex, value: user.sex)
```

---

### 8. 公共类型定义

#### 分页参数和结果
位置: `packages/types/src/global.d.ts`

```typescript
// 分页参数
interface PageParam {
  pageNo: number;
  pageSize: number;
  [key: string]: any;
}

// 分页结果
interface PageResult<T> {
  list: T[];
  total: number;
}

// HTTP 响应
interface HttpResponse<T> {
  code: number;  // 0 = 成功
  data: T;
  msg: string;
}

// 通用状态枚举
enum CommonStatusEnum {
  ENABLE = 0,   // 开启
  DISABLE = 1,  // 关闭
}
```

#### Flutter 迁移

```dart
// lib/models/common/page_param.dart
class PageParam {
  final int pageNo;
  final int pageSize;
  final Map<String, dynamic> extra;

  PageParam({
    this.pageNo = 1,
    this.pageSize = 10,
    Map<String, dynamic>? extra,
  }) : extra = extra ?? {};

  Map<String, dynamic> toJson() => {
    'pageNo': pageNo,
    'pageSize': pageSize,
    ...extra,
  };
}

// lib/models/common/page_result.dart
class PageResult<T> {
  final List<T> list;
  final int total;

  PageResult({required this.list, required this.total});

  factory PageResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PageResult(
      list: (json['list'] as List).map((e) => fromJsonT(e)).toList(),
      total: json['total'] as int,
    );
  }
}

// lib/models/common/api_response.dart
class ApiResponse<T> {
  final int code;
  final T? data;
  final String msg;

  bool get isSuccess => code == 0;

  ApiResponse({required this.code, this.data, required this.msg});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse(
      code: json['code'] as int,
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      msg: json['msg'] as String,
    );
  }
}

// lib/constants/common_status.dart
enum CommonStatus {
  enable(0, '开启'),
  disable(1, '关闭');

  final int value;
  final String label;
  const CommonStatus(this.value, this.label);
}
```

---

## 迁移清单

### 环境配置
- [ ] Dio HTTP 客户端配置
- [ ] 拦截器配置 (Auth, Tenant, Language)
- [ ] Token 刷新机制
- [ ] 安全存储 (flutter_secure_storage)

### 状态管理
- [ ] AccessStore (认证状态)
- [ ] UserStore (用户信息)
- [ ] DictStore (字典缓存)
- [ ] 持久化配置

### API 层
- [ ] API 客户端封装
- [ ] 请求拦截器
- [ ] 响应拦截器
- [ ] 错误处理

### 路由
- [ ] go_router 配置
- [ ] 路由守卫
- [ ] 动态路由生成
- [ ] 权限中间件

### 组件
- [ ] SchemaForm (表单生成)
- [ ] SchemaTable (表格生成)
- [ ] DictTag (字典标签)
- [ ] TableAction (操作按钮)
- [ ] FileUpload (文件上传)

### 工具
- [ ] 日期格式化
- [ ] 树形数据处理
- [ ] 权限检查

---

## 项目关键文件路径

```
apps/web-antd/src/
├── api/
│   ├── request.ts              # 请求客户端配置
│   └── {module}/index.ts       # API 模块定义
├── store/
│   └── auth.ts                 # 认证 Store
├── views/
│   └── {module}/
│       ├── index.vue           # 列表页
│       ├── data.ts             # 表格/表单配置
│       └── modules/
│           ├── form.vue        # 表单弹窗
│           └── detail.vue      # 详情页
├── router/
│   ├── routes/                 # 路由配置
│   ├── guard.ts                # 路由守卫
│   └── access.ts               # 动态路由
└── components/
    ├── table-action/           # 表格操作组件
    └── dict-tag/               # 字典标签组件

packages/
├── stores/src/modules/
│   ├── access.ts               # 认证状态
│   ├── user.ts                 # 用户状态
│   └── dict.ts                 # 字典状态
├── effects/
│   ├── access/                 # 权限控制
│   └── request/                 # 请求封装
├── constants/src/
│   └── dict.ts                 # 字典常量
└── types/src/
    └── global.d.ts              # 类型定义
```

---

## 常用代码片段

### 创建新的 CRUD 模块

**1. API 定义** (`lib/api/system/xxx_api.dart`)
```dart
class XxxApi {
  static Future<PageResult<Xxx>> getXxxPage(PageParam params);
  static Future<Xxx> getXxx(int id);
  static Future<void> createXxx(Xxx data);
  static Future<void> updateXxx(Xxx data);
  static Future<void> deleteXxx(int id);
}
```

**2. 数据模型** (`lib/models/system/xxx.dart`)
```dart
@JsonSerializable()
class Xxx {
  final int? id;
  final String name;
  final int status;
  // ...
}
```

**3. 列表页** (`lib/pages/system/xxx/xxx_list_page.dart`)
```dart
class XxxListPage extends StatelessWidget {
  // SchemaTable with search form and actions
}
```

**4. 表单弹窗** (`lib/pages/system/xxx/xxx_form_dialog.dart`)
```dart
class XxxFormDialog extends StatelessWidget {
  // SchemaForm in Dialog
}
```

### 权限控制

```dart
// 按钮级权限
if (ref.read(accessStoreProvider).hasPermission('system:user:create')) {
  // 显示创建按钮
}

// Widget 级权限
PermissionGuard(
  permissions: ['system:user:update'],
  child: ElevatedButton(onPressed: handleEdit, child: Text('编辑')),
)
```

---

此 Skill 文档将持续更新，记录项目迁移过程中的模式和最佳实践。