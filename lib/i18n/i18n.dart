import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// 国际化字符串类
abstract class S {
  static const LocalizationsDelegate<S> delegate = _AppLocalizationsDelegate();
  static S? _current;

  static S get current {
    assert(_current != null, 'S.current is null. Did you forget to add S.delegate to MaterialApp?');
    return _current!;
  }

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  // 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];

  // 通用翻译 - 应用信息
  String get appName;
  String get appVersion;

  // 通用翻译 - 认证相关
  String get login;
  String get logout;
  String get username;
  String get password;
  String get confirmPassword;
  String get rememberMe;
  String get forgetPassword;
  String get register;
  String get captcha;
  String get sendCaptcha;

  // 通用翻译 - 操作按钮
  String get search;
  String get reset;
  String get add;
  String get edit;
  String get delete;
  String get confirm;
  String get cancel;
  String get submit;
  String get save;
  String get close;
  String get closeOtherTabs;
  String get closeAllTabs;
  String get refresh;
  String get export;
  String get import;
  String get download;
  String get upload;
  String get copy;
  String get move;
  String get view;
  String get detail;
  String get more;
  String get expand;
  String get collapse;
  String get selectAll;
  String get clearAll;
  String get filter;
  String get sort;

  // 通用翻译 - 状态
  String get status;
  String get enabled;
  String get disabled;
  String get normal;
  String get stopped;
  String get pending;
  String get processing;
  String get success;
  String get failed;
  String get warning;
  String get error;
  String get info;
  String get online;
  String get offline;

  // 通用翻译 - 时间
  String get createTime;
  String get updateTime;
  String get startTime;
  String get endTime;
  String get expireTime;
  String get lastLoginTime;
  String get duration;
  String get today;
  String get yesterday;
  String get thisWeek;
  String get thisMonth;
  String get thisYear;
  String get custom;

  // 通用翻译 - 表格/列表
  String get operation;
  String get action;
  String get index;
  String get total;
  String get items;
  String get page;
  String get pageSize;
  String get prevPage;
  String get nextPage;
  String get firstPage;
  String get lastPage;
  String get jumpTo;
  String get rowsPerPage;

  // 通用翻译 - 提示信息
  String get loading;
  String get loadFailed;
  String get noData;
  String get noMore;
  String get retry;
  String get operationSuccess;
  String get operationFailed;
  String get deleteSuccess;
  String get deleteFailed;
  String get saveSuccess;
  String get saveFailed;
  String get confirmDelete;
  String get confirmOperation;
  String get pleaseConfirm;
  String get tips;
  String get notice;
  String get message;
  String get notification;

  // 通用翻译 - 用户相关
  String get profile;
  String get settings;
  String get notLoggedIn;
  String get welcome;
  String get hello;
  String get goodbye;
  String get personalCenter;
  String get changePassword;
  String get oldPassword;
  String get newPassword;

  // 通用翻译 - 表单
  String get pleaseEnter;
  String get pleaseSelect;
  String get pleaseInput;
  String get pleaseChoose;
  String get pleaseEnterUsername;
  String get pleaseEnterPassword;
  String get pleaseEnterConfirmPassword;
  String get pleaseEnterOldPassword;
  String get pleaseEnterNewPassword;
  String get pleaseEnterCaptcha;
  String get pleaseEnterKeyword;
  String get requiredField;
  String get invalidFormat;
  String get minLength;
  String get maxLength;
  String get passwordNotMatch;
  String get usernameOrPasswordError;
  String get loginFailed;
  String get loginSuccess;
  String get logoutSuccess;
  String get logoutFailed;

  // 通用翻译 - 验证
  String get validateSuccess;
  String get validateFailed;
  String get fieldRequired;
  String get fieldInvalid;
  String get emailInvalid;
  String get phoneInvalid;
  String get urlInvalid;
  String get numberInvalid;
  String get dateInvalid;

  // 通用翻译 - 系统菜单
  String get system;
  String get user;
  String get role;
  String get menu;
  String get dept;
  String get post;
  String get dict;
  String get dictData;
  String get dictType;
  String get log;
  String get loginLog;
  String get operateLog;
  String get config;
  String get permission;
  String get area;

  // 通用翻译 - 其他
  String get yes;
  String get no;
  String get ok;
  String get back;
  String get home;
  String get dashboard;
  String get help;
  String get about;
  String get feedback;
  String get language;
  String get theme;
  String get darkMode;
  String get lightMode;
  String get systemMode;
  String get version;
  String get copyright;
  String get allRightsReserved;

  // 角色管理
  String get roleManagement;
  String get roleList;
  String get addRole;
  String get editRole;
  String get roleName;
  String get roleCode;
  String get menuPermission;
  String get dataPermission;

  // 菜单管理
  String get menuManagement;
  String get menuList;
  String get addMenu;
  String get editMenu;
  String get menuName;
  String get icon;
  String get iconHint;
  String get routePath;
  String get routePathHint;
  String get componentPath;
  String get componentName;
  String get permissionHint;
  String get menuType;
  String get parentMenu;
  String get topMenu;
  String get searchMenuName;
  String get visible;
  String get show;
  String get hide;
  String get cache;
  String get alwaysShow;
  String get confirmDeleteMenu;
  String get menuHasChildren;

  // 部门管理
  String get deptManagement;
  String get deptList;
  String get addDept;
  String get editDept;
  String get deptName;
  String get leader;
  String get phone;
  String get email;
  String get searchDeptName;
  String get expandAll;
  String get collapseAll;
  String get confirmDeleteDept;
  String get department;
  String get parentDept;
  String get topDept;
  String get addChild;
  String get deptHasChildren;

  // 用户管理
  String get userManagement;
  String get userList;
  String get addUser;
  String get editUser;
  String get confirmEnableUser;
  String get confirmDisableUser;
  String get confirmDeleteUser;
  String get enable;
  String get disable;

  // 地区管理
  String get areaManagement;
  String get areaCode;
  String get areaName;
  String get areaList;
  String get ipQuery;
  String get ipAddress;
  String get ipAddressHint;
  String get pleaseInputIp;
  String get queryResult;
  String get queryFailed;

  // 通知消息管理
  String get notifyMessageManagement;
  String get notifyMessageList;
  String get noMessages;
  String get notifyMessage;
  String get messageId;
  String get senderName;
  String get messageContent;
  String get readStatus;
  String get read;
  String get unread;
  String get readTime;
  String get siteMessage;
  String get mail;
  String get sms;
  String get unknown;

  // 通知模板管理
  String get notifyTemplateManagement;
  String get addNotifyTemplate;
  String get editNotifyTemplate;
  String get noTemplateData;
  String get templateList;
  String get sender;
  String get supportParamFormat;
  String get sendTest;
  String get receiverUserId;
  String get inputUserId;
  String get pleaseInputValidUserId;
  String get sendSuccess;
  String get sendFailed;
  String get addTemplate;

  // 邮件账号管理
  String get mailAccountManagement;
  String get mailAccountList;
  String get addMailAccount;
  String get editMailAccount;
  String get mailAddress;
  String get smtpServer;
  String get smtpPort;
  String get smtpServerPort;
  String get sslEnable;
  String get starttlsEnable;
  String get pleaseInputMail;
  String get pleaseInputUsername;
  String get pleaseInputPassword;
  String get pleaseInputSmtpServer;
  String get pleaseInputPort;
  String get confirmDeleteMailAccount;

  // 邮件模板管理
  String get mailTemplateManagement;
  String get mailTemplateList;
  String get addMailTemplate;
  String get editMailTemplate;
  String get templateTitle;
  String get mailAccount;
  String get pleaseInputTemplateName;
  String get pleaseInputTemplateCode;
  String get pleaseSelectMailAccount;
  String get pleaseInputTemplateTitle;
  String get pleaseInputTemplateContent;
  String get confirmDeleteMailTemplate;
  String get testSendMail;
  String get toMail;
  String get ccMail;
  String get bccMail;
  String get multipleMailsHint;
  String get pleaseInputToMail;
  String get pleaseInputParamValue;
  String get param;
  String get mailSendSuccess;
  String get mailSendFailed;

  // 邮件日志管理
  String get mailLogManagement;
  String get mailLogList;
  String get userId;
  String get templateId;
  String get userType;
  String get admin;
  String get member;
  String get sendStatus;
  String get sending;
  String get sendSuccessStatus;
  String get sendFailedStatus;
  String get notSend;
  String get sendTime;
  String get fromMail;
  String get toMails;
  String get ccMails;
  String get bccMails;
  String get mailTitle;
  String get sendMessageId;
  String get sendException;
  String get mailLogDetail;

  // 短信渠道管理
  String get smsChannelManagement;
  String get smsChannelList;
  String get addSmsChannel;
  String get editSmsChannel;
  String get smsSignature;
  String get channelCode;
  String get channelStatus;
  String get smsApiKey;
  String get smsApiSecret;
  String get smsCallbackUrl;
  String get searchSmsSignature;
  String get pleaseFillRequired;
  String get confirmDeleteSmsChannel;
  String get aliyun;
  String get tencentCloud;
  String get huaweiCloud;
  String get yunpian;
  String get apiAccount;

  // 短信日志管理
  String get smsLogManagement;
  String get smsLogList;
  String get mobile;
  String get smsChannel;
  String get smsContent;
  String get receiveStatus;
  String get receiveTime;
  String get smsLogDetail;
  String get apiSendCode;
  String get apiSendMsg;
  String get apiReceiveCode;
  String get apiReceiveMsg;
  String get apiRequestId;
  String get apiSerialNo;
  String get initialized;
  String get waitingReceive;
  String get receiveSuccess;
  String get receiveFailed;
  String get totalRecords;

  // 短信模板管理
  String get smsTemplateManagement;
  String get smsTemplateList;
  String get addSmsTemplate;
  String get editSmsTemplate;
  String get smsType;
  String get verifyCode;
  // String get notification;
  String get marketing;
  String get apiTemplateId;
  String get apiTemplateNo;
  String get smsTemplateContentHint;
  String get confirmDeleteSmsTemplate;
  String get testSendSms;
  String get mobileNumber;
  String get pleaseInputMobile;
  String get smsSendSuccess;

  // 其他通用
  String get id;
  String get code;
  String get name;
  String get nickname;
  String get content;
  String get type;
  String get templateCode;
  String get templateName;
  String get templateContent;
  String get templateType;
  String get templateParams;
  String get testBtn;
  String get open;
  String get closed;
  String get all;

  // 租户管理
  String get tenantName;
  String get tenantPackage;
  String get contactName;
  String get contactMobile;
  String get accountLimit;
  String get tenantList;
  String get addTenant;
  String get editTenant;
  String get searchTenantName;
  String get tenantNameRequired;
  String get tenantPackageRequired;
  String get expireTimeFormat;
  String get bindDomain;
  String get confirmDeleteTenant;

  // 租户套餐管理
  String get packageName;
  String get packageNameRequired;
  String get tenantPackageList;
  String get addTenantPackageBtn;
  String get editTenantPackage;
  String get addTenantPackage;
  String get searchPackageName;
  String get pleaseFillPackageName;
  String get relatedMenuIds;
  String get menuIdsExample;
  String get confirmDeletePackage;

  // OAuth2 客户端管理
  String get oauth2ClientList;
  String get addOAuth2ClientTitle;
  String get editOAuth2Client;
  String get addClient;
  String get searchClientName;
  String get clientId;
  String get clientIdRequired;
  String get clientSecret;
  // String get appName;
  String get appNameRequired;
  String get appIcon;
  String get appDescription;
  String get accessTokenValidity;
  String get refreshTokenValidity;
  String get seconds;
  String get confirmDeleteOAuth2Client;

  // OAuth2 令牌管理
  String get oauth2TokenList;
  String get accessToken;
  String get refreshToken;
  // String get userId;
  // String get userType;
  String get expiresTime;
  String get searchClientId;
  String get confirmDeleteToken;

  // 用户类型
  // String get admin;
  // String get member;

  // 社交客户端管理
  String get socialClientList;
  String get addSocialClient;
  String get editSocialClient;
  String get searchSocialClientName;
  String get socialPlatform;
  String get socialPlatformRequired;
  String get userTypeRequired;
  String get agentId;
  String get publicKey;
  String get confirmDeleteSocialClient;

  // 社交平台类型
  String get dingtalk;
  String get wecom;
  String get wechat;
  String get qq;
  String get weibo;
  String get wechatMini;
  String get wechatOpen;
  String get qqMini;
  String get alipayMini;

  // 社交用户管理
  String get socialUserList;
  String get socialUserDetail;
  String get searchNickname;
  String get openid;
  String get avatar;
  String get rawUserInfo;
  String get none;
  String get socialToken;
  String get rawTokenInfo;
  String get lastAuthCode;
  String get lastAuthState;

  // 提示信息
  String get updateSuccess;
  String get createSuccess;
  String get addSuccess;
  String get editSuccess;

  // 岗位管理
  String get postId;
  String get postName;
  String get postCode;
  String get postSort;
  String get postList;
  String get addPost;
  String get editPost;
  String get confirmDeletePost;

  // 字典管理
  String get dictName;
  String get addDictType;
  String get editDictType;
  String get addType;
  String get confirmDeleteDictType;
  String get searchDictNameOrType;
  String get dictTypeList;
  String get dataLabel;
  String get dataValue;
  String get colorType;
  String get colorDefault;
  String get colorPrimary;
  String get colorSuccess;
  String get colorWarning;
  String get colorDanger;
  String get colorInfo;
  String get cssClass;
  String get cssClassHint;
  String get addDictData;
  String get editDictData;
  String get addData;
  String get confirmDeleteDictData;
  String get currentDictType;
  String get pleaseSelectDictType;
  String get pleaseSelectDictTypeLeft;
  String get dictDataList;
  String get color;
  String get remark;

  // 登录日志
  String get loginLog_loadFailed;
  String get loginLog_detailTitle;
  String get loginLog_logId;
  String get loginLog_logType;
  String get loginLog_username;
  String get loginLog_loginAddress;
  String get loginLog_browser;
  String get loginLog_loginResult;
  String get loginLog_loginDate;
  String get loginLog_typePassword;
  String get loginLog_typeSocial;
  String get loginLog_list;
  String get loginLog_loginTime;

  // 操作日志
  String get operateLog_loadFailed;
  String get operateLog_detailTitle;
  String get operateLog_logId;
  String get operateLog_traceId;
  String get operateLog_userId;
  String get operateLog_userType;
  String get operateLog_userName;
  String get operateLog_userIp;
  String get operateLog_userAgent;
  String get operateLog_module;
  String get operateLog_actionName;
  String get operateLog_actionContent;
  String get operateLog_extra;
  String get operateLog_requestUrl;
  String get operateLog_operateTime;
  String get operateLog_bizId;
  String get operateLog_userTypeAdmin;
  String get operateLog_userTypeMember;
  String get operateLog_list;

  // 公告管理
  String get noticeId;
  String get noticeName;
  String get noticeType;
  String get noticeContent;
  String get noticeCreator;
  String get noticeList;
  String get addNotice;
  String get editNotice;
  String get confirmDeleteNotice;
  String get confirmPush;
  String get confirmPushNotice;
  String get push;
  String get pushSuccess;
  String get pushFailed;
  String get typeNotify;
  String get typeAnnouncement;
  String get typeUnknown;

  // 用户管理扩展
  String get resetPassword;
  String get assignRole;
  String get deleteBatch;
  String get pleaseSelectData;
  String get passwordRequired;
  String get confirmDeleteSelected;
  String get exportSuccess;
  String get exportFailed;
  String get sex;
  String get male;
  String get female;
  // String get mobile;

  // 通用扩展
  String get common_close;
  String get common_success;
  String get common_failed;
  String get common_totalCount;
  String get common_selectTimeRange;
  String get common_search;
  String get common_reset;
  String get common_detail;
  String get common_operation;

  cacl_common_totalCount(int totalCount) {}

  // 带参数的方法
  // String common_totalCount(int count);
}

/// Strings 扩展，用于兼容旧的翻译访问方式
extension StringsExtension on S {
  _Strings get strings => _Strings(this);
}

/// Strings 辅助类
class _Strings {
  final S _s;
  _Strings(this._s);

  String get loadFailed => _s.loadFailed;
  String get status => _s.status;
  String get all => _s.all;
  String get enabled => _s.enabled;
  String get disabled => _s.disabled;
  String get search => _s.search;
  String get reset => _s.reset;
  String get noticeName => _s.noticeName;
  String get noticeList => _s.noticeList;
  String get addNotice => _s.addNotice;
  String get editNotice => _s.editNotice;
  String get noticeId => _s.noticeId;
  String get noticeType => _s.noticeType;
  String get noticeCreator => _s.noticeCreator;
  String get createTime => _s.createTime;
  String get operation => _s.operation;
  String get noticeContent => _s.noticeContent;
  String get typeNotify => _s.typeNotify;
  String get typeAnnouncement => _s.typeAnnouncement;
  String get typeUnknown => _s.typeUnknown;
  String get retry => _s.retry;
  String get noData => _s.noData;
  String get confirmDelete => _s.confirmDelete;
  String get confirmDeleteNotice => _s.confirmDeleteNotice;
  String get delete => _s.delete;
  String get cancel => _s.cancel;
  String get deleteSuccess => _s.deleteSuccess;
  String get deleteFailed => _s.deleteFailed;
  String get confirmPush => _s.confirmPush;
  String get confirmPushNotice => _s.confirmPushNotice;
  String get push => _s.push;
  String get pushSuccess => _s.pushSuccess;
  String get pushFailed => _s.pushFailed;
  String get edit => _s.edit;
  String get pleaseFillRequired => _s.pleaseFillRequired;
  String get addSuccess => _s.addSuccess;
  String get editSuccess => _s.editSuccess;
  String get operationFailed => _s.operationFailed;
  String get confirm => _s.confirm;

  
}

/// 本地化代理
class _AppLocalizationsDelegate extends LocalizationsDelegate<S> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['zh', 'en'].contains(locale.languageCode);

  @override
  Future<S> load(Locale locale) async {
    final String path = 'assets/i18n/${locale.languageCode}.json';
    try {
      final String json = await rootBundle.loadString(path);
      final Map<String, dynamic> data = jsonDecode(json);
      S._current = _AppLocalizations(data);
    } catch (e) {
      // 如果加载失败，使用默认中文
      S._current = _AppLocalizations({});
    }
    return S._current!;
  }

  @override
  bool shouldReload(LocalizationsDelegate<S> old) => false;
}

/// 本地化实现
class _AppLocalizations extends S {
  final Map<String, dynamic> _data;

  _AppLocalizations(this._data);

  String _get(String key, [String? defaultValue]) {
    return _data[key]?.toString() ?? defaultValue ?? key;
  }

  // 应用信息
  @override
  String get appName => _get('appName', 'Yudao Admin');
  @override
  String get appVersion => _get('appVersion', 'Version');

  // 认证相关
  @override
  String get login => _get('login', 'Login');
  @override
  String get logout => _get('logout', 'Logout');
  @override
  String get username => _get('username', 'Username');
  @override
  String get password => _get('password', 'Password');
  @override
  String get confirmPassword => _get('confirmPassword', 'Confirm Password');
  @override
  String get rememberMe => _get('rememberMe', 'Remember Me');
  @override
  String get forgetPassword => _get('forgetPassword', 'Forget Password');
  @override
  String get register => _get('register', 'Register');
  @override
  String get captcha => _get('captcha', 'Captcha');
  @override
  String get sendCaptcha => _get('sendCaptcha', 'Send Captcha');

  // 操作按钮
  @override
  String get search => _get('search', 'Search');
  @override
  String get reset => _get('reset', 'Reset');
  @override
  String get add => _get('add', 'Add');
  @override
  String get edit => _get('edit', 'Edit');
  @override
  String get delete => _get('delete', 'Delete');
  @override
  String get confirm => _get('confirm', 'Confirm');
  @override
  String get cancel => _get('cancel', 'Cancel');
  @override
  String get submit => _get('submit', 'Submit');
  @override
  String get save => _get('save', 'Save');
  @override
  String get close => _get('close', 'Close');
  @override
  String get closeOtherTabs => _get('closeOtherTabs', 'Close Other Tabs');
  @override
  String get closeAllTabs => _get('closeAllTabs', 'Close All Tabs');
  @override
  String get refresh => _get('refresh', 'Refresh');
  @override
  String get export => _get('export', 'Export');
  @override
  String get import => _get('import', 'Import');
  @override
  String get download => _get('download', 'Download');
  @override
  String get upload => _get('upload', 'Upload');
  @override
  String get copy => _get('copy', 'Copy');
  @override
  String get move => _get('move', 'Move');
  @override
  String get view => _get('view', 'View');
  @override
  String get detail => _get('detail', 'Detail');
  @override
  String get more => _get('more', 'More');
  @override
  String get expand => _get('expand', 'Expand');
  @override
  String get collapse => _get('collapse', 'Collapse');
  @override
  String get selectAll => _get('selectAll', 'Select All');
  @override
  String get clearAll => _get('clearAll', 'Clear All');
  @override
  String get filter => _get('filter', 'Filter');
  @override
  String get sort => _get('sort', 'Sort');

  // 状态
  @override
  String get status => _get('status', 'Status');
  @override
  String get enabled => _get('enabled', 'Enabled');
  @override
  String get disabled => _get('disabled', 'Disabled');
  @override
  String get normal => _get('normal', 'Normal');
  @override
  String get stopped => _get('stopped', 'Stopped');
  @override
  String get pending => _get('pending', 'Pending');
  @override
  String get processing => _get('processing', 'Processing');
  @override
  String get success => _get('success', 'Success');
  @override
  String get failed => _get('failed', 'Failed');
  @override
  String get warning => _get('warning', 'Warning');
  @override
  String get error => _get('error', 'Error');
  @override
  String get info => _get('info', 'Info');
  @override
  String get online => _get('online', 'Online');
  @override
  String get offline => _get('offline', 'Offline');

  // 时间
  @override
  String get createTime => _get('createTime', 'Create Time');
  @override
  String get updateTime => _get('updateTime', 'Update Time');
  @override
  String get startTime => _get('startTime', 'Start Time');
  @override
  String get endTime => _get('endTime', 'End Time');
  @override
  String get expireTime => _get('expireTime', 'Expire Time');
  @override
  String get lastLoginTime => _get('lastLoginTime', 'Last Login Time');
  @override
  String get duration => _get('duration', 'Duration');
  @override
  String get today => _get('today', 'Today');
  @override
  String get yesterday => _get('yesterday', 'Yesterday');
  @override
  String get thisWeek => _get('thisWeek', 'This Week');
  @override
  String get thisMonth => _get('thisMonth', 'This Month');
  @override
  String get thisYear => _get('thisYear', 'This Year');
  @override
  String get custom => _get('custom', 'Custom');

  // 表格/列表
  @override
  String get operation => _get('operation', 'Operation');
  @override
  String get action => _get('action', 'Action');
  @override
  String get index => _get('index', 'Index');
  @override
  String get total => _get('total', 'Total');
  @override
  String get items => _get('items', 'Items');
  @override
  String get page => _get('page', 'Page');
  @override
  String get pageSize => _get('pageSize', 'Page Size');
  @override
  String get prevPage => _get('prevPage', 'Previous');
  @override
  String get nextPage => _get('nextPage', 'Next');
  @override
  String get firstPage => _get('firstPage', 'First');
  @override
  String get lastPage => _get('lastPage', 'Last');
  @override
  String get jumpTo => _get('jumpTo', 'Jump to');
  @override
  String get rowsPerPage => _get('rowsPerPage', 'Rows per page');

  // 提示信息
  @override
  String get loading => _get('loading', 'Loading...');
  @override
  String get loadFailed => _get('loadFailed', 'Load Failed');
  @override
  String get noData => _get('noData', 'No Data');
  @override
  String get noMore => _get('noMore', 'No More');
  @override
  String get retry => _get('retry', 'Retry');
  @override
  String get operationSuccess => _get('operationSuccess', 'Operation Success');
  @override
  String get operationFailed => _get('operationFailed', 'Operation Failed');
  @override
  String get deleteSuccess => _get('deleteSuccess', 'Delete Success');
  @override
  String get deleteFailed => _get('deleteFailed', 'Delete Failed');
  @override
  String get saveSuccess => _get('saveSuccess', 'Save Success');
  @override
  String get saveFailed => _get('saveFailed', 'Save Failed');
  @override
  String get confirmDelete => _get('confirmDelete', 'Are you sure to delete?');
  @override
  String get confirmOperation => _get('confirmOperation', 'Confirm Operation');
  @override
  String get pleaseConfirm => _get('pleaseConfirm', 'Please Confirm');
  @override
  String get tips => _get('tips', 'Tips');
  @override
  String get notice => _get('notice', 'Notice');
  @override
  String get message => _get('message', 'Message');
  @override
  String get notification => _get('notification', 'Notification');

  // 用户相关
  @override
  String get profile => _get('profile', 'Profile');
  @override
  String get settings => _get('settings', 'Settings');
  @override
  String get notLoggedIn => _get('notLoggedIn', 'Not Logged In');
  @override
  String get welcome => _get('welcome', 'Welcome');
  @override
  String get hello => _get('hello', 'Hello');
  @override
  String get goodbye => _get('goodbye', 'Goodbye');
  @override
  String get personalCenter => _get('personalCenter', 'Personal Center');
  @override
  String get changePassword => _get('changePassword', 'Change Password');
  @override
  String get oldPassword => _get('oldPassword', 'Old Password');
  @override
  String get newPassword => _get('newPassword', 'New Password');

  // 表单
  @override
  String get pleaseEnter => _get('pleaseEnter', 'Please Enter');
  @override
  String get pleaseSelect => _get('pleaseSelect', 'Please Select');
  @override
  String get pleaseInput => _get('pleaseInput', 'Please Input');
  @override
  String get pleaseChoose => _get('pleaseChoose', 'Please Choose');
  @override
  String get pleaseEnterUsername => _get('pleaseEnterUsername', 'Please enter username');
  @override
  String get pleaseEnterPassword => _get('pleaseEnterPassword', 'Please enter password');
  @override
  String get pleaseEnterConfirmPassword => _get('pleaseEnterConfirmPassword', 'Please enter confirm password');
  @override
  String get pleaseEnterOldPassword => _get('pleaseEnterOldPassword', 'Please enter old password');
  @override
  String get pleaseEnterNewPassword => _get('pleaseEnterNewPassword', 'Please enter new password');
  @override
  String get pleaseEnterCaptcha => _get('pleaseEnterCaptcha', 'Please enter captcha');
  @override
  String get pleaseEnterKeyword => _get('pleaseEnterKeyword', 'Please enter keyword');
  @override
  String get requiredField => _get('requiredField', 'Required Field');
  @override
  String get invalidFormat => _get('invalidFormat', 'Invalid Format');
  @override
  String get minLength => _get('minLength', 'Min Length');
  @override
  String get maxLength => _get('maxLength', 'Max Length');
  @override
  String get passwordNotMatch => _get('passwordNotMatch', 'Password Not Match');
  @override
  String get usernameOrPasswordError => _get('usernameOrPasswordError', 'Username or Password Error');
  @override
  String get loginFailed => _get('loginFailed', 'Login Failed');
  @override
  String get loginSuccess => _get('loginSuccess', 'Login Success');
  @override
  String get logoutSuccess => _get('logoutSuccess', 'Logout Success');
  @override
  String get logoutFailed => _get('logoutFailed', 'Logout Failed');

  // 验证
  @override
  String get validateSuccess => _get('validateSuccess', 'Validate Success');
  @override
  String get validateFailed => _get('validateFailed', 'Validate Failed');
  @override
  String get fieldRequired => _get('fieldRequired', 'Field Required');
  @override
  String get fieldInvalid => _get('fieldInvalid', 'Field Invalid');
  @override
  String get emailInvalid => _get('emailInvalid', 'Email Invalid');
  @override
  String get phoneInvalid => _get('phoneInvalid', 'Phone Invalid');
  @override
  String get urlInvalid => _get('urlInvalid', 'URL Invalid');
  @override
  String get numberInvalid => _get('numberInvalid', 'Number Invalid');
  @override
  String get dateInvalid => _get('dateInvalid', 'Date Invalid');

  // 系统菜单
  @override
  String get system => _get('system', 'System');
  @override
  String get user => _get('user', 'User');
  @override
  String get role => _get('role', 'Role');
  @override
  String get menu => _get('menu', 'Menu');
  @override
  String get dept => _get('dept', 'Department');
  @override
  String get post => _get('post', 'Post');
  @override
  String get dict => _get('dict', 'Dictionary');
  @override
  String get dictData => _get('dictData', 'Dictionary Data');
  @override
  String get dictType => _get('dictType', 'Dictionary Type');
  @override
  String get log => _get('log', 'Log');
  @override
  String get loginLog => _get('loginLog', 'Login Log');
  @override
  String get operateLog => _get('operateLog', 'Operation Log');
  @override
  String get config => _get('config', 'Config');
  @override
  String get permission => _get('permission', 'Permission');
  @override
  String get area => _get('area', 'Area');

  // 其他
  @override
  String get yes => _get('yes', 'Yes');
  @override
  String get no => _get('no', 'No');
  @override
  String get ok => _get('ok', 'OK');
  @override
  String get back => _get('back', 'Back');
  @override
  String get home => _get('home', 'Home');
  @override
  String get dashboard => _get('dashboard', 'Dashboard');
  @override
  String get help => _get('help', 'Help');
  @override
  String get about => _get('about', 'About');
  @override
  String get feedback => _get('feedback', 'Feedback');
  @override
  String get language => _get('language', 'Language');
  @override
  String get theme => _get('theme', 'Theme');
  @override
  String get darkMode => _get('darkMode', 'Dark Mode');
  @override
  String get lightMode => _get('lightMode', 'Light Mode');
  @override
  String get systemMode => _get('systemMode', 'System Mode');
  @override
  String get version => _get('version', 'Version');
  @override
  String get copyright => _get('copyright', 'Copyright');
  @override
  String get allRightsReserved => _get('allRightsReserved', 'All Rights Reserved');

  // 角色管理
  @override
  String get roleManagement => _get('roleManagement', 'Role Management');
  @override
  String get roleList => _get('roleList', 'Role List');
  @override
  String get addRole => _get('addRole', 'Add Role');
  @override
  String get editRole => _get('editRole', 'Edit Role');
  @override
  String get roleName => _get('roleName', 'Role Name');
  @override
  String get roleCode => _get('roleCode', 'Role Code');
  @override
  String get menuPermission => _get('menuPermission', 'Menu Permission');
  @override
  String get dataPermission => _get('dataPermission', 'Data Permission');

  // 菜单管理
  @override
  String get menuManagement => _get('menuManagement', 'Menu Management');
  @override
  String get menuList => _get('menuList', 'Menu List');
  @override
  String get addMenu => _get('addMenu', 'Add Menu');
  @override
  String get editMenu => _get('editMenu', 'Edit Menu');
  @override
  String get menuName => _get('menuName', 'Menu Name');
  @override
  String get icon => _get('icon', 'Icon');
  @override
  String get iconHint => _get('iconHint', 'Please input icon name');
  @override
  String get routePath => _get('routePath', 'Route Path');
  @override
  String get routePathHint => _get('routePathHint', 'Route path like: user');
  @override
  String get componentPath => _get('componentPath', 'Component Path');
  @override
  String get componentName => _get('componentName', 'Component Name');
  @override
  String get permissionHint => _get('permissionHint', 'Permission identifier like: system:user:add');
  @override
  String get menuType => _get('menuType', 'Menu Type');
  @override
  String get parentMenu => _get('parentMenu', 'Parent Menu');
  @override
  String get topMenu => _get('topMenu', 'Top Menu');
  @override
  String get searchMenuName => _get('searchMenuName', 'Search Menu Name');
  @override
  String get visible => _get('visible', 'Visible');
  @override
  String get show => _get('show', 'Show');
  @override
  String get hide => _get('hide', 'Hide');
  @override
  String get cache => _get('cache', 'Cache');
  @override
  String get alwaysShow => _get('alwaysShow', 'Always Show');
  @override
  String get confirmDeleteMenu => _get('confirmDeleteMenu', 'Are you sure to delete this menu?');
  @override
  String get menuHasChildren => _get('menuHasChildren', 'Menu has children, cannot delete');

  // 部门管理
  @override
  String get deptManagement => _get('deptManagement', 'Department Management');
  @override
  String get deptList => _get('deptList', 'Department List');
  @override
  String get addDept => _get('addDept', 'Add Department');
  @override
  String get editDept => _get('editDept', 'Edit Department');
  @override
  String get deptName => _get('deptName', 'Department Name');
  @override
  String get leader => _get('leader', 'Leader');
  @override
  String get phone => _get('phone', 'Phone');
  @override
  String get email => _get('email', 'Email');
  @override
  String get searchDeptName => _get('searchDeptName', 'Search Department Name');
  @override
  String get expandAll => _get('expandAll', 'Expand All');
  @override
  String get collapseAll => _get('collapseAll', 'Collapse All');
  @override
  String get confirmDeleteDept => _get('confirmDeleteDept', 'Are you sure to delete this department?');
  @override
  String get department => _get('department', 'Department');
  @override
  String get parentDept => _get('parentDept', 'Parent Department');
  @override
  String get topDept => _get('topDept', 'Top Department');
  @override
  String get addChild => _get('addChild', 'Add Child');
  @override
  String get deptHasChildren => _get('deptHasChildren', 'Department has children, cannot delete');

  // 用户管理
  @override
  String get userManagement => _get('userManagement', 'User Management');
  @override
  String get userList => _get('userList', 'User List');
  @override
  String get addUser => _get('addUser', 'Add User');
  @override
  String get editUser => _get('editUser', 'Edit User');
  @override
  String get confirmEnableUser => _get('confirmEnableUser', 'Are you sure to enable this user?');
  @override
  String get confirmDisableUser => _get('confirmDisableUser', 'Are you sure to disable this user?');
  @override
  String get confirmDeleteUser => _get('confirmDeleteUser', 'Are you sure to delete this user?');
  @override
  String get enable => _get('enable', 'Enable');
  @override
  String get disable => _get('disable', 'Disable');

  // 地区管理
  @override
  String get areaManagement => _get('areaManagement', 'Area Management');
  @override
  String get areaCode => _get('areaCode', 'Area Code');
  @override
  String get areaName => _get('areaName', 'Area Name');
  @override
  String get areaList => _get('areaList', 'Area List');
  @override
  String get ipQuery => _get('ipQuery', 'IP Query');
  @override
  String get ipAddress => _get('ipAddress', 'IP Address');
  @override
  String get ipAddressHint => _get('ipAddressHint', 'Please input IP address');
  @override
  String get pleaseInputIp => _get('pleaseInputIp', 'Please input IP');
  @override
  String get queryResult => _get('queryResult', 'Query Result');
  @override
  String get queryFailed => _get('queryFailed', 'Query Failed');

  // 通知消息管理
  @override
  String get notifyMessageManagement => _get('notifyMessageManagement', 'Notify Message Management');
  @override
  String get notifyMessageList => _get('notifyMessageList', 'Notify Message List');
  @override
  String get noMessages => _get('noMessages', 'No Messages');
  @override
  String get notifyMessage => _get('notifyMessage', 'Notify Message');
  @override
  String get messageId => _get('messageId', 'Message ID');
  @override
  String get senderName => _get('senderName', 'Sender Name');
  @override
  String get messageContent => _get('messageContent', 'Message Content');
  @override
  String get readStatus => _get('readStatus', 'Read Status');
  @override
  String get read => _get('read', 'Read');
  @override
  String get unread => _get('unread', 'Unread');
  @override
  String get readTime => _get('readTime', 'Read Time');
  @override
  String get siteMessage => _get('siteMessage', 'Site Message');
  @override
  String get mail => _get('mail', 'Mail');
  @override
  String get sms => _get('sms', 'SMS');
  @override
  String get unknown => _get('unknown', 'Unknown');

  // 通知模板管理
  @override
  String get notifyTemplateManagement => _get('notifyTemplateManagement', 'Notify Template Management');
  @override
  String get addNotifyTemplate => _get('addNotifyTemplate', 'Add Notify Template');
  @override
  String get editNotifyTemplate => _get('editNotifyTemplate', 'Edit Notify Template');
  @override
  String get noTemplateData => _get('noTemplateData', 'No Template Data');
  @override
  String get templateList => _get('templateList', 'Template List');
  @override
  String get sender => _get('sender', 'Sender');
  @override
  String get supportParamFormat => _get('supportParamFormat', 'Support param format');
  @override
  String get sendTest => _get('sendTest', 'Send Test');
  @override
  String get receiverUserId => _get('receiverUserId', 'Receiver User ID');
  @override
  String get inputUserId => _get('inputUserId', 'Input User ID');
  @override
  String get pleaseInputValidUserId => _get('pleaseInputValidUserId', 'Please input valid user ID');
  @override
  String get sendSuccess => _get('sendSuccess', 'Send Success');
  @override
  String get sendFailed => _get('sendFailed', 'Send Failed');
  @override
  String get addTemplate => _get('addTemplate', 'Add Template');

  // 邮件账号管理
  @override
  String get mailAccountManagement => _get('mailAccountManagement', 'Mail Account Management');
  @override
  String get mailAccountList => _get('mailAccountList', 'Mail Account List');
  @override
  String get addMailAccount => _get('addMailAccount', 'Add Mail Account');
  @override
  String get editMailAccount => _get('editMailAccount', 'Edit Mail Account');
  @override
  String get mailAddress => _get('mailAddress', 'Mail Address');
  @override
  String get smtpServer => _get('smtpServer', 'SMTP Server');
  @override
  String get smtpPort => _get('smtpPort', 'SMTP Port');
  @override
  String get smtpServerPort => _get('smtpServerPort', 'SMTP Server:Port');
  @override
  String get sslEnable => _get('sslEnable', 'SSL Enable');
  @override
  String get starttlsEnable => _get('starttlsEnable', 'STARTTLS Enable');
  @override
  String get pleaseInputMail => _get('pleaseInputMail', 'Please input mail');
  @override
  String get pleaseInputUsername => _get('pleaseInputUsername', 'Please input username');
  @override
  String get pleaseInputPassword => _get('pleaseInputPassword', 'Please input password');
  @override
  String get pleaseInputSmtpServer => _get('pleaseInputSmtpServer', 'Please input SMTP server');
  @override
  String get pleaseInputPort => _get('pleaseInputPort', 'Please input port');
  @override
  String get confirmDeleteMailAccount => _get('confirmDeleteMailAccount', 'Are you sure to delete this mail account?');

  // 邮件模板管理
  @override
  String get mailTemplateManagement => _get('mailTemplateManagement', 'Mail Template Management');
  @override
  String get mailTemplateList => _get('mailTemplateList', 'Mail Template List');
  @override
  String get addMailTemplate => _get('addMailTemplate', 'Add Mail Template');
  @override
  String get editMailTemplate => _get('editMailTemplate', 'Edit Mail Template');
  @override
  String get templateTitle => _get('templateTitle', 'Template Title');
  @override
  String get mailAccount => _get('mailAccount', 'Mail Account');
  @override
  String get pleaseInputTemplateName => _get('pleaseInputTemplateName', 'Please input template name');
  @override
  String get pleaseInputTemplateCode => _get('pleaseInputTemplateCode', 'Please input template code');
  @override
  String get pleaseSelectMailAccount => _get('pleaseSelectMailAccount', 'Please select mail account');
  @override
  String get pleaseInputTemplateTitle => _get('pleaseInputTemplateTitle', 'Please input template title');
  @override
  String get pleaseInputTemplateContent => _get('pleaseInputTemplateContent', 'Please input template content');
  @override
  String get confirmDeleteMailTemplate => _get('confirmDeleteMailTemplate', 'Are you sure to delete this mail template?');
  @override
  String get testSendMail => _get('testSendMail', 'Test Send Mail');
  @override
  String get toMail => _get('toMail', 'To Mail');
  @override
  String get ccMail => _get('ccMail', 'CC Mail');
  @override
  String get bccMail => _get('bccMail', 'BCC Mail');
  @override
  String get multipleMailsHint => _get('multipleMailsHint', 'Multiple emails separated by comma');
  @override
  String get pleaseInputToMail => _get('pleaseInputToMail', 'Please input to mail');
  @override
  String get pleaseInputParamValue => _get('pleaseInputParamValue', 'Please input param value');
  @override
  String get param => _get('param', 'Param');
  @override
  String get mailSendSuccess => _get('mailSendSuccess', 'Mail Send Success');
  @override
  String get mailSendFailed => _get('mailSendFailed', 'Mail Send Failed');

  // 邮件日志管理
  @override
  String get mailLogManagement => _get('mailLogManagement', 'Mail Log Management');
  @override
  String get mailLogList => _get('mailLogList', 'Mail Log List');
  @override
  String get userId => _get('userId', 'User ID');
  @override
  String get templateId => _get('templateId', 'Template ID');
  @override
  String get userType => _get('userType', 'User Type');
  @override
  String get admin => _get('admin', 'Admin');
  @override
  String get member => _get('member', 'Member');
  @override
  String get sendStatus => _get('sendStatus', 'Send Status');
  @override
  String get sending => _get('sending', 'Sending');
  @override
  String get sendSuccessStatus => _get('sendSuccessStatus', 'Send Success');
  @override
  String get sendFailedStatus => _get('sendFailedStatus', 'Send Failed');
  @override
  String get notSend => _get('notSend', 'Not Send');
  @override
  String get sendTime => _get('sendTime', 'Send Time');
  @override
  String get fromMail => _get('fromMail', 'From Mail');
  @override
  String get toMails => _get('toMails', 'To Mails');
  @override
  String get ccMails => _get('ccMails', 'CC Mails');
  @override
  String get bccMails => _get('bccMails', 'BCC Mails');
  @override
  String get mailTitle => _get('mailTitle', 'Mail Title');
  @override
  String get sendMessageId => _get('sendMessageId', 'Send Message ID');
  @override
  String get sendException => _get('sendException', 'Send Exception');
  @override
  String get mailLogDetail => _get('mailLogDetail', 'Mail Log Detail');

  // 短信渠道管理
  @override
  String get smsChannelManagement => _get('smsChannelManagement', 'SMS Channel Management');
  @override
  String get smsChannelList => _get('smsChannelList', 'SMS Channel List');
  @override
  String get addSmsChannel => _get('addSmsChannel', 'Add SMS Channel');
  @override
  String get editSmsChannel => _get('editSmsChannel', 'Edit SMS Channel');
  @override
  String get smsSignature => _get('smsSignature', 'SMS Signature');
  @override
  String get channelCode => _get('channelCode', 'Channel Code');
  @override
  String get channelStatus => _get('channelStatus', 'Channel Status');
  @override
  String get smsApiKey => _get('smsApiKey', 'SMS API Key');
  @override
  String get smsApiSecret => _get('smsApiSecret', 'SMS API Secret');
  @override
  String get smsCallbackUrl => _get('smsCallbackUrl', 'SMS Callback URL');
  @override
  String get searchSmsSignature => _get('searchSmsSignature', 'Search SMS Signature');
  @override
  String get pleaseFillRequired => _get('pleaseFillRequired', 'Please fill required fields');
  @override
  String get confirmDeleteSmsChannel => _get('confirmDeleteSmsChannel', 'Are you sure to delete this SMS channel?');
  @override
  String get aliyun => _get('aliyun', 'Aliyun');
  @override
  String get tencentCloud => _get('tencentCloud', 'Tencent Cloud');
  @override
  String get huaweiCloud => _get('huaweiCloud', 'Huawei Cloud');
  @override
  String get yunpian => _get('yunpian', 'Yunpian');
  @override
  String get apiAccount => _get('apiAccount', 'API Account');

  // 短信日志管理
  @override
  String get smsLogManagement => _get('smsLogManagement', 'SMS Log Management');
  @override
  String get smsLogList => _get('smsLogList', 'SMS Log List');
  @override
  String get mobile => _get('mobile', 'Mobile');
  @override
  String get smsChannel => _get('smsChannel', 'SMS Channel');
  @override
  String get smsContent => _get('smsContent', 'SMS Content');
  @override
  String get receiveStatus => _get('receiveStatus', 'Receive Status');
  @override
  String get receiveTime => _get('receiveTime', 'Receive Time');
  @override
  String get smsLogDetail => _get('smsLogDetail', 'SMS Log Detail');
  @override
  String get apiSendCode => _get('apiSendCode', 'API Send Code');
  @override
  String get apiSendMsg => _get('apiSendMsg', 'API Send Message');
  @override
  String get apiReceiveCode => _get('apiReceiveCode', 'API Receive Code');
  @override
  String get apiReceiveMsg => _get('apiReceiveMsg', 'API Receive Message');
  @override
  String get apiRequestId => _get('apiRequestId', 'API Request ID');
  @override
  String get apiSerialNo => _get('apiSerialNo', 'API Serial No');
  @override
  String get initialized => _get('initialized', 'Initialized');
  @override
  String get waitingReceive => _get('waitingReceive', 'Waiting Receive');
  @override
  String get receiveSuccess => _get('receiveSuccess', 'Receive Success');
  @override
  String get receiveFailed => _get('receiveFailed', 'Receive Failed');
  @override
  String get totalRecords => _get('totalRecords', 'Total Records');

  // 短信模板管理
  @override
  String get smsTemplateManagement => _get('smsTemplateManagement', 'SMS Template Management');
  @override
  String get smsTemplateList => _get('smsTemplateList', 'SMS Template List');
  @override
  String get addSmsTemplate => _get('addSmsTemplate', 'Add SMS Template');
  @override
  String get editSmsTemplate => _get('editSmsTemplate', 'Edit SMS Template');
  @override
  String get smsType => _get('smsType', 'SMS Type');
  @override
  String get verifyCode => _get('verifyCode', 'Verify Code');
  // @override
  // String get notification => _get('notification', 'Notification');
  @override
  String get marketing => _get('marketing', 'Marketing');
  @override
  String get apiTemplateId => _get('apiTemplateId', 'API Template ID');
  @override
  String get apiTemplateNo => _get('apiTemplateNo', 'API Template No');
  @override
  String get smsTemplateContentHint => _get('smsTemplateContentHint', 'SMS Template Content Hint');
  @override
  String get confirmDeleteSmsTemplate => _get('confirmDeleteSmsTemplate', 'Are you sure to delete this SMS template?');
  @override
  String get testSendSms => _get('testSendSms', 'Test Send SMS');
  @override
  String get mobileNumber => _get('mobileNumber', 'Mobile Number');
  @override
  String get pleaseInputMobile => _get('pleaseInputMobile', 'Please input mobile number');
  @override
  String get smsSendSuccess => _get('smsSendSuccess', 'SMS Send Success');

  // 其他通用
  @override
  String get id => _get('id', 'ID');
  @override
  String get code => _get('code', 'Code');
  @override
  String get name => _get('name', 'Name');
  @override
  String get nickname => _get('nickname', 'Nickname');
  @override
  String get content => _get('content', 'Content');
  @override
  String get type => _get('type', 'Type');
  @override
  String get templateCode => _get('templateCode', 'Template Code');
  @override
  String get templateName => _get('templateName', 'Template Name');
  @override
  String get templateContent => _get('templateContent', 'Template Content');
  @override
  String get templateType => _get('templateType', 'Template Type');
  @override
  String get templateParams => _get('templateParams', 'Template Params');
  @override
  String get testBtn => _get('testBtn', 'Test');
  @override
  String get open => _get('open', 'Open');
  @override
  String get closed => _get('closed', 'Closed');
  @override
  String get all => _get('all', 'All');

  // 租户管理
  @override
  String get tenantName => _get('tenantName', 'Tenant Name');
  @override
  String get tenantPackage => _get('tenantPackage', 'Tenant Package');
  @override
  String get contactName => _get('contactName', 'Contact Name');
  @override
  String get contactMobile => _get('contactMobile', 'Contact Mobile');
  @override
  String get accountLimit => _get('accountLimit', 'Account Limit');
  @override
  String get tenantList => _get('tenantList', 'Tenant List');
  @override
  String get addTenant => _get('addTenant', 'Add Tenant');
  @override
  String get editTenant => _get('editTenant', 'Edit Tenant');
  @override
  String get searchTenantName => _get('searchTenantName', 'Search Tenant Name');
  @override
  String get tenantNameRequired => _get('tenantNameRequired', 'Tenant Name *');
  @override
  String get tenantPackageRequired => _get('tenantPackageRequired', 'Tenant Package *');
  @override
  String get expireTimeFormat => _get('expireTimeFormat', 'Format: 2024-12-31');
  @override
  String get bindDomain => _get('bindDomain', 'Bind Domain');
  @override
  String get confirmDeleteTenant => _get('confirmDeleteTenant', 'Confirm Delete Tenant');

  // 租户套餐管理
  @override
  String get packageName => _get('packageName', 'Package Name');
  @override
  String get packageNameRequired => _get('packageNameRequired', 'Package Name *');
  @override
  String get tenantPackageList => _get('tenantPackageList', 'Tenant Package List');
  @override
  String get addTenantPackageBtn => _get('addTenantPackageBtn', 'Add Package');
  @override
  String get editTenantPackage => _get('editTenantPackage', 'Edit Tenant Package');
  @override
  String get addTenantPackage => _get('addTenantPackage', 'Add Tenant Package');
  @override
  String get searchPackageName => _get('searchPackageName', 'Search Package Name');
  @override
  String get pleaseFillPackageName => _get('pleaseFillPackageName', 'Please fill package name');
  @override
  String get relatedMenuIds => _get('relatedMenuIds', 'Related Menu IDs');
  @override
  String get menuIdsExample => _get('menuIdsExample', 'Example: 1, 2, 3, 100, 101');
  @override
  String get confirmDeletePackage => _get('confirmDeletePackage', 'Confirm Delete Package');

  // OAuth2 客户端管理
  @override
  String get oauth2ClientList => _get('oauth2ClientList', 'OAuth2 Client List');
  @override
  String get addOAuth2ClientTitle => _get('addOAuth2ClientTitle', 'Add OAuth2 Client');
  @override
  String get editOAuth2Client => _get('editOAuth2Client', 'Edit OAuth2 Client');
  @override
  String get addClient => _get('addClient', 'Add Client');
  @override
  String get searchClientName => _get('searchClientName', 'Search Client Name');
  @override
  String get clientId => _get('clientId', 'Client ID');
  @override
  String get clientIdRequired => _get('clientIdRequired', 'Client ID *');
  @override
  String get clientSecret => _get('clientSecret', 'Client Secret');
  @override
  String get appNameRequired => _get('appNameRequired', 'App Name *');
  @override
  String get appIcon => _get('appIcon', 'App Icon');
  @override
  String get appDescription => _get('appDescription', 'App Description');
  @override
  String get accessTokenValidity => _get('accessTokenValidity', 'Access Token Validity (seconds)');
  @override
  String get refreshTokenValidity => _get('refreshTokenValidity', 'Refresh Token Validity (seconds)');
  @override
  String get seconds => _get('seconds', 'seconds');
  @override
  String get confirmDeleteOAuth2Client => _get('confirmDeleteOAuth2Client', 'Confirm Delete Client');

  // OAuth2 令牌管理
  @override
  String get oauth2TokenList => _get('oauth2TokenList', 'OAuth2 Token List');
  @override
  String get accessToken => _get('accessToken', 'Access Token');
  @override
  String get refreshToken => _get('refreshToken', 'Refresh Token');
  @override
  String get expiresTime => _get('expiresTime', 'Expires Time');
  @override
  String get searchClientId => _get('searchClientId', 'Search Client ID');
  @override
  String get confirmDeleteToken => _get('confirmDeleteToken', 'Confirm Delete Token');

  // 社交客户端管理
  @override
  String get socialClientList => _get('socialClientList', 'Social Client List');
  @override
  String get addSocialClient => _get('addSocialClient', 'Add Social Client');
  @override
  String get editSocialClient => _get('editSocialClient', 'Edit Social Client');
  @override
  String get searchSocialClientName => _get('searchSocialClientName', 'Search Social Client Name');
  @override
  String get socialPlatform => _get('socialPlatform', 'Social Platform');
  @override
  String get socialPlatformRequired => _get('socialPlatformRequired', 'Social Platform *');
  @override
  String get userTypeRequired => _get('userTypeRequired', 'User Type *');
  @override
  String get agentId => _get('agentId', 'Agent ID');
  @override
  String get publicKey => _get('publicKey', 'Public Key');
  @override
  String get confirmDeleteSocialClient => _get('confirmDeleteSocialClient', 'Confirm Delete Social Client');

  // 社交平台类型
  @override
  String get dingtalk => _get('dingtalk', 'DingTalk');
  @override
  String get wecom => _get('wecom', 'WeCom');
  @override
  String get wechat => _get('wechat', 'WeChat');
  @override
  String get qq => _get('qq', 'QQ');
  @override
  String get weibo => _get('weibo', 'Weibo');
  @override
  String get wechatMini => _get('wechatMini', 'WeChat Mini');
  @override
  String get wechatOpen => _get('wechatOpen', 'WeChat Open');
  @override
  String get qqMini => _get('qqMini', 'QQ Mini');
  @override
  String get alipayMini => _get('alipayMini', 'Alipay Mini');

  // 社交用户管理
  @override
  String get socialUserList => _get('socialUserList', 'Social User List');
  @override
  String get socialUserDetail => _get('socialUserDetail', 'Social User Detail');
  @override
  String get searchNickname => _get('searchNickname', 'Search Nickname');
  @override
  String get openid => _get('openid', 'OpenID');
  @override
  String get avatar => _get('avatar', 'Avatar');
  @override
  String get rawUserInfo => _get('rawUserInfo', 'Raw User Info');
  @override
  String get none => _get('none', 'None');
  @override
  String get socialToken => _get('socialToken', 'Social Token');
  @override
  String get rawTokenInfo => _get('rawTokenInfo', 'Raw Token Info');
  @override
  String get lastAuthCode => _get('lastAuthCode', 'Last Auth Code');
  @override
  String get lastAuthState => _get('lastAuthState', 'Last Auth State');

  // 提示信息
  @override
  String get updateSuccess => _get('updateSuccess', 'Update Success');
  @override
  String get createSuccess => _get('createSuccess', 'Create Success');
  @override
  String get addSuccess => _get('addSuccess', 'Add Success');
  @override
  String get editSuccess => _get('editSuccess', 'Edit Success');

  // 岗位管理
  @override
  String get postId => _get('postId', 'Post ID');
  @override
  String get postName => _get('postName', 'Post Name');
  @override
  String get postCode => _get('postCode', 'Post Code');
  @override
  String get postSort => _get('postSort', 'Post Sort');
  @override
  String get postList => _get('postList', 'Post List');
  @override
  String get addPost => _get('addPost', 'Add Post');
  @override
  String get editPost => _get('editPost', 'Edit Post');
  @override
  String get confirmDeletePost => _get('confirmDeletePost', 'Are you sure to delete this post?');

  // 字典管理
  @override
  String get dictName => _get('dictName', 'Dict Name');
  @override
  String get addDictType => _get('addDictType', 'Add Dict Type');
  @override
  String get editDictType => _get('editDictType', 'Edit Dict Type');
  @override
  String get addType => _get('addType', 'Add Type');
  @override
  String get confirmDeleteDictType => _get('confirmDeleteDictType', 'Are you sure to delete this dict type?');
  @override
  String get searchDictNameOrType => _get('searchDictNameOrType', 'Search dict name or type');
  @override
  String get dictTypeList => _get('dictTypeList', 'Dict Type List');
  @override
  String get dataLabel => _get('dataLabel', 'Data Label');
  @override
  String get dataValue => _get('dataValue', 'Data Value');
  @override
  String get colorType => _get('colorType', 'Color Type');
  @override
  String get colorDefault => _get('colorDefault', 'Default');
  @override
  String get colorPrimary => _get('colorPrimary', 'Primary');
  @override
  String get colorSuccess => _get('colorSuccess', 'Success');
  @override
  String get colorWarning => _get('colorWarning', 'Warning');
  @override
  String get colorDanger => _get('colorDanger', 'Danger');
  @override
  String get colorInfo => _get('colorInfo', 'Info');
  @override
  String get cssClass => _get('cssClass', 'CSS Class');
  @override
  String get cssClassHint => _get('cssClassHint', 'Enter hex color, e.g. #108ee9');
  @override
  String get addDictData => _get('addDictData', 'Add Dict Data');
  @override
  String get editDictData => _get('editDictData', 'Edit Dict Data');
  @override
  String get addData => _get('addData', 'Add Data');
  @override
  String get confirmDeleteDictData => _get('confirmDeleteDictData', 'Are you sure to delete this dict data?');
  @override
  String get currentDictType => _get('currentDictType', 'Current Dict Type');
  @override
  String get pleaseSelectDictType => _get('pleaseSelectDictType', 'Please select dict type');
  @override
  String get pleaseSelectDictTypeLeft => _get('pleaseSelectDictTypeLeft', 'Please select dict type from left');
  @override
  String get dictDataList => _get('dictDataList', 'Dict Data List');
  @override
  String get color => _get('color', 'Color');

  // 登录日志
  @override
  String get loginLog_loadFailed => _get('loginLog_loadFailed', 'Load Failed');
  @override
  String get loginLog_detailTitle => _get('loginLog_detailTitle', 'Login Log Detail');
  @override
  String get loginLog_logId => _get('loginLog_logId', 'Log ID');
  @override
  String get loginLog_logType => _get('loginLog_logType', 'Log Type');
  @override
  String get loginLog_username => _get('loginLog_username', 'Username');
  @override
  String get loginLog_loginAddress => _get('loginLog_loginAddress', 'Login Address');
  @override
  String get loginLog_browser => _get('loginLog_browser', 'Browser');
  @override
  String get loginLog_loginResult => _get('loginLog_loginResult', 'Login Result');
  @override
  String get loginLog_loginDate => _get('loginLog_loginDate', 'Login Date');
  @override
  String get loginLog_typePassword => _get('loginLog_typePassword', 'Password Login');
  @override
  String get loginLog_typeSocial => _get('loginLog_typeSocial', 'Social Login');
  @override
  String get loginLog_list => _get('loginLog_list', 'Login Log List');
  @override
  String get loginLog_loginTime => _get('loginLog_loginTime', 'Login Time');

  // 操作日志
  @override
  String get operateLog_loadFailed => _get('operateLog_loadFailed', 'Load Failed');
  @override
  String get operateLog_detailTitle => _get('operateLog_detailTitle', 'Operate Log Detail');
  @override
  String get operateLog_logId => _get('operateLog_logId', 'Log ID');
  @override
  String get operateLog_traceId => _get('operateLog_traceId', 'Trace ID');
  @override
  String get operateLog_userId => _get('operateLog_userId', 'User ID');
  @override
  String get operateLog_userType => _get('operateLog_userType', 'User Type');
  @override
  String get operateLog_userName => _get('operateLog_userName', 'Username');
  @override
  String get operateLog_userIp => _get('operateLog_userIp', 'User IP');
  @override
  String get operateLog_userAgent => _get('operateLog_userAgent', 'User Agent');
  @override
  String get operateLog_module => _get('operateLog_module', 'Module');
  @override
  String get operateLog_actionName => _get('operateLog_actionName', 'Action Name');
  @override
  String get operateLog_actionContent => _get('operateLog_actionContent', 'Action Content');
  @override
  String get operateLog_extra => _get('operateLog_extra', 'Extra');
  @override
  String get operateLog_requestUrl => _get('operateLog_requestUrl', 'Request URL');
  @override
  String get operateLog_operateTime => _get('operateLog_operateTime', 'Operate Time');
  @override
  String get operateLog_bizId => _get('operateLog_bizId', 'Biz ID');
  @override
  String get operateLog_userTypeAdmin => _get('operateLog_userTypeAdmin', 'Admin');
  @override
  String get operateLog_userTypeMember => _get('operateLog_userTypeMember', 'Member');
  @override
  String get operateLog_list => _get('operateLog_list', 'Operate Log List');

  // 公告管理
  @override
  String get noticeId => _get('noticeId', 'Notice ID');
  @override
  String get noticeName => _get('noticeName', 'Notice Name');
  @override
  String get noticeType => _get('noticeType', 'Notice Type');
  @override
  String get noticeContent => _get('noticeContent', 'Notice Content');
  @override
  String get noticeCreator => _get('noticeCreator', 'Notice Creator');
  @override
  String get noticeList => _get('noticeList', 'Notice List');
  @override
  String get addNotice => _get('addNotice', 'Add Notice');
  @override
  String get editNotice => _get('editNotice', 'Edit Notice');
  @override
  String get confirmDeleteNotice => _get('confirmDeleteNotice', 'Are you sure to delete this notice?');
  @override
  String get confirmPush => _get('confirmPush', 'Confirm Push');
  @override
  String get confirmPushNotice => _get('confirmPushNotice', 'Are you sure to push this notice?');
  @override
  String get push => _get('push', 'Push');
  @override
  String get pushSuccess => _get('pushSuccess', 'Push Success');
  @override
  String get pushFailed => _get('pushFailed', 'Push Failed');
  @override
  String get typeNotify => _get('typeNotify', 'Notify');
  @override
  String get typeAnnouncement => _get('typeAnnouncement', 'Announcement');
  @override
  String get typeUnknown => _get('typeUnknown', 'Unknown');

  // 用户管理扩展
  @override
  String get resetPassword => _get('resetPassword', 'Reset Password');
  @override
  String get assignRole => _get('assignRole', 'Assign Role');
  @override
  String get deleteBatch => _get('deleteBatch', 'Batch Delete');
  @override
  String get pleaseSelectData => _get('pleaseSelectData', 'Please select data');
  @override
  String get passwordRequired => _get('passwordRequired', 'Password is required');
  @override
  String get confirmDeleteSelected => _get('confirmDeleteSelected', 'Are you sure to delete selected items?');
  @override
  String get exportSuccess => _get('exportSuccess', 'Export Success');
  @override
  String get exportFailed => _get('exportFailed', 'Export Failed');
  @override
  String get sex => _get('sex', 'Sex');
  @override
  String get male => _get('male', 'Male');
  @override
  String get female => _get('female', 'Female');


  // 通用扩展
  @override
  String get common_close => _get('common_close', 'Close');
  @override
  String get common_success => _get('common_success', 'Success');
  @override
  String get common_failed => _get('common_failed', 'Failed');
  @override
  String get common_totalCount => _get('common_totalCount', 'Total: %s');
  @override
  String get common_selectTimeRange => _get('common_selectTimeRange', 'Select Time Range');
  @override
  String get common_search => _get('common_search', 'Search');
  @override
  String get common_reset => _get('common_reset', 'Reset');
  @override
  String get common_detail => _get('common_detail', 'Detail');
  @override
  String get common_operation => _get('common_operation', 'Operation');

  @override
  String get remark => _get('remark', 'Remark');

  // 带参数的方法
  @override
  String cacl_common_totalCount(int count) {
    final template = _get('common_totalCount', 'Total: %s');
    return template.replaceAll('%s', count.toString());
  }
}



/// 全局访问点
S get s => S.current;