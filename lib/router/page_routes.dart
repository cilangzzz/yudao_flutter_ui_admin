import 'package:flutter/material.dart';
import 'route_registry.dart';
import 'app_router.dart' show Routes;

// ==================== 导入所有页面 ====================
import '../pages/auth/login_page.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../pages/layout/basic_layout.dart';
import '../pages/system/user/user_page.dart' show UserPage;
import '../pages/system/role/role_page.dart' show RolePage;
import '../pages/system/menu/menu_page.dart' show MenuPage;
import '../pages/system/dept/dept_page.dart' show DeptPage;
import '../pages/system/dict/dict_page.dart' show DictPage;
import '../pages/system/dict/dict_type_page.dart' show DictTypePage;
import '../pages/system/dict/dict_data_page.dart' show DictDataPage;
import '../pages/system/area/area_page.dart' show AreaPage;
import '../pages/system/loginlog/login_log_page.dart' show LoginLogPage;
import '../pages/system/oauth2_client/oauth2_client_page.dart' show OAuth2ClientPage;
import '../pages/system/oauth2_token/oauth2_token_page.dart' show OAuth2TokenPage;
import '../pages/system/operatelog/operate_log_page.dart' show OperateLogPage;
import '../pages/system/social_client/social_client_page.dart' show SocialClientPage;
import '../pages/system/social_user/social_user_page.dart' show SocialUserPage;
import '../pages/system/notice/notice_page.dart' show NoticePage;
import '../pages/system/post/post_page.dart' show PostPage;
import '../pages/system/tenant/tenant_page.dart' show TenantPage;
import '../pages/system/tenant_package/tenant_package_page.dart' show TenantPackagePage;
import '../pages/system/notify_message/notify_message_page.dart' show NotifyMessagePage;
import '../pages/system/notify_template/notify_template_page.dart' show NotifyTemplatePage;
import '../pages/system/mail/account/mail_account_page.dart' show MailAccountPage;
import '../pages/system/mail/log/mail_log_page.dart' show MailLogPage;
import '../pages/system/mail/template/mail_template_page.dart' show MailTemplatePage;
import '../pages/system/sms/channel/sms_channel_page.dart' show SmsChannelPage;
import '../pages/system/sms/log/sms_log_page.dart' show SmsLogPage;
import '../pages/system/sms/template/sms_template_page.dart' show SmsTemplatePage;

/// 注册所有页面路由
///
/// 在应用启动时调用此函数，将所有页面路由注册到 RouteRegistry。
void registerAllPageRoutes() {
  RouteRegistry.registerAll([
    // ==================== 核心路由 ====================
    PageRouteMeta(
      path: Routes.login,
      name: Routes.loginName,
      title: '登录',
      ignoreAccess: true,
      hideInMenu: true,
      builder: (context) => const LoginPage(),
    ),
    PageRouteMeta(
      path: Routes.dashboard,
      name: Routes.dashboardName,
      title: '仪表板',
      icon: 'lucide:layout-dashboard',
      builder: (context) => const DashboardPage(),
    ),

    // ==================== 系统管理 ====================
    PageRouteMeta(
      path: Routes.user,
      name: 'user',
      title: '用户管理',
      icon: 'ant-design:user-outlined',
      permission: 'system:user:list',
      builder: (context) => const UserPage(),
    ),
    PageRouteMeta(
      path: Routes.role,
      name: 'role',
      title: '角色管理',
      icon: 'ant-design:team-outlined',
      permission: 'system:role:list',
      builder: (context) => const RolePage(),
    ),
    PageRouteMeta(
      path: Routes.menu,
      name: 'menu',
      title: '菜单管理',
      icon: 'ant-design:menu-outlined',
      permission: 'system:menu:list',
      builder: (context) => const MenuPage(),
    ),
    PageRouteMeta(
      path: Routes.dept,
      name: 'dept',
      title: '部门管理',
      icon: 'ant-design:apartment-outlined',
      permission: 'system:dept:list',
      builder: (context) => const DeptPage(),
    ),
    PageRouteMeta(
      path: Routes.dict,
      name: 'dict',
      title: '字典管理',
      icon: 'ant-design:book-outlined',
      permission: 'system:dict:list',
      builder: (context) => const DictPage(),
    ),
    PageRouteMeta(
      path: Routes.dictType,
      name: 'dictType',
      title: '字典类型',
      icon: 'ant-design:book-outlined',
      permission: 'system:dict-type:list',
      builder: (context) => const DictTypePage(),
    ),
    PageRouteMeta(
      path: Routes.dictData,
      name: 'dictData',
      title: '字典数据',
      icon: 'ant-design:database-outlined',
      permission: 'system:dict-data:list',
      hideInMenu: true,
      builder: (context) => const DictDataPage(),
    ),
    PageRouteMeta(
      path: Routes.area,
      name: 'area',
      title: '地区管理',
      icon: 'ant-design:global-outlined',
      permission: 'system:area:list',
      builder: (context) => const AreaPage(),
    ),
    PageRouteMeta(
      path: Routes.loginLog,
      name: 'loginLog',
      title: '登录日志',
      icon: 'ant-design:login-outlined',
      permission: 'system:login-log:list',
      builder: (context) => const LoginLogPage(),
    ),
    PageRouteMeta(
      path: Routes.oauth2Client,
      name: 'oauth2Client',
      title: 'OAuth2客户端',
      icon: 'ant-design:api-outlined',
      permission: 'system:oauth2-client:list',
      builder: (context) => const OAuth2ClientPage(),
    ),
    PageRouteMeta(
      path: Routes.oauth2Token,
      name: 'oauth2Token',
      title: 'OAuth2令牌',
      icon: 'ant-design:key-outlined',
      permission: 'system:oauth2-token:list',
      builder: (context) => const OAuth2TokenPage(),
    ),
    PageRouteMeta(
      path: Routes.operateLog,
      name: 'operateLog',
      title: '操作日志',
      icon: 'ant-design:file-text-outlined',
      permission: 'system:operate-log:list',
      builder: (context) => const OperateLogPage(),
    ),
    PageRouteMeta(
      path: Routes.socialClient,
      name: 'socialClient',
      title: '社交客户端',
      icon: 'ant-design:link-outlined',
      permission: 'system:social-client:list',
      builder: (context) => const SocialClientPage(),
    ),
    PageRouteMeta(
      path: Routes.socialUser,
      name: 'socialUser',
      title: '社交用户',
      icon: 'ant-design:usergroup-outlined',
      permission: 'system:social-user:list',
      builder: (context) => const SocialUserPage(),
    ),
    PageRouteMeta(
      path: Routes.notice,
      name: 'notice',
      title: '通知公告',
      icon: 'ant-design:notification-outlined',
      permission: 'system:notice:list',
      builder: (context) => const NoticePage(),
    ),
    PageRouteMeta(
      path: Routes.post,
      name: 'post',
      title: '岗位管理',
      icon: 'ant-design:solution-outlined',
      permission: 'system:post:list',
      builder: (context) => const PostPage(),
    ),

    // ==================== 租户管理 ====================
    PageRouteMeta(
      path: Routes.tenant,
      name: 'tenant',
      title: '租户管理',
      icon: 'ant-design:home-outlined',
      hideInMenu: true,
      permission: 'system:tenant:list',
      builder: (context) => const TenantPage(),
    ),
    PageRouteMeta(
      path: Routes.tenantList,
      name: 'tenantList',
      title: '租户列表',
      icon: 'ant-design:home-outlined',
      permission: 'system:tenant:list',
      builder: (context) => const TenantPage(),
    ),
    PageRouteMeta(
      path: Routes.tenantPackage,
      name: 'tenantPackage',
      title: '租户套餐',
      icon: 'ant-design:gift-outlined',
      permission: 'system:tenant-package:list',
      builder: (context) => const TenantPackagePage(),
    ),

    // ==================== 通知管理 ====================
    PageRouteMeta(
      path: Routes.notifyMessage,
      name: 'notifyMessage',
      title: '我的站内信',
      icon: 'ant-design:message-filled',
      hideInMenu: true,
      permission: 'system:notify-message:list',
      builder: (context) => const NotifyMessagePage(),
    ),
    PageRouteMeta(
      path: Routes.notifyTemplate,
      name: 'notifyTemplate',
      title: '通知模板',
      icon: 'ant-design:notification-outlined',
      permission: 'system:notify-template:list',
      builder: (context) => const NotifyTemplatePage(),
    ),

    // ==================== 邮件管理 ====================
    PageRouteMeta(
      path: Routes.mailAccount,
      name: 'mailAccount',
      title: '邮箱账号',
      icon: 'ant-design:mail-outlined',
      permission: 'system:mail-account:list',
      builder: (context) => const MailAccountPage(),
    ),
    PageRouteMeta(
      path: Routes.mailTemplate,
      name: 'mailTemplate',
      title: '邮件模板',
      icon: 'ant-design:file-markdown-outlined',
      permission: 'system:mail-template:list',
      builder: (context) => const MailTemplatePage(),
    ),
    PageRouteMeta(
      path: Routes.mailLog,
      name: 'mailLog',
      title: '邮件日志',
      icon: 'ant-design:history-outlined',
      permission: 'system:mail-log:list',
      builder: (context) => const MailLogPage(),
    ),

    // ==================== 短信管理 ====================
    PageRouteMeta(
      path: Routes.smsChannel,
      name: 'smsChannel',
      title: '短信渠道',
      icon: 'ant-design:message-outlined',
      permission: 'system:sms-channel:list',
      builder: (context) => const SmsChannelPage(),
    ),
    PageRouteMeta(
      path: Routes.smsLog,
      name: 'smsLog',
      title: '短信日志',
      icon: 'ant-design:file-search-outlined',
      permission: 'system:sms-log:list',
      builder: (context) => const SmsLogPage(),
    ),
    PageRouteMeta(
      path: Routes.smsTemplate,
      name: 'smsTemplate',
      title: '短信模板',
      icon: 'ant-design:file-text-outlined',
      permission: 'system:sms-template:list',
      builder: (context) => const SmsTemplatePage(),
    ),
  ]);
}

/// 获取布局组件
///
/// 用于动态路由中的 ShellRoute 构建。
Widget buildBasicLayout(Widget child) {
  return BasicLayout(child: child);
}