// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class SZh extends S {
  SZh([String locale = 'zh']) : super(locale);

  @override
  String get confirm_delete => '确认删除';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get confirm => '确定';

  @override
  String get search => '搜索';

  @override
  String get status => '状态';

  @override
  String get status_enabled => '开启';

  @override
  String get status_disabled => '禁用';

  @override
  String get status_all => '全部';

  @override
  String get create_time => '创建时间';

  @override
  String get operation => '操作';

  @override
  String get delete_success => '删除成功';

  @override
  String delete_failed(String msg) {
    return '删除失败: $msg';
  }

  @override
  String get update_success => '更新成功';

  @override
  String get create_success => '创建成功';

  @override
  String operation_failed(String msg) {
    return '操作失败: $msg';
  }

  @override
  String get please_fill_required => '请填写必填项';

  @override
  String get remark => '备注';

  @override
  String get tenant_name => '租户名称';

  @override
  String get tenant_package => '租户套餐';

  @override
  String get contact_name => '联系人';

  @override
  String get contact_mobile => '联系电话';

  @override
  String get account_limit => '账号限额';

  @override
  String get expire_time => '过期时间';

  @override
  String get tenant_list => '租户列表';

  @override
  String get add_tenant => '新增租户';

  @override
  String get edit_tenant => '编辑租户';

  @override
  String get search_tenant_name => '搜索租户名称';

  @override
  String get tenant_name_required => '租户名称 *';

  @override
  String get tenant_package_required => '租户套餐 *';

  @override
  String get expire_time_format => '格式: 2024-12-31';

  @override
  String get bind_domain => '绑定域名（每行一个）';

  @override
  String confirm_delete_tenant(String name) {
    return '确定要删除租户 \"$name\" 吗？';
  }

  @override
  String get package_name => '套餐名称';

  @override
  String get package_name_required => '套餐名称 *';

  @override
  String get tenant_package_list => '租户套餐列表';

  @override
  String get add_package => '新增套餐';

  @override
  String get edit_package => '编辑租户套餐';

  @override
  String get add_tenant_package => '新增租户套餐';

  @override
  String get search_package_name => '搜索套餐名称';

  @override
  String get please_fill_package_name => '请填写套餐名称';

  @override
  String get related_menu_ids => '关联菜单ID（逗号分隔）';

  @override
  String get menu_ids_example => '例如: 1, 2, 3, 100, 101';

  @override
  String confirm_delete_package(String name) {
    return '确定要删除租户套餐 \"$name\" 吗？';
  }

  @override
  String get oauth2_client_list => 'OAuth2 客户端列表';

  @override
  String get add_oauth2_client => '新增 OAuth2 客户端';

  @override
  String get edit_oauth2_client => '编辑 OAuth2 客户端';

  @override
  String get add_client => '新增客户端';

  @override
  String get search_client_name => '搜索客户端名称';

  @override
  String get client_id => '客户端ID';

  @override
  String get client_id_required => '客户端ID *';

  @override
  String get client_secret => '客户端密钥';

  @override
  String get app_name => '应用名称';

  @override
  String get app_name_required => '应用名称 *';

  @override
  String get app_icon => '应用图标';

  @override
  String get app_description => '应用描述';

  @override
  String get access_token_validity => '访问令牌有效期（秒）';

  @override
  String get refresh_token_validity => '刷新令牌有效期（秒）';

  @override
  String seconds(int count) {
    return '$count 秒';
  }

  @override
  String confirm_delete_oauth2_client(String name) {
    return '确定要删除客户端 \"$name\" 吗？';
  }

  @override
  String get oauth2_token_list => 'OAuth2 令牌列表';

  @override
  String get access_token => '访问令牌';

  @override
  String get refresh_token => '刷新令牌';

  @override
  String get user_id => '用户ID';

  @override
  String get user_type => '用户类型';

  @override
  String get expires_time => '过期时间';

  @override
  String get search_client_id => '搜索客户端ID';

  @override
  String get confirm_delete_token => '确定要删除该令牌吗？删除后用户将需要重新登录。';

  @override
  String get admin => '管理员';

  @override
  String get member => '会员';

  @override
  String get unknown => '未知';

  @override
  String get social_client_list => '社交客户端列表';

  @override
  String get add_social_client => '新增社交客户端';

  @override
  String get edit_social_client => '编辑社交客户端';

  @override
  String get search_social_client_name => '搜索客户端名称';

  @override
  String get social_platform => '社交平台';

  @override
  String get social_platform_required => '社交平台 *';

  @override
  String get user_type_required => '用户类型 *';

  @override
  String get agent_id => '代理ID (AgentId)';

  @override
  String get public_key => '公钥';

  @override
  String confirm_delete_social_client(String name) {
    return '确定要删除社交客户端 \"$name\" 吗？';
  }

  @override
  String get dingtalk => '钉钉';

  @override
  String get wecom => '企业微信';

  @override
  String get wechat => '微信';

  @override
  String get qq => 'QQ';

  @override
  String get weibo => '微博';

  @override
  String get wechat_mini => '微信小程序';

  @override
  String get wechat_open => '微信开放平台';

  @override
  String get qq_mini => 'QQ小程序';

  @override
  String get alipay_mini => '支付宝小程序';

  @override
  String get social_user_list => '社交用户列表';

  @override
  String get social_user_detail => '社交用户详情';

  @override
  String get search_nickname => '搜索昵称';

  @override
  String get openid => 'OpenID';

  @override
  String get nickname => '昵称';

  @override
  String get avatar => '头像';

  @override
  String get update_time => '更新时间';

  @override
  String get raw_user_info => '原始用户信息';

  @override
  String get detail => '详情';

  @override
  String get close => '关闭';

  @override
  String get none => '无';
}
