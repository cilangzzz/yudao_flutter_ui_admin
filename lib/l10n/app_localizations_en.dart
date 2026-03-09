// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get confirm_delete => 'Confirm Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get search => 'Search';

  @override
  String get status => 'Status';

  @override
  String get status_enabled => 'Enabled';

  @override
  String get status_disabled => 'Disabled';

  @override
  String get status_all => 'All';

  @override
  String get create_time => 'Create Time';

  @override
  String get operation => 'Operation';

  @override
  String get delete_success => 'Deleted successfully';

  @override
  String delete_failed(String msg) {
    return 'Delete failed: $msg';
  }

  @override
  String get update_success => 'Updated successfully';

  @override
  String get create_success => 'Created successfully';

  @override
  String operation_failed(String msg) {
    return 'Operation failed: $msg';
  }

  @override
  String get please_fill_required => 'Please fill in required fields';

  @override
  String get remark => 'Remark';

  @override
  String get tenant_name => 'Tenant Name';

  @override
  String get tenant_package => 'Tenant Package';

  @override
  String get contact_name => 'Contact Name';

  @override
  String get contact_mobile => 'Contact Mobile';

  @override
  String get account_limit => 'Account Limit';

  @override
  String get expire_time => 'Expire Time';

  @override
  String get tenant_list => 'Tenant List';

  @override
  String get add_tenant => 'Add Tenant';

  @override
  String get edit_tenant => 'Edit Tenant';

  @override
  String get search_tenant_name => 'Search tenant name';

  @override
  String get tenant_name_required => 'Tenant Name *';

  @override
  String get tenant_package_required => 'Tenant Package *';

  @override
  String get expire_time_format => 'Format: 2024-12-31';

  @override
  String get bind_domain => 'Bind Domain (one per line)';

  @override
  String confirm_delete_tenant(String name) {
    return 'Are you sure to delete tenant \"$name\"?';
  }

  @override
  String get package_name => 'Package Name';

  @override
  String get package_name_required => 'Package Name *';

  @override
  String get tenant_package_list => 'Tenant Package List';

  @override
  String get add_package => 'Add Package';

  @override
  String get edit_package => 'Edit Tenant Package';

  @override
  String get add_tenant_package => 'Add Tenant Package';

  @override
  String get search_package_name => 'Search package name';

  @override
  String get please_fill_package_name => 'Please fill in package name';

  @override
  String get related_menu_ids => 'Related Menu IDs (comma separated)';

  @override
  String get menu_ids_example => 'e.g.: 1, 2, 3, 100, 101';

  @override
  String confirm_delete_package(String name) {
    return 'Are you sure to delete tenant package \"$name\"?';
  }

  @override
  String get oauth2_client_list => 'OAuth2 Client List';

  @override
  String get add_oauth2_client => 'Add OAuth2 Client';

  @override
  String get edit_oauth2_client => 'Edit OAuth2 Client';

  @override
  String get add_client => 'Add Client';

  @override
  String get search_client_name => 'Search client name';

  @override
  String get client_id => 'Client ID';

  @override
  String get client_id_required => 'Client ID *';

  @override
  String get client_secret => 'Client Secret';

  @override
  String get app_name => 'App Name';

  @override
  String get app_name_required => 'App Name *';

  @override
  String get app_icon => 'App Icon';

  @override
  String get app_description => 'App Description';

  @override
  String get access_token_validity => 'Access Token Validity (seconds)';

  @override
  String get refresh_token_validity => 'Refresh Token Validity (seconds)';

  @override
  String seconds(int count) {
    return '$count seconds';
  }

  @override
  String confirm_delete_oauth2_client(String name) {
    return 'Are you sure to delete client \"$name\"?';
  }

  @override
  String get oauth2_token_list => 'OAuth2 Token List';

  @override
  String get access_token => 'Access Token';

  @override
  String get refresh_token => 'Refresh Token';

  @override
  String get user_id => 'User ID';

  @override
  String get user_type => 'User Type';

  @override
  String get expires_time => 'Expires Time';

  @override
  String get search_client_id => 'Search client ID';

  @override
  String get confirm_delete_token =>
      'Are you sure to delete this token? The user will need to log in again.';

  @override
  String get admin => 'Admin';

  @override
  String get member => 'Member';

  @override
  String get unknown => 'Unknown';

  @override
  String get social_client_list => 'Social Client List';

  @override
  String get add_social_client => 'Add Social Client';

  @override
  String get edit_social_client => 'Edit Social Client';

  @override
  String get search_social_client_name => 'Search client name';

  @override
  String get social_platform => 'Social Platform';

  @override
  String get social_platform_required => 'Social Platform *';

  @override
  String get user_type_required => 'User Type *';

  @override
  String get agent_id => 'Agent ID';

  @override
  String get public_key => 'Public Key';

  @override
  String confirm_delete_social_client(String name) {
    return 'Are you sure to delete social client \"$name\"?';
  }

  @override
  String get dingtalk => 'DingTalk';

  @override
  String get wecom => 'WeCom';

  @override
  String get wechat => 'WeChat';

  @override
  String get qq => 'QQ';

  @override
  String get weibo => 'Weibo';

  @override
  String get wechat_mini => 'WeChat Mini Program';

  @override
  String get wechat_open => 'WeChat Open Platform';

  @override
  String get qq_mini => 'QQ Mini Program';

  @override
  String get alipay_mini => 'Alipay Mini Program';

  @override
  String get social_user_list => 'Social User List';

  @override
  String get social_user_detail => 'Social User Detail';

  @override
  String get search_nickname => 'Search nickname';

  @override
  String get openid => 'OpenID';

  @override
  String get nickname => 'Nickname';

  @override
  String get avatar => 'Avatar';

  @override
  String get update_time => 'Update Time';

  @override
  String get raw_user_info => 'Raw User Info';

  @override
  String get detail => 'Detail';

  @override
  String get close => 'Close';

  @override
  String get none => 'None';
}
