import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/router/route_registry.dart';
import 'package:yudao_flutter_ui_admin/router/app_router.dart' show Routes;

// ==================== 导入所有页面 ====================
import 'package:yudao_flutter_ui_admin/pages/auth/login_page.dart';
import 'package:yudao_flutter_ui_admin/pages/dashboard/dashboard_page.dart';
import 'package:yudao_flutter_ui_admin/pages/layout/basic_layout.dart';
import 'package:yudao_flutter_ui_admin/pages/system/user/user_page.dart' show UserPage;
import 'package:yudao_flutter_ui_admin/pages/system/role/role_page.dart' show RolePage;
import 'package:yudao_flutter_ui_admin/pages/system/menu/menu_page.dart' show MenuPage;
import 'package:yudao_flutter_ui_admin/pages/system/dept/dept_page.dart' show DeptPage;
import 'package:yudao_flutter_ui_admin/pages/system/dict/dict_page.dart' show DictPage;
import 'package:yudao_flutter_ui_admin/pages/system/dict/dict_type_page.dart' show DictTypePage;
import 'package:yudao_flutter_ui_admin/pages/system/dict/dict_data_page.dart' show DictDataPage;
import 'package:yudao_flutter_ui_admin/pages/system/area/area_page.dart' show AreaPage;
import 'package:yudao_flutter_ui_admin/pages/system/loginlog/login_log_page.dart' show LoginLogPage;
import 'package:yudao_flutter_ui_admin/pages/system/oauth2/oauth2_client/oauth2_client_page.dart' show OAuth2ClientPage;
import 'package:yudao_flutter_ui_admin/pages/system/oauth2/oauth2_token/oauth2_token_page.dart' show OAuth2TokenPage;
import 'package:yudao_flutter_ui_admin/pages/system/operatelog/operate_log_page.dart' show OperateLogPage;
import 'package:yudao_flutter_ui_admin/pages/system/social_client/social_client_page.dart' show SocialClientPage;
import 'package:yudao_flutter_ui_admin/pages/system/social_user/social_user_page.dart' show SocialUserPage;
import 'package:yudao_flutter_ui_admin/pages/system/message/notice/notice_page.dart' show NoticePage;
import 'package:yudao_flutter_ui_admin/pages/system/post/post_page.dart' show PostPage;
import 'package:yudao_flutter_ui_admin/pages/system/tenant/tenant_page.dart' show TenantPage;
import 'package:yudao_flutter_ui_admin/pages/system/tenant_package/tenant_package_page.dart' show TenantPackagePage;
import 'package:yudao_flutter_ui_admin/pages/system/message/notify/notify_message/notify_message_page.dart' show NotifyMessagePage;
import 'package:yudao_flutter_ui_admin/pages/system/message/notify/notify_template/notify_template_page.dart' show NotifyTemplatePage;
import 'package:yudao_flutter_ui_admin/pages/system/message/mail/account/mail_account_page.dart' show MailAccountPage;
import 'package:yudao_flutter_ui_admin/pages/system/message/mail/log/mail_log_page.dart' show MailLogPage;
import 'package:yudao_flutter_ui_admin/pages/system/message/mail/template/mail_template_page.dart' show MailTemplatePage;
import 'package:yudao_flutter_ui_admin/pages/system/message/sms/channel/sms_channel_page.dart' show SmsChannelPage;
import 'package:yudao_flutter_ui_admin/pages/system/message/sms/log/sms_log_page.dart' show SmsLogPage;
import 'package:yudao_flutter_ui_admin/pages/system/message/sms/template/sms_template_page.dart' show SmsTemplatePage;

// Infra 页面导入
import 'package:yudao_flutter_ui_admin/pages/infra/log/api_access_log/api_access_log_page.dart' show ApiAccessLogPage;
import 'package:yudao_flutter_ui_admin/pages/infra/log/api_error_log/api_error_log_page.dart' show ApiErrorLogPage;
import 'package:yudao_flutter_ui_admin/pages/infra/config/config_page.dart' show ConfigPage;
import 'package:yudao_flutter_ui_admin/pages/infra/data_source_config/data_source_config_page.dart' show DataSourceConfigPage;
import 'package:yudao_flutter_ui_admin/pages/infra/file/file_page.dart' show FilePage;
import 'package:yudao_flutter_ui_admin/pages/infra/file_config/file_config_page.dart' show FileConfigPage;
import 'package:yudao_flutter_ui_admin/pages/infra/job/job_page.dart' show JobPage;
import 'package:yudao_flutter_ui_admin/pages/infra/job/job_log_page.dart' show JobLogPage;
import 'package:yudao_flutter_ui_admin/pages/infra/codegen/codegen_page.dart' show CodegenPage;
import 'package:yudao_flutter_ui_admin/pages/infra/monitors/redis/redis_page.dart' show RedisPage;
import 'package:yudao_flutter_ui_admin/pages/infra/monitors/server/server_page.dart' show ServerPage;
import 'package:yudao_flutter_ui_admin/pages/infra/swagger/swagger_page.dart' show SwaggerPage;
import 'package:yudao_flutter_ui_admin/pages/infra/websocket/websocket_page.dart' show WebSocketPage;
import 'package:yudao_flutter_ui_admin/pages/infra/monitors/druid/druid_page.dart' show DruidPage;
import 'package:yudao_flutter_ui_admin/pages/infra/monitors/skywalking/skywalking_page.dart' show SkywalkingPage;
import 'package:yudao_flutter_ui_admin/pages/infra/build/build_page.dart' show BuildPage;

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

    // ==================== 基础设施管理 ====================
    PageRouteMeta(
      path: Routes.apiAccessLog,
      name: 'apiAccessLog',
      title: 'API访问日志',
      icon: 'ant-design:audit-outlined',
      permission: 'infra:api-access-log:list',
      builder: (context) => const ApiAccessLogPage(),
    ),
    PageRouteMeta(
      path: Routes.apiErrorLog,
      name: 'apiErrorLog',
      title: 'API错误日志',
      icon: 'ant-design:warning-outlined',
      permission: 'infra:api-error-log:list',
      builder: (context) => const ApiErrorLogPage(),
    ),
    PageRouteMeta(
      path: Routes.config,
      name: 'infraConfig',
      title: '参数配置',
      icon: 'ant-design:setting-outlined',
      permission: 'infra:config:list',
      builder: (context) => const ConfigPage(),
    ),
    PageRouteMeta(
      path: Routes.dataSourceConfig,
      name: 'dataSourceConfig',
      title: '数据源配置',
      icon: 'ant-design:database-outlined',
      permission: 'infra:data-source-config:list',
      builder: (context) => const DataSourceConfigPage(),
    ),
    PageRouteMeta(
      path: Routes.file,
      name: 'file',
      title: '文件管理',
      icon: 'ant-design:folder-outlined',
      permission: 'infra:file:list',
      builder: (context) => const FilePage(),
    ),
    PageRouteMeta(
      path: Routes.fileConfig,
      name: 'fileConfig',
      title: '文件配置',
      icon: 'ant-design:folder-settings-outlined',
      permission: 'infra:file-config:list',
      builder: (context) => const FileConfigPage(),
    ),
    PageRouteMeta(
      path: Routes.job,
      name: 'job',
      title: '定时任务',
      icon: 'ant-design:schedule-outlined',
      permission: 'infra:job:list',
      builder: (context) => const JobPage(),
    ),
    PageRouteMeta(
      path: Routes.jobLog,
      name: 'jobLog',
      title: '任务日志',
      icon: 'ant-design:file-sync-outlined',
      permission: 'infra:job-log:list',
      builder: (context) => const JobLogPage(),
    ),
    PageRouteMeta(
      path: Routes.codegen,
      name: 'codegen',
      title: '代码生成',
      icon: 'ant-design:code-outlined',
      permission: 'infra:codegen:list',
      builder: (context) => const CodegenPage(),
    ),
    PageRouteMeta(
      path: Routes.redis,
      name: 'redis',
      title: 'Redis监控',
      icon: 'ant-design:database-filled',
      permission: 'infra:redis:list',
      builder: (context) => const RedisPage(),
    ),
    PageRouteMeta(
      path: Routes.server,
      name: 'server',
      title: '服务器监控',
      icon: 'ant-design:desktop-outlined',
      permission: 'infra:server:list',
      builder: (context) => const ServerPage(),
    ),
    PageRouteMeta(
      path: Routes.swagger,
      name: 'swagger',
      title: 'API文档',
      icon: 'ant-design:book-outlined',
      permission: 'infra:swagger:list',
      builder: (context) => const SwaggerPage(),
    ),
    PageRouteMeta(
      path: Routes.websocket,
      name: 'websocket',
      title: 'WebSocket',
      icon: 'ant-design:api-outlined',
      permission: 'infra:websocket:list',
      builder: (context) => const WebSocketPage(),
    ),
    PageRouteMeta(
      path: Routes.druid,
      name: 'druid',
      title: 'Druid监控',
      icon: 'ant-design:monitor-outlined',
      permission: 'infra:druid:list',
      builder: (context) => const DruidPage(),
    ),
    PageRouteMeta(
      path: Routes.skywalking,
      name: 'skywalking',
      title: 'Skywalking',
      icon: 'ant-design:radar-chart-outlined',
      permission: 'infra:skywalking:list',
      builder: (context) => const SkywalkingPage(),
    ),
    PageRouteMeta(
      path: Routes.build,
      name: 'build',
      title: '表单构建',
      icon: 'ant-design:build-outlined',
      permission: 'infra:build:list',
      builder: (context) => const BuildPage(),
    ),
  ]);
}

/// 获取布局组件
///
/// 用于动态路由中的 ShellRoute 构建。
Widget buildBasicLayout(Widget child) {
  return BasicLayout(child: child);
}