import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// 确认删除对话框标题
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get confirm_delete;

  /// 取消按钮
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// 删除按钮
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// 编辑按钮
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// 确定按钮
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get confirm;

  /// 搜索按钮
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search;

  /// 状态标签
  ///
  /// In zh, this message translates to:
  /// **'状态'**
  String get status;

  /// 状态-开启
  ///
  /// In zh, this message translates to:
  /// **'开启'**
  String get status_enabled;

  /// 状态-禁用
  ///
  /// In zh, this message translates to:
  /// **'禁用'**
  String get status_disabled;

  /// 状态筛选-全部
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get status_all;

  /// 创建时间
  ///
  /// In zh, this message translates to:
  /// **'创建时间'**
  String get create_time;

  /// 操作列标题
  ///
  /// In zh, this message translates to:
  /// **'操作'**
  String get operation;

  /// 删除成功提示
  ///
  /// In zh, this message translates to:
  /// **'删除成功'**
  String get delete_success;

  /// 删除失败提示
  ///
  /// In zh, this message translates to:
  /// **'删除失败: {msg}'**
  String delete_failed(String msg);

  /// 更新成功提示
  ///
  /// In zh, this message translates to:
  /// **'更新成功'**
  String get update_success;

  /// 创建成功提示
  ///
  /// In zh, this message translates to:
  /// **'创建成功'**
  String get create_success;

  /// 操作失败提示
  ///
  /// In zh, this message translates to:
  /// **'操作失败: {msg}'**
  String operation_failed(String msg);

  /// 请填写必填项提示
  ///
  /// In zh, this message translates to:
  /// **'请填写必填项'**
  String get please_fill_required;

  /// 备注字段
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get remark;

  /// 租户名称
  ///
  /// In zh, this message translates to:
  /// **'租户名称'**
  String get tenant_name;

  /// 租户套餐
  ///
  /// In zh, this message translates to:
  /// **'租户套餐'**
  String get tenant_package;

  /// 联系人
  ///
  /// In zh, this message translates to:
  /// **'联系人'**
  String get contact_name;

  /// 联系电话
  ///
  /// In zh, this message translates to:
  /// **'联系电话'**
  String get contact_mobile;

  /// 账号限额
  ///
  /// In zh, this message translates to:
  /// **'账号限额'**
  String get account_limit;

  /// 过期时间
  ///
  /// In zh, this message translates to:
  /// **'过期时间'**
  String get expire_time;

  /// 租户列表标题
  ///
  /// In zh, this message translates to:
  /// **'租户列表'**
  String get tenant_list;

  /// 新增租户按钮
  ///
  /// In zh, this message translates to:
  /// **'新增租户'**
  String get add_tenant;

  /// 编辑租户标题
  ///
  /// In zh, this message translates to:
  /// **'编辑租户'**
  String get edit_tenant;

  /// 搜索租户名称提示
  ///
  /// In zh, this message translates to:
  /// **'搜索租户名称'**
  String get search_tenant_name;

  /// 租户名称（必填）
  ///
  /// In zh, this message translates to:
  /// **'租户名称 *'**
  String get tenant_name_required;

  /// 租户套餐（必填）
  ///
  /// In zh, this message translates to:
  /// **'租户套餐 *'**
  String get tenant_package_required;

  /// 过期时间格式提示
  ///
  /// In zh, this message translates to:
  /// **'格式: 2024-12-31'**
  String get expire_time_format;

  /// 绑定域名提示
  ///
  /// In zh, this message translates to:
  /// **'绑定域名（每行一个）'**
  String get bind_domain;

  /// 确认删除租户提示
  ///
  /// In zh, this message translates to:
  /// **'确定要删除租户 \"{name}\" 吗？'**
  String confirm_delete_tenant(String name);

  /// 套餐名称
  ///
  /// In zh, this message translates to:
  /// **'套餐名称'**
  String get package_name;

  /// 套餐名称（必填）
  ///
  /// In zh, this message translates to:
  /// **'套餐名称 *'**
  String get package_name_required;

  /// 租户套餐列表标题
  ///
  /// In zh, this message translates to:
  /// **'租户套餐列表'**
  String get tenant_package_list;

  /// 新增套餐按钮
  ///
  /// In zh, this message translates to:
  /// **'新增套餐'**
  String get add_package;

  /// 编辑租户套餐标题
  ///
  /// In zh, this message translates to:
  /// **'编辑租户套餐'**
  String get edit_package;

  /// 新增租户套餐标题
  ///
  /// In zh, this message translates to:
  /// **'新增租户套餐'**
  String get add_tenant_package;

  /// 搜索套餐名称提示
  ///
  /// In zh, this message translates to:
  /// **'搜索套餐名称'**
  String get search_package_name;

  /// 请填写套餐名称提示
  ///
  /// In zh, this message translates to:
  /// **'请填写套餐名称'**
  String get please_fill_package_name;

  /// 关联菜单ID提示
  ///
  /// In zh, this message translates to:
  /// **'关联菜单ID（逗号分隔）'**
  String get related_menu_ids;

  /// 菜单ID示例
  ///
  /// In zh, this message translates to:
  /// **'例如: 1, 2, 3, 100, 101'**
  String get menu_ids_example;

  /// 确认删除租户套餐提示
  ///
  /// In zh, this message translates to:
  /// **'确定要删除租户套餐 \"{name}\" 吗？'**
  String confirm_delete_package(String name);

  /// OAuth2 客户端列表标题
  ///
  /// In zh, this message translates to:
  /// **'OAuth2 客户端列表'**
  String get oauth2_client_list;

  /// 新增 OAuth2 客户端标题
  ///
  /// In zh, this message translates to:
  /// **'新增 OAuth2 客户端'**
  String get add_oauth2_client;

  /// 编辑 OAuth2 客户端标题
  ///
  /// In zh, this message translates to:
  /// **'编辑 OAuth2 客户端'**
  String get edit_oauth2_client;

  /// 新增客户端按钮
  ///
  /// In zh, this message translates to:
  /// **'新增客户端'**
  String get add_client;

  /// 搜索客户端名称提示
  ///
  /// In zh, this message translates to:
  /// **'搜索客户端名称'**
  String get search_client_name;

  /// 客户端ID
  ///
  /// In zh, this message translates to:
  /// **'客户端ID'**
  String get client_id;

  /// 客户端ID（必填）
  ///
  /// In zh, this message translates to:
  /// **'客户端ID *'**
  String get client_id_required;

  /// 客户端密钥
  ///
  /// In zh, this message translates to:
  /// **'客户端密钥'**
  String get client_secret;

  /// 应用名称
  ///
  /// In zh, this message translates to:
  /// **'应用名称'**
  String get app_name;

  /// 应用名称（必填）
  ///
  /// In zh, this message translates to:
  /// **'应用名称 *'**
  String get app_name_required;

  /// 应用图标
  ///
  /// In zh, this message translates to:
  /// **'应用图标'**
  String get app_icon;

  /// 应用描述
  ///
  /// In zh, this message translates to:
  /// **'应用描述'**
  String get app_description;

  /// 访问令牌有效期
  ///
  /// In zh, this message translates to:
  /// **'访问令牌有效期（秒）'**
  String get access_token_validity;

  /// 刷新令牌有效期
  ///
  /// In zh, this message translates to:
  /// **'刷新令牌有效期（秒）'**
  String get refresh_token_validity;

  /// 秒数
  ///
  /// In zh, this message translates to:
  /// **'{count} 秒'**
  String seconds(int count);

  /// 确认删除OAuth2客户端提示
  ///
  /// In zh, this message translates to:
  /// **'确定要删除客户端 \"{name}\" 吗？'**
  String confirm_delete_oauth2_client(String name);

  /// OAuth2 令牌列表标题
  ///
  /// In zh, this message translates to:
  /// **'OAuth2 令牌列表'**
  String get oauth2_token_list;

  /// 访问令牌
  ///
  /// In zh, this message translates to:
  /// **'访问令牌'**
  String get access_token;

  /// 刷新令牌
  ///
  /// In zh, this message translates to:
  /// **'刷新令牌'**
  String get refresh_token;

  /// 用户ID
  ///
  /// In zh, this message translates to:
  /// **'用户ID'**
  String get user_id;

  /// 用户类型
  ///
  /// In zh, this message translates to:
  /// **'用户类型'**
  String get user_type;

  /// 过期时间
  ///
  /// In zh, this message translates to:
  /// **'过期时间'**
  String get expires_time;

  /// 搜索客户端ID提示
  ///
  /// In zh, this message translates to:
  /// **'搜索客户端ID'**
  String get search_client_id;

  /// 确认删除令牌提示
  ///
  /// In zh, this message translates to:
  /// **'确定要删除该令牌吗？删除后用户将需要重新登录。'**
  String get confirm_delete_token;

  /// 管理员
  ///
  /// In zh, this message translates to:
  /// **'管理员'**
  String get admin;

  /// 会员
  ///
  /// In zh, this message translates to:
  /// **'会员'**
  String get member;

  /// 未知
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get unknown;

  /// 社交客户端列表标题
  ///
  /// In zh, this message translates to:
  /// **'社交客户端列表'**
  String get social_client_list;

  /// 新增社交客户端标题
  ///
  /// In zh, this message translates to:
  /// **'新增社交客户端'**
  String get add_social_client;

  /// 编辑社交客户端标题
  ///
  /// In zh, this message translates to:
  /// **'编辑社交客户端'**
  String get edit_social_client;

  /// 搜索客户端名称提示
  ///
  /// In zh, this message translates to:
  /// **'搜索客户端名称'**
  String get search_social_client_name;

  /// 社交平台
  ///
  /// In zh, this message translates to:
  /// **'社交平台'**
  String get social_platform;

  /// 社交平台（必填）
  ///
  /// In zh, this message translates to:
  /// **'社交平台 *'**
  String get social_platform_required;

  /// 用户类型（必填）
  ///
  /// In zh, this message translates to:
  /// **'用户类型 *'**
  String get user_type_required;

  /// 代理ID
  ///
  /// In zh, this message translates to:
  /// **'代理ID (AgentId)'**
  String get agent_id;

  /// 公钥
  ///
  /// In zh, this message translates to:
  /// **'公钥'**
  String get public_key;

  /// 确认删除社交客户端提示
  ///
  /// In zh, this message translates to:
  /// **'确定要删除社交客户端 \"{name}\" 吗？'**
  String confirm_delete_social_client(String name);

  /// 钉钉
  ///
  /// In zh, this message translates to:
  /// **'钉钉'**
  String get dingtalk;

  /// 企业微信
  ///
  /// In zh, this message translates to:
  /// **'企业微信'**
  String get wecom;

  /// 微信
  ///
  /// In zh, this message translates to:
  /// **'微信'**
  String get wechat;

  /// QQ
  ///
  /// In zh, this message translates to:
  /// **'QQ'**
  String get qq;

  /// 微博
  ///
  /// In zh, this message translates to:
  /// **'微博'**
  String get weibo;

  /// 微信小程序
  ///
  /// In zh, this message translates to:
  /// **'微信小程序'**
  String get wechat_mini;

  /// 微信开放平台
  ///
  /// In zh, this message translates to:
  /// **'微信开放平台'**
  String get wechat_open;

  /// QQ小程序
  ///
  /// In zh, this message translates to:
  /// **'QQ小程序'**
  String get qq_mini;

  /// 支付宝小程序
  ///
  /// In zh, this message translates to:
  /// **'支付宝小程序'**
  String get alipay_mini;

  /// 社交用户列表标题
  ///
  /// In zh, this message translates to:
  /// **'社交用户列表'**
  String get social_user_list;

  /// 社交用户详情标题
  ///
  /// In zh, this message translates to:
  /// **'社交用户详情'**
  String get social_user_detail;

  /// 搜索昵称提示
  ///
  /// In zh, this message translates to:
  /// **'搜索昵称'**
  String get search_nickname;

  /// OpenID
  ///
  /// In zh, this message translates to:
  /// **'OpenID'**
  String get openid;

  /// 昵称
  ///
  /// In zh, this message translates to:
  /// **'昵称'**
  String get nickname;

  /// 头像
  ///
  /// In zh, this message translates to:
  /// **'头像'**
  String get avatar;

  /// 更新时间
  ///
  /// In zh, this message translates to:
  /// **'更新时间'**
  String get update_time;

  /// 原始用户信息
  ///
  /// In zh, this message translates to:
  /// **'原始用户信息'**
  String get raw_user_info;

  /// 详情按钮
  ///
  /// In zh, this message translates to:
  /// **'详情'**
  String get detail;

  /// 关闭按钮
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// 无
  ///
  /// In zh, this message translates to:
  /// **'无'**
  String get none;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'zh':
      return SZh();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
