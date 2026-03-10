import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../stores/access_store.dart';
import '../pages/auth/login_page.dart';
import '../pages/layout/basic_layout.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../pages/system/user/user_page.dart';
import '../pages/system/role/role_page.dart';
import '../pages/system/menu/menu_page.dart';
import '../pages/system/dept/dept_page.dart';
import '../pages/system/dict/dict_page.dart';
import '../pages/system/dict/dict_type_page.dart';
import '../pages/system/dict/dict_data_page.dart';
import '../pages/system/area/area_page.dart';
import '../pages/system/loginlog/login_log_page.dart';
import '../pages/system/oauth2_client/oauth2_client_page.dart';
import '../pages/system/oauth2_token/oauth2_token_page.dart';
import '../pages/system/operatelog/operate_log_page.dart';
import '../pages/system/social_client/social_client_page.dart';
import '../pages/system/social_user/social_user_page.dart';
import '../pages/system/notice/notice_page.dart';
import '../pages/system/post/post_page.dart';
import '../pages/system/tenant/tenant_page.dart';
import '../pages/system/tenant_package/tenant_package_page.dart';
import '../pages/system/notify_message/notify_message_page.dart';
import '../pages/system/notify_template/notify_template_page.dart';
import '../pages/system/mail/account/mail_account_page.dart';
import '../pages/system/mail/log/mail_log_page.dart';
import '../pages/system/mail/template/mail_template_page.dart';
import '../pages/system/sms/channel/sms_channel_page.dart';
import '../pages/system/sms/log/sms_log_page.dart';
import '../pages/system/sms/template/sms_template_page.dart';

// ==================== 路由路径常量 ====================

/// 路由路径常量
class Routes {
  Routes._();

  // ==================== 核心路由 ====================
  static const String login = '/login';
  static const String dashboard = '/';
  static const String forbidden = '/403';
  static const String notFound = '/404';

  // ==================== 仪表板路由 ====================
  static const String workspace = '/workspace';
  static const String analytics = '/analytics';
  static const String profile = '/profile';

  // ==================== 认证路由 ====================
  static const String auth = '/auth';
  static const String codeLogin = '/auth/code-login';
  static const String qrCodeLogin = '/auth/qrcode-login';
  static const String forgetPassword = '/auth/forget-password';
  static const String register = '/auth/register';
  static const String socialLogin = '/auth/social-login';
  static const String ssoLogin = '/auth/sso-login';

  // ==================== 系统管理路由 ====================
  static const String system = '/system';
  static const String user = '/system/user';
  static const String role = '/system/role';
  static const String menu = '/system/menu';
  static const String dept = '/system/dept';
  static const String dict = '/system/dict';
  static const String dictType = '/system/dict-type';
  static const String dictData = '/system/dict-data';
  static const String area = '/system/area';
  static const String loginLog = '/system/login-log';
  static const String oauth2Client = '/system/oauth2-client';
  static const String oauth2Token = '/system/oauth2-token';
  static const String operateLog = '/system/operate-log';
  static const String socialClient = '/system/social-client';
  static const String socialUser = '/system/social-user';
  static const String notice = '/system/notice';
  static const String post = '/system/post';
  static const String tenant = '/system/tenant';
  static const String tenantPackage = '/system/tenant-package';
  static const String notifyMessage = '/system/notify-message';
  static const String notifyTemplate = '/system/notify-template';

  // ==================== 邮件管理路由 ====================
  static const String mailAccount = '/system/mail-account';
  static const String mailTemplate = '/system/mail-template';
  static const String mailLog = '/system/mail-log';

  // ==================== 短信管理路由 ====================
  static const String smsChannel = '/system/sms-channel';
  static const String smsLog = '/system/sms-log';
  static const String smsTemplate = '/system/sms-template';

  // ==================== BPM流程路由 ====================
  static const String bpmMobileFormPreview = '/bpm/mobile/form-preview';

  // ==================== 路由名称 ====================
  static const String loginName = 'Login';
  static const String dashboardName = 'Dashboard';
  static const String workspaceName = 'Workspace';
  static const String analyticsName = 'Analytics';
  static const String profileName = 'Profile';
  static const String forbiddenName = 'Forbidden';
  static const String notFoundName = 'NotFound';
}

// ==================== 核心路由配置 ====================

/// 核心路由名称列表（不需要权限验证的路由）
/// 参考 TypeScript 版本的 coreRouteNames
const coreRouteNames = [
  Routes.loginName,
  Routes.forbiddenName,
  Routes.notFoundName,
  'CodeLogin',
  'QrCodeLogin',
  'ForgetPassword',
  'Register',
  'SocialLogin',
  'SSOLogin',
];

/// 核心路由路径列表（不需要权限验证的路由）
/// 参考 TypeScript 版本的 coreRoutes
const coreRoutePaths = [
  Routes.login,
  Routes.forbidden,
  Routes.notFound,
  Routes.auth,
  Routes.codeLogin,
  Routes.qrCodeLogin,
  Routes.forgetPassword,
  Routes.register,
  Routes.socialLogin,
  Routes.ssoLogin,
  Routes.bpmMobileFormPreview,
];

// ==================== 路由元数据 ====================

/// 路由元数据
/// 参考 TypeScript 版本的 RouteMeta
class RouteMeta {
  final String title;
  final String? icon;
  final bool hideInMenu;
  final bool hideInTab;
  final bool hideInBreadcrumb;
  final bool ignoreAccess;
  final bool affixTab;
  final int? order;

  const RouteMeta({
    required this.title,
    this.icon,
    this.hideInMenu = false,
    this.hideInTab = false,
    this.hideInBreadcrumb = false,
    this.ignoreAccess = false,
    this.affixTab = false,
    this.order,
  });
}

/// 路由元数据映射
final Map<String, RouteMeta> routeMetaMap = {
  Routes.login: const RouteMeta(title: '登录', hideInMenu: true, ignoreAccess: true),
  Routes.forbidden: const RouteMeta(title: '无权访问', hideInMenu: true, ignoreAccess: true),
  Routes.notFound: const RouteMeta(title: '页面未找到', hideInMenu: true, ignoreAccess: true),
  Routes.dashboard: const RouteMeta(
    title: '仪表板',
    icon: 'lucide:layout-dashboard',
    order: -1,
  ),
  Routes.workspace: const RouteMeta(title: '工作台', icon: 'carbon:workspace'),
  Routes.analytics: const RouteMeta(
    title: '分析页',
    icon: 'lucide:area-chart',
    affixTab: true,
  ),
  Routes.profile: const RouteMeta(
    title: '个人中心',
    icon: 'ant-design:profile-outlined',
    hideInMenu: true,
  ),
  Routes.user: const RouteMeta(title: '用户管理', icon: 'ant-design:user-outlined'),
  Routes.role: const RouteMeta(title: '角色管理', icon: 'ant-design:team-outlined'),
  Routes.menu: const RouteMeta(title: '菜单管理', icon: 'ant-design:menu-outlined'),
  Routes.dept: const RouteMeta(title: '部门管理', icon: 'ant-design:apartment-outlined'),
  Routes.dict: const RouteMeta(title: '字典管理', icon: 'ant-design:book-outlined'),
  Routes.dictType: const RouteMeta(title: '字典类型', icon: 'ant-design:book-outlined'),
  Routes.dictData: const RouteMeta(title: '字典数据', icon: 'ant-design:database-outlined'),
  Routes.area: const RouteMeta(title: '地区管理', icon: 'ant-design:global-outlined'),
  Routes.loginLog: const RouteMeta(title: '登录日志', icon: 'ant-design:login-outlined'),
  Routes.oauth2Client: const RouteMeta(title: 'OAuth2客户端', icon: 'ant-design:api-outlined'),
  Routes.oauth2Token: const RouteMeta(title: 'OAuth2令牌', icon: 'ant-design:key-outlined'),
  Routes.operateLog: const RouteMeta(title: '操作日志', icon: 'ant-design:file-text-outlined'),
  Routes.socialClient: const RouteMeta(title: '社交客户端', icon: 'ant-design:link-outlined'),
  Routes.socialUser: const RouteMeta(title: '社交用户', icon: 'ant-design:usergroup-outlined'),
  Routes.notice: const RouteMeta(title: '通知公告', icon: 'ant-design:notification-outlined'),
  Routes.post: const RouteMeta(title: '岗位管理', icon: 'ant-design:solution-outlined'),
  Routes.tenant: const RouteMeta(title: '租户管理', icon: 'ant-design:home-outlined'),
  Routes.tenantPackage: const RouteMeta(title: '租户套餐', icon: 'ant-design:gift-outlined'),
  Routes.notifyMessage: const RouteMeta(
    title: '我的站内信',
    icon: 'ant-design:message-filled',
    hideInMenu: true,
  ),
  Routes.notifyTemplate: const RouteMeta(
    title: '通知模板',
    icon: 'ant-design:notification-outlined',
  ),
  Routes.mailAccount: const RouteMeta(title: '邮箱账号', icon: 'ant-design:mail-outlined'),
  Routes.mailTemplate: const RouteMeta(
    title: '邮件模板',
    icon: 'ant-design:file-markdown-outlined',
  ),
  Routes.mailLog: const RouteMeta(title: '邮件日志', icon: 'ant-design:history-outlined'),
  Routes.smsChannel: const RouteMeta(title: '短信渠道', icon: 'ant-design:message-outlined'),
  Routes.smsLog: const RouteMeta(title: '短信日志', icon: 'ant-design:file-search-outlined'),
  Routes.smsTemplate: const RouteMeta(
    title: '短信模板',
    icon: 'ant-design:file-text-outlined',
  ),
  Routes.bpmMobileFormPreview: const RouteMeta(
    title: '移动端流程表单展示',
    hideInMenu: true,
    hideInTab: true,
    hideInBreadcrumb: true,
    ignoreAccess: true,
  ),
};

// ==================== 权限映射 ====================

/// 路由权限映射
/// 根据路径映射所需权限
final Map<String, String> routePermissionMap = {
  Routes.user: 'system:user:list',
  Routes.role: 'system:role:list',
  Routes.menu: 'system:menu:list',
  Routes.dept: 'system:dept:list',
  Routes.dict: 'system:dict:list',
  Routes.dictType: 'system:dict-type:list',
  Routes.dictData: 'system:dict-data:list',
  Routes.area: 'system:area:list',
  Routes.loginLog: 'system:login-log:list',
  Routes.oauth2Client: 'system:oauth2-client:list',
  Routes.oauth2Token: 'system:oauth2-token:list',
  Routes.operateLog: 'system:operate-log:list',
  Routes.socialClient: 'system:social-client:list',
  Routes.socialUser: 'system:social-user:list',
  Routes.notice: 'system:notice:list',
  Routes.post: 'system:post:list',
  Routes.tenant: 'system:tenant:list',
  Routes.tenantPackage: 'system:tenant-package:list',
  Routes.notifyMessage: 'system:notify-message:list',
  Routes.notifyTemplate: 'system:notify-template:list',
  Routes.mailAccount: 'system:mail-account:list',
  Routes.mailTemplate: 'system:mail-template:list',
  Routes.mailLog: 'system:mail-log:list',
  Routes.smsChannel: 'system:sms-channel:list',
  Routes.smsLog: 'system:sms-log:list',
  Routes.smsTemplate: 'system:sms-template:list',
};

// ==================== GoRouter 刷新流 ====================

/// 用于 go_router 的刷新流
/// 监听认证状态变化，触发路由刷新
class GoRouterRefreshStream extends ChangeNotifier {
  final Ref ref;

  GoRouterRefreshStream(this.ref) {
    ref.listen<AccessState>(accessStoreProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated) {
        notifyListeners();
      }
    });
  }
}

// ==================== 路由配置提供者 ====================

/// 路由配置提供者
/// 参考 TypeScript 版本的 router/index.ts 和 guard.ts 实现
final routerProvider = Provider<GoRouter>((ref) {
  final accessState = ref.watch(accessStoreProvider);

  return GoRouter(
    initialLocation: Routes.dashboard,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(ref),
    redirect: (context, state) {
      return _handleRedirect(context, state, accessState);
    },
    routes: [
      // ==================== 登录页（不需要BasicLayout） ====================
      GoRoute(
        path: Routes.login,
        name: Routes.loginName,
        builder: (context, state) => const LoginPage(),
      ),

      // ==================== 403禁止访问页面 ====================
      GoRoute(
        path: Routes.forbidden,
        name: Routes.forbiddenName,
        builder: (context, state) => const ForbiddenPage(),
      ),

      // ==================== 主布局路由（需要登录） ====================
      // ShellRoute 类似于 Vue 的 BasicLayout 嵌套
      // 所有子路由都会被包裹在 BasicLayout 中
      ShellRoute(
        builder: (context, state, child) {
          // 可以在这里添加全局布局逻辑
          // 例如：检查权限、加载菜单等
          return BasicLayout(child: child);
        },
        routes: [
          // ==================== 仪表板 ====================
          GoRoute(
            path: Routes.dashboard,
            name: Routes.dashboardName,
            builder: (context, state) => const DashboardPage(),
          ),

          // ==================== 工作台 ====================
          GoRoute(
            path: Routes.workspace,
            name: Routes.workspaceName,
            builder: (context, state) => const DashboardPage(),
          ),

          // ==================== 分析页 ====================
          GoRoute(
            path: Routes.analytics,
            name: Routes.analyticsName,
            builder: (context, state) => const DashboardPage(),
          ),

          // ==================== 个人中心 ====================
          GoRoute(
            path: Routes.profile,
            name: Routes.profileName,
            builder: (context, state) => const DashboardPage(),
          ),

          // ==================== 系统管理（嵌套路由） ====================
          GoRoute(
            path: Routes.system,
            name: 'system',
            redirect: (context, state) => Routes.user,
            routes: [
              // ==================== 系统管理 - 用户管理 ====================
              GoRoute(
                path: 'user',
                name: 'user',
                builder: (context, state) => const UserPage(),
              ),

              // ==================== 系统管理 - 角色管理 ====================
              GoRoute(
                path: 'role',
                name: 'role',
                builder: (context, state) => const RolePage(),
              ),

              // ==================== 系统管理 - 菜单管理 ====================
              GoRoute(
                path: 'menu',
                name: 'menu',
                builder: (context, state) => const MenuPage(),
              ),

              // ==================== 系统管理 - 部门管理 ====================
              GoRoute(
                path: 'dept',
                name: 'dept',
                builder: (context, state) => const DeptPage(),
              ),

              // ==================== 系统管理 - 字典管理 ====================
              GoRoute(
                path: 'dict',
                name: 'dict',
                builder: (context, state) => const DictPage(),
              ),

              // ==================== 系统管理 - 字典类型 ====================
              GoRoute(
                path: 'dict-type',
                name: 'dictType',
                builder: (context, state) => const DictTypePage(),
              ),

              // ==================== 系统管理 - 字典数据 ====================
              GoRoute(
                path: 'dict-data',
                name: 'dictData',
                builder: (context, state) {
                  final dictType = state.uri.queryParameters['dictType'];
                  return DictDataPage(dictType: dictType);
                },
              ),

              // ==================== 系统管理 - 地区管理 ====================
              GoRoute(
                path: 'area',
                name: 'area',
                builder: (context, state) => const AreaPage(),
              ),

              // ==================== 系统管理 - 登录日志 ====================
              GoRoute(
                path: 'login-log',
                name: 'loginLog',
                builder: (context, state) => const LoginLogPage(),
              ),

              // ==================== 系统管理 - OAuth2客户端 ====================
              GoRoute(
                path: 'oauth2-client',
                name: 'oauth2Client',
                builder: (context, state) => const OAuth2ClientPage(),
              ),

              // ==================== 系统管理 - OAuth2令牌 ====================
              GoRoute(
                path: 'oauth2-token',
                name: 'oauth2Token',
                builder: (context, state) => const OAuth2TokenPage(),
              ),

              // ==================== 系统管理 - 操作日志 ====================
              GoRoute(
                path: 'operate-log',
                name: 'operateLog',
                builder: (context, state) => const OperateLogPage(),
              ),

              // ==================== 系统管理 - 社交客户端 ====================
              GoRoute(
                path: 'social-client',
                name: 'socialClient',
                builder: (context, state) => const SocialClientPage(),
              ),

              // ==================== 系统管理 - 社交用户 ====================
              GoRoute(
                path: 'social-user',
                name: 'socialUser',
                builder: (context, state) => const SocialUserPage(),
              ),

              // ==================== 系统管理 - 通知公告 ====================
              GoRoute(
                path: 'notice',
                name: 'notice',
                builder: (context, state) => const NoticePage(),
              ),

              // ==================== 系统管理 - 岗位管理 ====================
              GoRoute(
                path: 'post',
                name: 'post',
                builder: (context, state) => const PostPage(),
              ),

              // ==================== 系统管理 - 租户管理 ====================
              GoRoute(
                path: 'tenant',
                name: 'tenant',
                builder: (context, state) => const TenantPage(),
              ),

              // ==================== 系统管理 - 租户套餐 ====================
              GoRoute(
                path: 'tenant-package',
                name: 'tenantPackage',
                builder: (context, state) => const TenantPackagePage(),
              ),

              // ==================== 系统管理 - 通知消息 ====================
              GoRoute(
                path: 'notify-message',
                name: 'notifyMessage',
                builder: (context, state) => const NotifyMessagePage(),
              ),

              // ==================== 系统管理 - 通知模板 ====================
              GoRoute(
                path: 'notify-template',
                name: 'notifyTemplate',
                builder: (context, state) => const NotifyTemplatePage(),
              ),

              // ==================== 邮件管理 - 邮件账号管理 ====================
              GoRoute(
                path: 'mail-account',
                name: 'mailAccount',
                builder: (context, state) => const MailAccountPage(),
              ),

              // ==================== 邮件管理 - 邮件模板管理 ====================
              GoRoute(
                path: 'mail-template',
                name: 'mailTemplate',
                builder: (context, state) => const MailTemplatePage(),
              ),

              // ==================== 邮件管理 - 邮件日志 ====================
              GoRoute(
                path: 'mail-log',
                name: 'mailLog',
                builder: (context, state) => const MailLogPage(),
              ),

              // ==================== 短信管理 - 短信渠道管理 ====================
              GoRoute(
                path: 'sms-channel',
                name: 'smsChannel',
                builder: (context, state) => const SmsChannelPage(),
              ),

              // ==================== 短信管理 - 短信日志 ====================
              GoRoute(
                path: 'sms-log',
                name: 'smsLog',
                builder: (context, state) => const SmsLogPage(),
              ),

              // ==================== 短信管理 - 短信模板管理 ====================
              GoRoute(
                path: 'sms-template',
                name: 'smsTemplate',
                builder: (context, state) => const SmsTemplatePage(),
              ),
            ],
          ),
        ],
      ),

      // ==================== BPM移动端流程表单（特殊路由，不需要Layout） ====================
      GoRoute(
        path: Routes.bpmMobileFormPreview,
        name: 'BpmMobileFormPreview',
        builder: (context, state) {
          // 可以根据需要传递参数
          return const Scaffold(
            body: Center(
              child: Text('BPM流程表单预览'),
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => ScaffoldErrorPage(error: state.error),
  );
});

// ==================== 路由守卫逻辑 ====================

/// 处理路由重定向逻辑
/// 参考 TypeScript 版本的 guard.ts 中的 setupAccessGuard 实现
String? _handleRedirect(
  BuildContext context,
  GoRouterState state,
  AccessState accessState,
) {
  final currentPath = state.matchedLocation;
  final currentName = state.name;

  // 1. 检查是否为核心路由（不需要权限验证）
  // 参考 TypeScript 版本的 coreRouteNames.includes(to.name as string)
  if (_isCoreRoute(currentPath, currentName)) {
    // 如果是登录页且已登录，重定向到首页或指定页面
    // 参考 TypeScript 版本的：
    // if (to.path === LOGIN_PATH && accessStore.accessToken) {
    //   return decodeURIComponent(
    //     (to.query?.redirect as string) ||
    //       userStore.userInfo?.homePath ||
    //       preferences.app.defaultHomePath,
    //   );
    // }
    if (currentPath == Routes.login && accessState.isAuthenticated) {
      final redirect = state.uri.queryParameters['redirect'];
      if (redirect != null && redirect.isNotEmpty) {
        return Uri.decodeComponent(redirect);
      }
      return Routes.dashboard;
    }
    return null;
  }

  // 2. 检查是否忽略权限访问
  // 参考 TypeScript 版本的：if (to.meta.ignoreAccess) { return true; }
  final meta = routeMetaMap[currentPath];
  if (meta?.ignoreAccess == true) {
    return null;
  }

  // 3. accessToken检查
  // 参考 TypeScript 版本的：if (!accessStore.accessToken)
  if (!accessState.isAuthenticated) {
    // 没有访问权限，跳转登录页面
    // 携带当前跳转的页面，登录后重新跳转该页面
    // 参考 TypeScript 版本的：
    // return {
    //   path: LOGIN_PATH,
    //   query: to.fullPath === preferences.app.defaultHomePath
    //     ? {}
    //     : { redirect: encodeURIComponent(to.fullPath) },
    //   replace: true,
    // };
    if (currentPath != Routes.login) {
      final queryString = currentPath == Routes.dashboard
          ? ''
          : '?redirect=${Uri.encodeComponent(currentPath)}';
      return '${Routes.login}$queryString';
    }
    return Routes.login;
  }

  // 4. 权限检查（如果路由需要特定权限）
  final requiredPermission = routePermissionMap[currentPath];
  if (requiredPermission != null &&
      !accessState.hasPermission(requiredPermission)) {
    // 无权限访问，重定向到403页面
    return Routes.forbidden;
  }

  // 5. 已认证且有权访问
  return null;
}

/// 检查是否为核心路由（不需要权限验证）
/// 参考 TypeScript 版本的 coreRouteNames
bool _isCoreRoute(String path, String? name) {
  // 检查路径
  if (coreRoutePaths.contains(path)) {
    return true;
  }
  // 检查是否以/auth开头
  if (path.startsWith(Routes.auth)) {
    return true;
  }
  // 检查名称
  if (name != null && coreRouteNames.contains(name)) {
    return true;
  }
  return false;
}

// ==================== 路由导航帮助类 ====================

/// 路由导航帮助类
/// 提供常用的路由导航方法
class RouterHelper {
  /// 导航到登录页并记录重定向路径
  static void goToLogin(BuildContext context, {String? redirect}) {
    final uri = Uri(
      path: Routes.login,
      queryParameters: redirect != null
          ? {'redirect': Uri.encodeComponent(redirect)}
          : null,
    );
    context.go(uri.toString());
  }

  /// 登录成功后导航到原始页面或首页
  /// 参考 TypeScript 版本的登录后重定向逻辑
  static void goToAfterLogin(BuildContext context, {String? redirect}) {
    if (redirect != null && redirect.isNotEmpty) {
      context.go(Uri.decodeComponent(redirect));
    } else {
      context.go(Routes.dashboard);
    }
  }

  /// 导航到403禁止访问页面
  static void goToForbidden(BuildContext context) {
    context.go(Routes.forbidden);
  }

  /// 导航到首页
  static void goToDashboard(BuildContext context) {
    context.go(Routes.dashboard);
  }

  /// 检查是否有权限访问指定路由
  static bool canAccess(String path, AccessState accessState) {
    final permission = routePermissionMap[path];
    if (permission == null) return true;
    return accessState.hasPermission(permission);
  }

  /// 获取路由元数据
  static RouteMeta? getRouteMeta(String path) {
    return routeMetaMap[path];
  }

  /// 获取路由所需权限
  static String? getRequiredPermission(String path) {
    return routePermissionMap[path];
  }

  /// 检查是否为核心路由
  static bool isCoreRoute(String path) {
    return coreRoutePaths.contains(path) || path.startsWith(Routes.auth);
  }
}

// ==================== 错误页面 ====================

/// 错误页面
class ScaffoldErrorPage extends StatelessWidget {
  final Exception? error;

  const ScaffoldErrorPage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('错误')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('页面未找到: ${error.toString()}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(Routes.dashboard),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 403禁止访问页面
class ForbiddenPage extends StatelessWidget {
  const ForbiddenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('无权访问')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              '403',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '抱歉，您没有权限访问此页面',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.go(Routes.dashboard),
                  child: const Text('返回首页'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => context.go(Routes.login),
                  child: const Text('重新登录'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}