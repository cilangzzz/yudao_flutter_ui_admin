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
import '../pages/system/oauth2/oauth2_client/oauth2_client_page.dart';
import '../pages/system/oauth2/oauth2_token/oauth2_token_page.dart';
import '../pages/system/operatelog/operate_log_page.dart';
import '../pages/system/social_client/social_client_page.dart';
import '../pages/system/social_user/social_user_page.dart';
import '../pages/system/message/notice/notice_page.dart';
import '../pages/system/post/post_page.dart';
import '../pages/system/tenant/tenant_page.dart';
import '../pages/system/tenant_package/tenant_package_page.dart';
import '../pages/system/message/notify/notify_message/notify_message_page.dart';
import '../pages/system/message/notify/notify_template/notify_template_page.dart';
import '../pages/system/message/mail/account/mail_account_page.dart';
import '../pages/system/message/mail/log/mail_log_page.dart';
import '../pages/system/message/mail/template/mail_template_page.dart';
import '../pages/system/message/sms/channel/sms_channel_page.dart';
import '../pages/system/message/sms/log/sms_log_page.dart';
import '../pages/system/message/sms/template/sms_template_page.dart';
import 'route_registry.dart';
import 'page_routes.dart';

// ==================== 路由初始化 ====================

/// 初始化路由系统
///
/// 在应用启动时调用，注册所有页面路由到 RouteRegistry。
void initializeRouter() {
  registerAllPageRoutes();
}

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

  // ==================== 系统管理 - 二级路由 ====================
  static const String system = '/system';
  static const String user = '/system/user';
  static const String role = '/system/role';
  static const String menu = '/system/menu';
  static const String dept = '/system/dept';
  static const String dict = '/system/dict';
  static const String dictType = '/system/dict-type';
  static const String dictData = '/system/dict-data';
  static const String area = '/system/area';
  static const String post = '/system/post';

  // ==================== 租户管理（三级） ====================
  static const String tenant = '/system/tenant';
  static const String tenantList = '/system/tenant/list';
  static const String tenantPackage = '/system/tenant/package';

  // ==================== 社交管理（三级） ====================
  static const String social = '/system/social';
  static const String socialClient = '/system/social/client';
  static const String socialUser = '/system/social/user';

  // ==================== 日志管理（三级） ====================
  static const String log = '/system/log';
  static const String loginLog = '/system/log/login-log';
  static const String operateLog = '/system/log/operate-log';

  // ==================== OAuth2管理（三级/四级） ====================
  static const String oauth2 = '/system/oauth2';
  static const String oauth2Token = '/system/oauth2/token';
  static const String oauth2Client = '/system/oauth2/oauth2/client';
  static const String oauth2Application = '/system/oauth2/oauth2/application';

  // ==================== 消息管理（三级/四级） ====================
  static const String messages = '/system/messages';
  static const String notice = '/system/messages/notice';

  // 通知管理（四级）
  static const String notify = '/system/messages/notify';
  static const String notifyTemplate = '/system/messages/notify/notify-template';
  static const String notifyMessage = '/system/messages/notify/notify-message';

  // 邮件管理（四级）
  static const String mail = '/system/messages/mail';
  static const String mailAccount = '/system/messages/mail/mail-account';
  static const String mailTemplate = '/system/messages/mail/mail-template';
  static const String mailLog = '/system/messages/mail/mail-log';

  // 短信管理（四级）
  static const String sms = '/system/messages/sms';
  static const String smsChannel = '/system/messages/sms/sms-channel';
  static const String smsTemplate = '/system/messages/sms/sms-template';
  static const String smsLog = '/system/messages/sms/sms-log';

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
  // 核心路由
  Routes.login: const RouteMeta(title: '登录', hideInMenu: true, ignoreAccess: true),
  Routes.forbidden: const RouteMeta(title: '无权访问', hideInMenu: true, ignoreAccess: true),
  Routes.notFound: const RouteMeta(title: '页面未找到', hideInMenu: true, ignoreAccess: true),
  Routes.dashboard: const RouteMeta(
    title: '仪表板',
    icon: 'lucide:layout-dashboard',
    order: -1,
  ),
  Routes.workspace: const RouteMeta(title: '工作台', icon: 'carbon:workspace'),
  Routes.analytics: const RouteMeta(title: '分析页', icon: 'lucide:area-chart', affixTab: true),
  Routes.profile: const RouteMeta(title: '个人中心', icon: 'ant-design:profile-outlined', hideInMenu: true),

  // 系统管理 - 二级路由
  Routes.user: const RouteMeta(title: '用户管理', icon: 'ant-design:user-outlined'),
  Routes.role: const RouteMeta(title: '角色管理', icon: 'ant-design:team-outlined'),
  Routes.menu: const RouteMeta(title: '菜单管理', icon: 'ant-design:menu-outlined'),
  Routes.dept: const RouteMeta(title: '部门管理', icon: 'ant-design:apartment-outlined'),
  Routes.dict: const RouteMeta(title: '字典管理', icon: 'ant-design:book-outlined'),
  Routes.dictType: const RouteMeta(title: '字典类型', icon: 'ant-design:book-outlined'),
  Routes.dictData: const RouteMeta(title: '字典数据', icon: 'ant-design:database-outlined'),
  Routes.area: const RouteMeta(title: '地区管理', icon: 'ant-design:global-outlined'),
  Routes.post: const RouteMeta(title: '岗位管理', icon: 'ant-design:solution-outlined'),

  // 租户管理（三级）
  Routes.tenant: const RouteMeta(title: '租户管理', icon: 'ant-design:home-outlined', hideInMenu: true),
  Routes.tenantList: const RouteMeta(title: '租户列表', icon: 'ant-design:home-outlined'),
  Routes.tenantPackage: const RouteMeta(title: '租户套餐', icon: 'ant-design:gift-outlined'),

  // 社交管理（三级）
  Routes.social: const RouteMeta(title: '社交管理', icon: 'ant-design:link-outlined', hideInMenu: true),
  Routes.socialClient: const RouteMeta(title: '社交客户端', icon: 'ant-design:link-outlined'),
  Routes.socialUser: const RouteMeta(title: '社交用户', icon: 'ant-design:usergroup-outlined'),

  // 日志管理（三级）
  Routes.log: const RouteMeta(title: '日志管理', icon: 'ant-design:file-text-outlined', hideInMenu: true),
  Routes.loginLog: const RouteMeta(title: '登录日志', icon: 'ant-design:login-outlined'),
  Routes.operateLog: const RouteMeta(title: '操作日志', icon: 'ant-design:file-text-outlined'),

  // OAuth2管理（三级/四级）
  Routes.oauth2: const RouteMeta(title: 'OAuth2管理', icon: 'ant-design:api-outlined', hideInMenu: true),
  Routes.oauth2Application: const RouteMeta(title: 'OAuth2应用', icon: 'ant-design:api-outlined'),
  Routes.oauth2Token: const RouteMeta(title: 'OAuth2令牌', icon: 'ant-design:key-outlined'),

  // 消息管理
  Routes.messages: const RouteMeta(title: '消息管理', icon: 'ant-design:message-outlined', hideInMenu: true),
  Routes.notice: const RouteMeta(title: '通知公告', icon: 'ant-design:notification-outlined'),

  // 通知管理（四级）
  Routes.notify: const RouteMeta(title: '站内信', icon: 'ant-design:message-outlined', hideInMenu: true),
  Routes.notifyTemplate: const RouteMeta(title: '通知模板', icon: 'ant-design:notification-outlined'),
  Routes.notifyMessage: const RouteMeta(title: '我的站内信', icon: 'ant-design:message-filled', hideInMenu: true),

  // 邮件管理（四级）
  Routes.mail: const RouteMeta(title: '邮件管理', icon: 'ant-design:mail-outlined', hideInMenu: true),
  Routes.mailAccount: const RouteMeta(title: '邮箱账号', icon: 'ant-design:mail-outlined'),
  Routes.mailTemplate: const RouteMeta(title: '邮件模板', icon: 'ant-design:file-markdown-outlined'),
  Routes.mailLog: const RouteMeta(title: '邮件日志', icon: 'ant-design:history-outlined'),

  // 短信管理（四级）
  Routes.sms: const RouteMeta(title: '短信管理', icon: 'ant-design:message-outlined', hideInMenu: true),
  Routes.smsChannel: const RouteMeta(title: '短信渠道', icon: 'ant-design:message-outlined'),
  Routes.smsTemplate: const RouteMeta(title: '短信模板', icon: 'ant-design:file-text-outlined'),
  Routes.smsLog: const RouteMeta(title: '短信日志', icon: 'ant-design:file-search-outlined'),

  // BPM
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
final Map<String, String> routePermissionMap = {
  // 系统管理 - 二级路由
  Routes.user: 'system:user:list',
  Routes.role: 'system:role:list',
  Routes.menu: 'system:menu:list',
  Routes.dept: 'system:dept:list',
  Routes.dict: 'system:dict:list',
  Routes.dictType: 'system:dict-type:list',
  Routes.dictData: 'system:dict-data:list',
  Routes.area: 'system:area:list',
  Routes.post: 'system:post:list',

  // 租户管理
  Routes.tenantList: 'system:tenant:list',
  Routes.tenantPackage: 'system:tenant-package:list',

  // 社交管理
  Routes.socialClient: 'system:social-client:list',
  Routes.socialUser: 'system:social-user:list',

  // 日志管理
  Routes.loginLog: 'system:login-log:list',
  Routes.operateLog: 'system:operate-log:list',

  // OAuth2管理
  Routes.oauth2Application: 'system:oauth2-client:list',
  Routes.oauth2Token: 'system:oauth2-token:list',

  // 消息管理
  Routes.notice: 'system:notice:list',
  Routes.notifyTemplate: 'system:notify-template:list',
  Routes.notifyMessage: 'system:notify-message:list',

  // 邮件管理
  Routes.mailAccount: 'system:mail-account:list',
  Routes.mailTemplate: 'system:mail-template:list',
  Routes.mailLog: 'system:mail-log:list',

  // 短信管理
  Routes.smsChannel: 'system:sms-channel:list',
  Routes.smsTemplate: 'system:sms-template:list',
  Routes.smsLog: 'system:sms-log:list',
};

// ==================== GoRouter 刷新流 ====================

/// 用于 go_router 的刷新流
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
      // ==================== 登录页 ====================
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
      ShellRoute(
        builder: (context, state, child) => BasicLayout(child: child),
        routes: [
          // ==================== 仪表板 ====================
          GoRoute(
            path: Routes.dashboard,
            name: Routes.dashboardName,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: Routes.workspace,
            name: Routes.workspaceName,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: Routes.analytics,
            name: Routes.analyticsName,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: Routes.profile,
            name: Routes.profileName,
            builder: (context, state) => const DashboardPage(),
          ),

          // ==================== 系统管理（二级） ====================
          GoRoute(
            path: Routes.system,
            name: 'system',
            redirect: (context, state) {
              if (state.uri.path == Routes.system) {
                return Routes.user;
              }
              return null;
            },
            routes: [
              // ==================== 二级路由页面 ====================
              GoRoute(path: 'user', name: 'user', builder: (context, state) => const UserPage()),
              GoRoute(path: 'role', name: 'role', builder: (context, state) => const RolePage()),
              GoRoute(path: 'menu', name: 'menu', builder: (context, state) => const MenuPage()),
              GoRoute(path: 'dept', name: 'dept', builder: (context, state) => const DeptPage()),
              GoRoute(path: 'dict', name: 'dict', builder: (context, state) => const DictPage()),
              GoRoute(path: 'dict-type', name: 'dictType', builder: (context, state) => const DictTypePage()),
              GoRoute(
                path: 'dict-data',
                name: 'dictData',
                builder: (context, state) {
                  final dictType = state.uri.queryParameters['dictType'];
                  return DictDataPage(dictType: dictType);
                },
              ),
              GoRoute(path: 'area', name: 'area', builder: (context, state) => const AreaPage()),
              GoRoute(path: 'post', name: 'post', builder: (context, state) => const PostPage()),

              // ==================== 租户管理（三级） ====================
              GoRoute(
                path: 'tenant',
                name: 'tenant',
                redirect: (context, state) {
                  if (state.uri.path == Routes.tenant) {
                    return Routes.tenantList;
                  }
                  return null;
                },
                routes: [
                  GoRoute(path: 'list', name: 'tenantList', builder: (context, state) => const TenantPage()),
                  GoRoute(path: 'package', name: 'tenantPackage', builder: (context, state) => const TenantPackagePage()),
                ],
              ),

              // ==================== 社交管理（三级） ====================
              GoRoute(
                path: 'social',
                name: 'social',
                redirect: (context, state) {
                  if (state.uri.path == Routes.social) {
                    return Routes.socialClient;
                  }
                  return null;
                },
                routes: [
                  GoRoute(path: 'client', name: 'socialClient', builder: (context, state) => const SocialClientPage()),
                  GoRoute(path: 'user', name: 'socialUser', builder: (context, state) => const SocialUserPage()),
                ],
              ),

              // ==================== 日志管理（三级） ====================
              GoRoute(
                path: 'log',
                name: 'log',
                redirect: (context, state) {
                  if (state.uri.path == Routes.log) {
                    return Routes.loginLog;
                  }
                  return null;
                },
                routes: [
                  GoRoute(path: 'login-log', name: 'loginLog', builder: (context, state) => const LoginLogPage()),
                  GoRoute(path: 'operate-log', name: 'operateLog', builder: (context, state) => const OperateLogPage()),
                ],
              ),

              // ==================== OAuth2管理（三级/四级） ====================
              GoRoute(
                path: 'oauth2',
                name: 'oauth2',
                redirect: (context, state) {
                  if (state.uri.path == Routes.oauth2) {
                    return Routes.oauth2Application;
                  }
                  return null;
                },
                routes: [
                  // OAuth2令牌（三级）
                  GoRoute(path: 'token', name: 'oauth2Token', builder: (context, state) => const OAuth2TokenPage()),
                  // OAuth2应用（四级）
                  GoRoute(
                    path: 'oauth2',
                    name: 'oauth2Sub',
                    redirect: (context, state) {
                      if (state.uri.path == '/system/oauth2/oauth2') {
                        return Routes.oauth2Application;
                      }
                      return null;
                    },
                    routes: [
                      GoRoute(path: 'application', name: 'oauth2Application', builder: (context, state) => const OAuth2ClientPage()),
                    ],
                  ),
                ],
              ),

              // ==================== 消息管理（三级/四级） ====================
              GoRoute(
                path: 'messages',
                name: 'messages',
                redirect: (context, state) {
                  if (state.uri.path == Routes.messages) {
                    return Routes.notice;
                  }
                  return null;
                },
                routes: [
                  // 通知公告（三级）
                  GoRoute(path: 'notice', name: 'notice', builder: (context, state) => const NoticePage()),

                  // 站内信管理（四级）
                  GoRoute(
                    path: 'notify',
                    name: 'notify',
                    redirect: (context, state) {
                      if (state.uri.path == Routes.notify) {
                        return Routes.notifyTemplate;
                      }
                      return null;
                    },
                    routes: [
                      GoRoute(path: 'notify-template', name: 'notifyTemplate', builder: (context, state) => const NotifyTemplatePage()),
                      GoRoute(path: 'notify-message', name: 'notifyMessage', builder: (context, state) => const NotifyMessagePage()),
                    ],
                  ),

                  // 邮件管理（四级）
                  GoRoute(
                    path: 'mail',
                    name: 'mail',
                    redirect: (context, state) {
                      if (state.uri.path == Routes.mail) {
                        return Routes.mailAccount;
                      }
                      return null;
                    },
                    routes: [
                      GoRoute(path: 'mail-account', name: 'mailAccount', builder: (context, state) => const MailAccountPage()),
                      GoRoute(path: 'mail-template', name: 'mailTemplate', builder: (context, state) => const MailTemplatePage()),
                      GoRoute(path: 'mail-log', name: 'mailLog', builder: (context, state) => const MailLogPage()),
                    ],
                  ),

                  // 短信管理（四级）
                  GoRoute(
                    path: 'sms',
                    name: 'sms',
                    redirect: (context, state) {
                      if (state.uri.path == Routes.sms) {
                        return Routes.smsChannel;
                      }
                      return null;
                    },
                    routes: [
                      GoRoute(path: 'sms-channel', name: 'smsChannel', builder: (context, state) => const SmsChannelPage()),
                      GoRoute(path: 'sms-template', name: 'smsTemplate', builder: (context, state) => const SmsTemplatePage()),
                      GoRoute(path: 'sms-log', name: 'smsLog', builder: (context, state) => const SmsLogPage()),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ==================== BPM移动端流程表单 ====================
      GoRoute(
        path: Routes.bpmMobileFormPreview,
        name: 'BpmMobileFormPreview',
        builder: (context, state) {
          return const Scaffold(
            body: Center(child: Text('BPM流程表单预览')),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => ScaffoldErrorPage(error: state.error),
  );
});

// ==================== 路由守卫逻辑 ====================

String? _handleRedirect(BuildContext context, GoRouterState state, AccessState accessState) {
  final currentPath = state.matchedLocation;
  final currentName = state.name;

  // 1. 检查是否为核心路由
  if (_isCoreRoute(currentPath, currentName)) {
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
  final meta = routeMetaMap[currentPath];
  if (meta?.ignoreAccess == true) {
    return null;
  }

  // 3. accessToken检查
  if (!accessState.isAuthenticated) {
    if (currentPath != Routes.login) {
      final queryString = currentPath == Routes.dashboard
          ? ''
          : '?redirect=${Uri.encodeComponent(currentPath)}';
      return '${Routes.login}$queryString';
    }
    return Routes.login;
  }

  // 4. 已认证且有权访问
  return null;
}

/// 检查是否为核心路由
bool _isCoreRoute(String path, String? name) {
  if (coreRoutePaths.contains(path)) return true;
  if (path.startsWith(Routes.auth)) return true;
  if (name != null && coreRouteNames.contains(name)) return true;
  return false;
}

// ==================== 路由导航帮助类 ====================

/// 路由导航帮助类
class RouterHelper {
  static void goToLogin(BuildContext context, {String? redirect}) {
    final uri = Uri(
      path: Routes.login,
      queryParameters: redirect != null ? {'redirect': Uri.encodeComponent(redirect)} : null,
    );
    context.go(uri.toString());
  }

  static void goToAfterLogin(BuildContext context, {String? redirect}) {
    if (redirect != null && redirect.isNotEmpty) {
      context.go(Uri.decodeComponent(redirect));
    } else {
      context.go(Routes.dashboard);
    }
  }

  static void goToForbidden(BuildContext context) => context.go(Routes.forbidden);
  static void goToDashboard(BuildContext context) => context.go(Routes.dashboard);

  static bool canAccess(String path, AccessState accessState) {
    final permission = routePermissionMap[path];
    if (permission == null) return true;
    return accessState.hasPermission(permission);
  }

  static RouteMeta? getRouteMeta(String path) => routeMetaMap[path];
  static String? getRequiredPermission(String path) => routePermissionMap[path];
  static bool isCoreRoute(String path) => coreRoutePaths.contains(path) || path.startsWith(Routes.auth);
}

// ==================== 错误页面 ====================

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
            const Text('403', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 16),
            const Text('抱歉，您没有权限访问此页面', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () => context.go(Routes.dashboard), child: const Text('返回首页')),
                const SizedBox(width: 16),
                OutlinedButton(onPressed: () => context.go(Routes.login), child: const Text('重新登录')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}