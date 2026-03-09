# TypeScript 路由系统分析文档

> 本文档分析了 `source-code/router` 目录下的 TypeScript 路由实现，供 Flutter 路由迁移参考。

## 目录

1. [路由实例创建](#1-路由实例创建)
2. [路由路径与组件映射](#2-路由路径与组件映射)
3. [路由守卫逻辑](#3-路由守卫逻辑)
4. [动态路由生成机制](#4-动态路由生成机制)
5. [路由元信息(Meta)结构](#5-路由元信息meta结构)
6. [菜单与路由的关系](#6-菜单与路由的关系)

---

## 1. 路由实例创建

### 文件位置
`source-code/router/index.ts`

### 核心代码

```typescript
import { createRouter, createWebHashHistory, createWebHistory } from 'vue-router';

const router = createRouter({
  history:
    import.meta.env.VITE_ROUTER_HISTORY === 'hash'
      ? createWebHashHistory(import.meta.env.VITE_BASE)
      : createWebHistory(import.meta.env.VITE_BASE),
  routes,
  scrollBehavior: (to, _from, savedPosition) => {
    if (savedPosition) {
      return savedPosition;
    }
    return to.hash ? { behavior: 'smooth', el: to.hash } : { left: 0, top: 0 };
  },
});

// 创建路由守卫
createRouterGuard(router);
// 设置百度统计
setupBaiduTongJi(router);
```

### 关键点

| 配置项 | 说明 |
|--------|------|
| `history` | 支持 hash 模式和 history 模式，通过环境变量 `VITE_ROUTER_HISTORY` 切换 |
| `routes` | 初始路由列表，包含核心路由、外部路由和404兜底路由 |
| `scrollBehavior` | 滚动行为：优先恢复上次位置，否则滚动到顶部或锚点位置 |

---

## 2. 路由路径与组件映射

### 2.1 核心路由 (core.ts)

核心路由是应用启动时必须加载的基础路由，不需要权限验证。

| 路径 | 名称 | 组件 | 说明 |
|------|------|------|------|
| `/` | Root | `#/layouts/basic.vue` | 根路由，使用 BasicLayout，重定向到默认首页 |
| `/auth` | Authentication | `#/layouts/auth.vue` | 认证布局路由 |
| `/auth/login` | Login | `#/views/_core/authentication/login.vue` | 登录页 |
| `/auth/code-login` | CodeLogin | `#/views/_core/authentication/code-login.vue` | 验证码登录 |
| `/auth/qrcode-login` | QrCodeLogin | `#/views/_core/authentication/qrcode-login.vue` | 二维码登录 |
| `/auth/forget-password` | ForgetPassword | `#/views/_core/authentication/forget-password.vue` | 忘记密码 |
| `/auth/register` | Register | `#/views/_core/authentication/register.vue` | 注册页 |
| `/auth/social-login` | SocialLogin | `#/views/_core/authentication/social-login.vue` | 社交登录 |
| `/auth/sso-login` | SSOLogin | `#/views/_core/authentication/sso-login.vue` | SSO登录 |
| `/bpm/mobile/form-preview` | BpmMobileFormPreview | `#/views/bpm/form/mobile/index.vue` | 移动端流程表单 |
| `/:path(.*)*` | FallbackNotFound | `#/views/_core/fallback/not-found.vue` | 404页面 |

### 2.2 动态路由模块

动态路由通过 `import.meta.glob('./modules/**/*.ts', { eager: true })` 自动加载，包含以下模块：

#### Dashboard 模块 (dashboard.ts)

| 路径 | 名称 | 组件 | Meta |
|------|------|------|------|
| `/dashboard` | Dashboard | - | icon: lucide:layout-dashboard, order: -1 |
| `/workspace` | Workspace | `#/views/dashboard/workspace/index.vue` | icon: carbon:workspace |
| `/analytics` | Analytics | `#/views/dashboard/analytics/index.vue` | icon: lucide:area-chart, affixTab: true |
| `/profile` | Profile | `#/views/_core/profile/index.vue` | hideInMenu: true |

#### System 模块 (system.ts)

| 路径 | 名称 | 组件 | Meta |
|------|------|------|------|
| `/system/notify-message` | MyNotifyMessage | `#/views/system/notify/my/index.vue` | hideInMenu: true |

#### BPM 工作流模块 (bpm.ts)

| 路径 | 名称 | 组件 | Meta |
|------|------|------|------|
| `/bpm` | bpm | - | hideInMenu: true |
| `/bpm/process-instance/detail` | BpmProcessInstanceDetail | `#/views/bpm/processInstance/detail/index.vue` | hideInMenu: true, keepAlive: false |
| `/bpm/manager/form/edit` | BpmFormEditor | `#/views/bpm/form/designer/index.vue` | activePath: /bpm/manager/form |
| `/bpm/manager/model/create` | BpmModelCreate | `#/views/bpm/model/form/index.vue` | hideInMenu: true, keepAlive: true |
| `/bpm/manager/model/:type/:id` | BpmModelUpdate | `#/views/bpm/model/form/index.vue` | hideInMenu: true, keepAlive: true |
| `/bpm/manager/definition` | BpmProcessDefinition | `#/views/bpm/model/definition/index.vue` | hideInMenu: true, keepAlive: true |
| `/bpm/process-instance/report` | BpmProcessInstanceReport | `#/views/bpm/processInstance/report/index.vue` | hideInMenu: true, keepAlive: true |

#### OA 请假模块 (leave.ts)

| 路径 | 名称 | 组件 | Meta |
|------|------|------|------|
| `/bpm/oa/leave` | OALeaveIndex | `#/views/bpm/oa/leave/index.vue` | activePath: /bpm/oa/leave |
| `/bpm/oa/leave/create` | OALeaveCreate | `#/views/bpm/oa/leave/create.vue` | activePath: /bpm/oa/leave |
| `/bpm/oa/leave/detail` | OALeaveDetail | `#/views/bpm/oa/leave/detail.vue` | activePath: /bpm/oa/leave |

#### AI 模块 (ai.ts)

| 路径 | 名称 | 组件 | Meta |
|------|------|------|------|
| `/ai` | Ai | - | hideInMenu: true |
| `/ai/image/square` | AiImageSquare | `#/views/ai/image/square/index.vue` | noCache: true, hidden: true, canTo: true |
| `/ai/knowledge/document` | AiKnowledgeDocument | `#/views/ai/knowledge/document/index.vue` | hidden: true, canTo: true |
| `/ai/knowledge/document/create` | AiKnowledgeDocumentCreate | `#/views/ai/knowledge/document/form/index.vue` | hidden: true, canTo: true |
| `/ai/knowledge/document/update` | AiKnowledgeDocumentUpdate | `#/views/ai/knowledge/document/form/index.vue` | hidden: true, canTo: true |
| `/ai/knowledge/retrieval` | AiKnowledgeRetrieval | `#/views/ai/knowledge/knowledge/retrieval/index.vue` | hidden: true, canTo: true |
| `/ai/knowledge/segment` | AiKnowledgeSegment | `#/views/ai/knowledge/segment/index.vue` | hidden: true, canTo: true |
| `/ai/workflow/create/:id(\d+)/:type(update|create)` | AiWorkflowCreate | `#/views/ai/workflow/form/index.vue` | hidden: true, canTo: true |
| `/ai/console/workflow/:type/:id` | AiWorkflowUpdate | `#/views/ai/workflow/form/index.vue` | hidden: true, canTo: true |

#### CRM 客户管理模块 (crm.ts)

| 路径 | 名称 | 组件 | Meta |
|------|------|------|------|
| `/crm` | CrmCenter | - | hideInMenu: true, keepAlive: true |
| `/crm/clue/detail/:id` | CrmClueDetail | `#/views/crm/clue/detail/index.vue` | activePath: /crm/clue |
| `/crm/customer/detail/:id` | CrmCustomerDetail | `#/views/crm/customer/detail/index.vue` | activePath: /crm/customer |
| `/crm/business/detail/:id` | CrmBusinessDetail | `#/views/crm/business/detail/index.vue` | activePath: /crm/business |
| `/crm/contract/detail/:id` | CrmContractDetail | `#/views/crm/contract/detail/index.vue` | activePath: /crm/contract |
| `/crm/receivable-plan/detail/:id` | CrmReceivablePlanDetail | `#/views/crm/receivable/plan/detail/index.vue` | activePath: /crm/receivable-plan |
| `/crm/receivable/detail/:id` | CrmReceivableDetail | `#/views/crm/receivable/detail/index.vue` | activePath: /crm/receivable |
| `/crm/contact/detail/:id` | CrmContactDetail | `#/views/crm/contact/detail/index.vue` | activePath: /crm/contact |
| `/crm/product/detail/:id` | CrmProductDetail | `#/views/crm/product/detail/index.vue` | activePath: /crm/product |

#### Mall 商城模块 (mall.ts)

| 路径 | 名称 | 组件 | Meta |
|------|------|------|------|
| `/mall/product` | ProductCenter | - | hideInMenu: true, keepAlive: true |
| `/mall/product/spu/add` | ProductSpuAdd | `#/views/mall/product/spu/form/index.vue` | activePath: /mall/product/spu |
| `/mall/product/spu/edit/:id(\d+)` | ProductSpuEdit | `#/views/mall/product/spu/form/index.vue` | activePath: /mall/product/spu |
| `/mall/product/spu/detail/:id(\d+)` | ProductSpuDetail | `#/views/mall/product/spu/form/index.vue` | activePath: /mall/product/spu |
| `/mall/trade` | TradeCenter | - | hideInMenu: true, keepAlive: true |
| `/mall/trade/order/detail/:id(\d+)` | TradeOrderDetail | `#/views/mall/trade/order/detail/index.vue` | activePath: /mall/trade/order |
| `/mall/trade/after-sale/detail/:id(\d+)` | TradeAfterSaleDetail | `#/views/mall/trade/afterSale/detail/index.vue` | activePath: /mall/trade/after-sale |
| `/diy` | DiyCenter | - | hideInMenu: true, keepAlive: true |
| `/diy/template/decorate/:id(\d+)` | DiyTemplateDecorate | `#/views/mall/promotion/diy/template/decorate/index.vue` | activePath: /mall/promotion/diy-template/diy-template |
| `/diy/page/decorate/:id` | DiyPageDecorate | `#/views/mall/promotion/diy/page/decorate/index.vue` | hidden: true, activePath: /mall/promotion/diy-template/diy-page |

#### IoT 物联网模块 (iot.ts)

| 路径 | 名称 | 组件 | Meta |
|------|------|------|------|
| `/iot` | IoTCenter | - | hideInMenu: true, keepAlive: true |
| `/iot/product/detail/:id` | IoTProductDetail | `#/views/iot/product/product/detail/index.vue` | activePath: /iot/device/product |
| `/iot/device/detail/:id` | IoTDeviceDetail | `#/views/iot/device/device/detail/index.vue` | activePath: /iot/device/device |
| `/iot/ota/firmware/detail/:id` | IoTOtaFirmwareDetail | `#/views/iot/ota/modules/firmware-detail/index.vue` | activePath: /iot/ota |

#### Infra 基础设施模块 (infra.ts)

| 路径 | 名称 | 组件 | Meta |
|------|------|------|------|
| `/infra/job/log` | InfraJobLog | `#/views/infra/job/logger/index.vue` | hideInMenu: true, keepAlive: false |
| `/infra/codegen/edit` | InfraCodegenEdit | `#/views/infra/codegen/edit/index.vue` | hideInMenu: true, keepAlive: true |

#### Member 会员模块 (member.ts)

| 路径 | 名称 | 组件 | Meta |
|------|------|------|------|
| `/member/user/detail` | MemberUserDetail | `#/views/member/user/detail/index.vue` | hideInMenu: true, activePath: /member/user |

#### Pay 支付模块 (pay.ts)

| 路径 | 名称 | 组件 | Meta |
|------|------|------|------|
| `/pay/cashier` | PayCashier | `#/views/pay/cashier/index.vue` | hideInMenu: true |

---

## 3. 路由守卫逻辑

### 文件位置
`source-code/router/guard.ts`

### 3.1 通用守卫 (setupCommonGuard)

```typescript
function setupCommonGuard(router: Router) {
  const loadedPaths = new Set<string>();

  router.beforeEach((to) => {
    // 标记页面是否已加载
    to.meta.loaded = loadedPaths.has(to.path);

    // 显示页面加载进度条
    if (!to.meta.loaded && preferences.transition.progress) {
      startProgress();
    }
    return true;
  });

  router.afterEach((to) => {
    // 记录已加载路径
    loadedPaths.add(to.path);

    // 关闭进度条
    if (preferences.transition.progress) {
      stopProgress();
    }
  });
}
```

### 3.2 权限访问守卫 (setupAccessGuard)

```typescript
function setupAccessGuard(router: Router) {
  router.beforeEach(async (to, from) => {
    const accessStore = useAccessStore();
    const userStore = useUserStore();
    const authStore = useAuthStore();
    const dictStore = useDictStore();

    // 1. 核心路由检查 - 不需要权限拦截
    if (coreRouteNames.includes(to.name as string)) {
      // 已登录用户访问登录页，重定向到首页
      if (to.path === LOGIN_PATH && accessStore.accessToken) {
        return decodeURIComponent(
          (to.query?.redirect as string) ||
            userStore.userInfo?.homePath ||
            preferences.app.defaultHomePath,
        );
      }
      return true;
    }

    // 2. AccessToken 检查
    if (!accessStore.accessToken) {
      // 路由标记为忽略权限，允许访问
      if (to.meta.ignoreAccess) {
        return true;
      }

      // 无权限，重定向到登录页
      if (to.fullPath !== LOGIN_PATH) {
        return {
          path: LOGIN_PATH,
          query: to.fullPath === preferences.app.defaultHomePath
            ? {}
            : { redirect: encodeURIComponent(to.fullPath) },
          replace: true,
        };
      }
      return to;
    }

    // 3. 检查是否已生成动态路由
    if (accessStore.isAccessChecked) {
      return true;
    }

    // 4. 加载字典数据（不阻塞）
    dictStore.setDictCacheByApi(getSimpleDictDataList);

    // 5. 获取用户信息
    let userInfo = userStore.userInfo;
    if (!userInfo) {
      const authPermissionInfo = await authStore.fetchUserInfo();
      if (authPermissionInfo) {
        userInfo = authPermissionInfo.user;
      }
    }

    // 6. 生成菜单和路由
    const { accessibleMenus, accessibleRoutes } = await generateAccess({
      roles: userStore.userRoles ?? [],
      router,
      routes: accessRoutes,
    });

    // 7. 保存菜单和路由信息
    accessStore.setAccessMenus(accessibleMenus);
    accessStore.setAccessRoutes(accessibleRoutes);
    accessStore.setIsAccessChecked(true);

    // 8. 重定向到目标页面
    return {
      ...router.resolve(decodeURIComponent(redirectPath)),
      replace: true,
    };
  });
}
```

### 守卫流程图

```
┌─────────────────────────────────────────────────────────────────┐
│                     路由守卫执行流程                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  beforeEach                                                     │
│       │                                                         │
│       ▼                                                         │
│  ┌─────────────────┐                                            │
│  │ 是核心路由？    │──是──▶ 检查是否登录页                       │
│  └────────┬────────┘              │                             │
│           │否                     ▼                             │
│           │              ┌─────────────────┐                    │
│           │              │ 已登录？        │                    │
│           │              └────────┬────────┘                    │
│           │                       │是                           │
│           │                       ▼                             │
│           │              ┌─────────────────┐                    │
│           │              │ 允许访问/重定向  │                    │
│           │              └─────────────────┘                    │
│           │                       │否                           │
│           │                       ▼                             │
│           │              ┌─────────────────┐                    │
│           │              │ 重定向到登录页  │                    │
│           │              └─────────────────┘                    │
│           ▼                                                     │
│  ┌─────────────────┐                                            │
│  │ 有accessToken？ │──否──▶ 检查ignoreAccess                    │
│  └────────┬────────┘              │                             │
│           │是                     ▼                             │
│           │              ┌─────────────────┐                    │
│           │              │ 是：允许访问    │                    │
│           │              │ 否：跳转登录页  │                    │
│           │              └─────────────────┘                    │
│           ▼                                                     │
│  ┌─────────────────┐                                            │
│  │已生成动态路由？ │──是──▶ 允许访问                            │
│  └────────┬────────┘                                            │
│           │否                                                   │
│           ▼                                                     │
│  ┌─────────────────┐                                            │
│  │ 加载用户信息    │                                            │
│  │ 加载字典数据    │                                            │
│  │ 生成动态路由    │                                            │
│  │ 保存菜单和路由  │                                            │
│  └────────┬────────┘                                            │
│           │                                                     │
│           ▼                                                     │
│  ┌─────────────────┐                                            │
│  │ 重定向到目标页  │                                            │
│  └─────────────────┘                                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. 动态路由生成机制

### 文件位置
`source-code/router/access.ts`

### 核心代码

```typescript
async function generateAccess(options: GenerateMenuAndRoutesOptions) {
  const pageMap: ComponentRecordType = import.meta.glob('../views/**/*.vue');
  const accessStore = useAccessStore();

  const layoutMap: ComponentRecordType = {
    BasicLayout,
    IFrameView,
  };

  return await generateAccessible(preferences.app.accessMode, {
    ...options,
    fetchMenuListAsync: async () => {
      // 从 accessStore 获取后端返回的菜单数据
      const accessMenus = accessStore.accessMenus as AppRouteRecordRaw[];
      return convertServerMenuToRouteRecordStringComponent(accessMenus);
    },
    forbiddenComponent,
    layoutMap,
    pageMap,
  });
}
```

### 路由分类

```
┌─────────────────────────────────────────────────────────────────┐
│                        路由分类体系                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  routes (初始路由)                                               │
│  ├── coreRoutes (核心路由)                                       │
│  │   ├── Root (/) - 基础布局容器                                 │
│  │   ├── Authentication (/auth) - 认证相关页面                   │
│  │   └── BpmMobileFormPreview - 特殊页面                         │
│  ├── externalRoutes (外部路由) - 不需要Layout                    │
│  └── fallbackNotFoundRoute - 404兜底路由                         │
│                                                                 │
│  accessRoutes (权限路由)                                         │
│  ├── dynamicRoutes (动态路由)                                    │
│  │   ├── system.ts                                              │
│  │   ├── dashboard.ts                                           │
│  │   ├── bpm.ts                                                 │
│  │   ├── ai.ts                                                  │
│  │   ├── crm.ts                                                 │
│  │   ├── mall.ts                                                │
│  │   ├── iot.ts                                                 │
│  │   ├── infra.ts                                               │
│  │   ├── member.ts                                              │
│  │   ├── pay.ts                                                 │
│  │   └── leave.ts                                               │
│  └── staticRoutes (静态路由)                                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 动态路由加载流程

```
┌─────────────────────────────────────────────────────────────────┐
│                    动态路由加载流程                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. 用户登录成功                                                 │
│        │                                                        │
│        ▼                                                        │
│  2. 访问受保护路由触发守卫                                        │
│        │                                                        │
│        ▼                                                        │
│  3. 检查 isAccessChecked = false                                │
│        │                                                        │
│        ▼                                                        │
│  4. 调用 authStore.fetchUserInfo()                               │
│        │                                                        │
│        ▼                                                        │
│  5. 获取 accessStore.accessMenus (后端菜单数据)                  │
│        │                                                        │
│        ▼                                                        │
│  6. convertServerMenuToRouteRecordStringComponent()             │
│        │                                                        │
│        ▼                                                        │
│  7. generateAccessible() 生成可访问路由                          │
│        │                                                        │
│        ├── pageMap: views/**/*.vue 组件映射                      │
│        ├── layoutMap: BasicLayout, IFrameView                   │
│        └── forbiddenComponent: 403页面                           │
│        │                                                        │
│        ▼                                                        │
│  8. 保存路由到 accessStore.setAccessRoutes()                     │
│        │                                                        │
│        ▼                                                        │
│  9. 设置 isAccessChecked = true                                 │
│        │                                                        │
│        ▼                                                        │
│  10. 重定向到目标页面                                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. 路由元信息(Meta)结构

### Meta 属性定义

```typescript
interface RouteMeta {
  // 基础属性
  title: string;              // 页面标题
  icon?: string;              // 菜单图标

  // 显示控制
  hideInMenu?: boolean;       // 是否在菜单中隐藏
  hideInTab?: boolean;        // 是否在标签页中隐藏
  hideInBreadcrumb?: boolean; // 是否在面包屑中隐藏

  // 缓存控制
  keepAlive?: boolean;         // 是否缓存组件
  noCache?: boolean;           // 是否禁用缓存

  // 权限控制
  ignoreAccess?: boolean;      // 忽略权限检查
  canTo?: boolean;             // 是否可访问

  // 导航控制
  activePath?: string;         // 激活的菜单路径（用于高亮父菜单）
  redirect?: string;           // 重定向路径

  // 标签页控制
  affixTab?: boolean;          // 是否固定在标签栏

  // 排序
  order?: number;              // 菜单排序

  // 其他
  hidden?: boolean;            // 是否隐藏
  loaded?: boolean;            // 页面是否已加载（运行时）

  // 权限相关
  menuVisibleWithForbidden?: boolean; // 无权限时菜单仍可见
}
```

### Meta 属性使用场景

| 属性 | 类型 | 说明 | 使用场景 |
|------|------|------|----------|
| `title` | string | 页面标题 | 所有路由，用于菜单、面包屑、标签页显示 |
| `icon` | string | 菜单图标 | 一级菜单、二级菜单 |
| `hideInMenu` | boolean | 隐藏菜单项 | 详情页、编辑页等不需要在菜单显示的页面 |
| `hideInTab` | boolean | 隐藏标签页 | 登录页、404页等 |
| `hideInBreadcrumb` | boolean | 隐藏面包屑 | 根路由、404页 |
| `keepAlive` | boolean | 组件缓存 | 列表页、需要保持状态的页面 |
| `activePath` | string | 激活菜单路径 | 详情页、编辑页需要高亮对应的父菜单 |
| `ignoreAccess` | boolean | 忽略权限 | 无需登录即可访问的页面 |
| `affixTab` | boolean | 固定标签页 | 首页等常用页面 |
| `order` | number | 菜单排序 | 控制菜单显示顺序，值越小越靠前 |

### Meta 属性示例

```typescript
// 普通菜单项
{
  path: '/dashboard',
  meta: {
    title: '仪表盘',
    icon: 'lucide:layout-dashboard',
    order: -1,
  }
}

// 隐藏的详情页
{
  path: '/crm/customer/detail/:id',
  meta: {
    title: '客户详情',
    activePath: '/crm/customer',  // 高亮客户菜单
    hideInMenu: true,
  }
}

// 需要缓存的页面
{
  path: '/iot',
  meta: {
    title: 'IoT 物联网',
    keepAlive: true,
    hideInMenu: true,
  }
}

// 无需权限的页面
{
  path: '/bpm/mobile/form-preview',
  meta: {
    title: '移动端流程表单',
    ignoreAccess: true,
    hideInMenu: true,
    hideInTab: true,
  }
}
```

---

## 6. 菜单与路由的关系

### 6.1 菜单数据来源

菜单数据主要来源于后端API返回，存储在 `accessStore.accessMenus` 中：

```typescript
// guard.ts
const authPermissionInfo = await authStore.fetchUserInfo();

// access.ts
const accessMenus = accessStore.accessMenus as AppRouteRecordRaw[];
return convertServerMenuToRouteRecordStringComponent(accessMenus);
```

### 6.2 菜单与路由的映射

```
┌─────────────────────────────────────────────────────────────────┐
│                    菜单与路由映射关系                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  后端菜单数据 (accessMenus)                                      │
│  {                                                              │
│    name: 'System',                                              │
│    path: '/system',                                             │
│    component: 'LAYOUT',           ─────┐                        │
│    meta: { title: '系统管理', icon: '...' },                    │
│    children: [                                                  │
│      {                                                          │
│        name: 'User',                                            │
│        path: 'user',                                            │
│        component: 'views/system/user/index',  ─────┐            │
│        meta: { title: '用户管理' },                             │
│      }                                                          │
│    ]                                                            │
│  }                                                              │
│                                                                 │
│                              转换                                │
│                                                                 │
│  前端路由数据 (RouteRecordRaw)                                   │
│  {                                                              │
│    name: 'System',                                              │
│    path: '/system',                                             │
│    component: BasicLayout,        ◄─────┘                        │
│    meta: { title: '系统管理', icon: '...' },                     │
│    children: [                                                  │
│      {                                                          │
│        name: 'User',                                            │
│        path: 'user',                                            │
│        component: () => import('#/views/system/user/index.vue'),│
│        meta: { title: '用户管理' },                              │
│      }                                                          │
│    ]                                                            │
│  }                                                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 6.3 组件映射规则

```typescript
// access.ts
const pageMap: ComponentRecordType = import.meta.glob('../views/**/*.vue');

const layoutMap: ComponentRecordType = {
  BasicLayout,
  IFrameView,
};

// 后端返回的 component 字符串转换为实际组件
// 'views/system/user/index' -> () => import('#/views/system/user/index.vue')
// 'LAYOUT' -> BasicLayout
// 'IFRAME' -> IFrameView
```

### 6.4 菜单显示控制

| Meta 属性 | 效果 |
|-----------|------|
| `hideInMenu: true` | 不在侧边菜单显示 |
| `hideInTab: true` | 不在标签页显示 |
| `hideInBreadcrumb: true` | 不在面包屑显示 |
| `activePath` | 子页面激活时高亮指定的父菜单 |

### 6.5 前端静态路由与后端动态路由的结合

```
┌─────────────────────────────────────────────────────────────────┐
│                  前端静态路由 + 后端动态路由                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  前端静态路由 (accessRoutes)                                     │
│  ├── 定义在 modules/*.ts 文件中                                  │
│  ├── 用于隐藏菜单但需要权限控制的页面                             │
│  │   ├── 详情页 (hideInMenu: true)                              │
│  │   ├── 编辑页 (hideInMenu: true)                              │
│  │   └── 特殊功能页                                              │
│  └── 示例:                                                       │
│      ├── /system/notify-message - 我的站内信                    │
│      ├── /bpm/process-instance/detail - 流程详情                │
│      ├── /crm/customer/detail/:id - 客户详情                     │
│      └── /mall/product/spu/edit/:id - 商品编辑                   │
│                                                                 │
│  后端动态路由 (accessMenus)                                      │
│  ├── 由后端API返回                                               │
│  ├── 用于生成菜单和大部分业务页面                                 │
│  └── 通过 convertServerMenuToRouteRecordStringComponent 转换    │
│                                                                 │
│  合并后                                                          │
│  accessibleRoutes = [...后端路由, ...前端静态路由]               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 7. Flutter 迁移建议

### 7.1 路由结构迁移

```dart
// 建议使用 go_router 或 auto_route
// 路由定义示例
final router = GoRouter(
  routes: [
    // 核心路由
    GoRoute(
      path: '/',
      builder: (context, state) => const BasicLayout(),
      routes: [
        // 首页
        GoRoute(
          path: 'dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        // 业务路由由后端动态生成
      ],
    ),
    // 认证路由
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthLayout(),
      routes: [
        GoRoute(
          path: 'login',
          builder: (context, state) => const LoginPage(),
        ),
      ],
    ),
  ],
);
```

### 7.2 路由守卫迁移

```dart
// 使用 GoRouter 的 redirect 实现权限守卫
final router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = authStore.isLoggedIn;
    final isAuthRoute = state.uri.path.startsWith('/auth');

    if (!isLoggedIn && !isAuthRoute) {
      return '/auth/login?redirect=${state.uri.path}';
    }

    if (isLoggedIn && isAuthRoute) {
      return '/';
    }

    return null;
  },
);
```

### 7.3 Meta 信息迁移

```dart
// 定义路由元信息
class RouteMeta {
  final String title;
  final String? icon;
  final bool hideInMenu;
  final bool hideInTab;
  final bool keepAlive;
  final String? activePath;
  final bool ignoreAccess;

  const RouteMeta({
    required this.title,
    this.icon,
    this.hideInMenu = false,
    this.hideInTab = false,
    this.keepAlive = false,
    this.activePath,
    this.ignoreAccess = false,
  });
}
```

### 7.4 动态路由迁移

```dart
// 从后端加载菜单并生成路由
Future<List<RouteBase>> generateDynamicRoutes(List<MenuVO> menus) async {
  return menus.map((menu) {
    if (menu.component == 'LAYOUT') {
      return ShellRoute(
        builder: (context, state, child) => BasicLayout(child: child),
        routes: generateDynamicRoutes(menu.children),
      );
    }

    return GoRoute(
      path: menu.path,
      name: menu.name,
      builder: (context, state) => createPage(menu.component),
    );
  }).toList();
}
```

---

## 附录：关键文件路径

| 文件 | 路径 | 说明 |
|------|------|------|
| 路由实例 | `source-code/router/index.ts` | 创建路由实例 |
| 路由守卫 | `source-code/router/guard.ts` | 权限验证逻辑 |
| 动态路由 | `source-code/router/access.ts` | 动态路由生成 |
| 核心路由 | `source-code/router/routes/core.ts` | 基础路由配置 |
| 路由索引 | `source-code/router/routes/index.ts` | 路由模块聚合 |
| System模块 | `source-code/router/routes/modules/system.ts` | 系统路由 |
| Dashboard模块 | `source-code/router/routes/modules/dashboard.ts` | 仪表盘路由 |
| BPM模块 | `source-code/router/routes/modules/bpm.ts` | 工作流路由 |
| AI模块 | `source-code/router/routes/modules/ai.ts` | AI路由 |
| CRM模块 | `source-code/router/routes/modules/crm.ts` | 客户管理路由 |
| Mall模块 | `source-code/router/routes/modules/mall.ts` | 商城路由 |
| IoT模块 | `source-code/router/routes/modules/iot.ts` | 物联网路由 |
| Infra模块 | `source-code/router/routes/modules/infra.ts` | 基础设施路由 |
| Member模块 | `source-code/router/routes/modules/member.ts` | 会员路由 |
| Pay模块 | `source-code/router/routes/modules/pay.ts` | 支付路由 |
| Leave模块 | `source-code/router/routes/modules/leave.ts` | 请假路由 |