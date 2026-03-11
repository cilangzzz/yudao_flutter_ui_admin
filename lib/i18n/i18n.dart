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

  // Infra 模块 - 监控相关
  String get infra;
  String get serverMonitor;
  String get serverMonitorDesc;
  String get apiDocs;
  String get apiDocsDesc;
  String get druidMonitor;
  String get druidMonitorDesc;
  String get skywalkingMonitor;
  String get skywalkingMonitorDesc;
  String get webSocketMonitor;
  String get formDesigner;

  // Infra 模块 - WebSocket
  String get connectionManagement;
  String get connectionStatus;
  String get connected;
  String get disconnected;
  String get connect;
  String get disconnect;
  String get connecting;
  String get serverAddress;
  String get sendMessage;
  String get selectReceiver;
  String get everyone;
  String get messageHistory;
  String get messagesCount;
  String get messageCannotBeEmpty;
  String get pleaseConnectFirst;
  String get groupMessage;
  String get singleMessage;
  String get systemMessage;
  String get copiedToClipboard;

  // Infra 模块 - 表单设计器
  String get componentLibrary;
  String get dragComponentHere;
  String get selectFieldToConfig;
  String get fieldProperties;
  String get fieldName;
  String get label;
  String get placeholder;
  String get defaultValue;
  String get required;
  String get preview;
  String get clear;

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
  String get assignMenuPermission;
  String get assignDataPermission;
  String get dataScope;
  String get dataScopeAll;
  String get dataScopeCustom;
  String get dataScopeDeptOnly;
  String get dataScopeDeptBelow;
  String get dataScopeSelfOnly;
  String get customDeptHint;

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

  // 定时任务管理
  String get jobId;
  String get jobName;
  String get jobList;
  String get addJob;
  String get editJob;
  String get jobDetail;
  String get confirmDeleteJob;
  String get handlerName;
  String get handlerParam;
  String get handlerNamePlaceholder;
  String get cronExpression;
  String get cronExpressionPlaceholder;
  String get retryCount;
  String get retryCountPlaceholder;
  String get retryInterval;
  String get retryIntervalPlaceholder;
  String get monitorTimeout;
  String get monitorTimeoutPlaceholder;
  String get nextExecuteTime;
  String get noNextExecuteTime;
  String get jobStatusNormal;
  String get jobStatusStop;
  String get jobStart;
  String get jobPause;
  String get jobExecute;
  String get jobLog;
  String get milliseconds;
  String get notEnabled;

  // 任务日志管理
  String get logId;
  String get jobLogList;
  String get jobLogDetail;
  String get executeIndex;
  String get executeTime;
  String get jobLogStatusSuccess;
  String get jobLogStatusFailure;
  String get result;

  // 字典管理
  String get dictName;
  String get addDictType;
  String get editDictType;
  String get addType;
  String get confirmDeleteDictType;
  String get viewDictData;
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

  // 代码生成
  String get codegenList;
  String get importTable;
  String get preview;
  String get generateCode;
  String get sync;
  String get syncSuccess;
  String get syncFailed;
  String get confirmSync;
  String get confirmSyncTable;
  String get generateSuccess;
  String get generateFailed;
  String get confirmDeleteTable;
  String get confirmDeleteTables;
  String get confirmDeleteBatch;
  String get tableName;
  String get tableComment;
  String get className;
  String get classNameHelp;
  String get classNameHelp2;
  String get author;
  String get dataSource;
  String get pleaseSelectDataSource;
  String get pleaseSelectTable;
  String get importSuccess;
  String get importFailed;
  String get codePreview;
  String get pleaseSelectFile;
  String get copySuccess;
  String get editCodegen;
  String get basicInfo;
  String get columnInfo;
  String get generationInfo;
  String get prevStep;
  String get nextStep;
  String get columnName;
  String get columnComment;
  String get dataType;
  String get javaType;
  String get javaField;
  String get insert;
  String get query;
  String get queryType;
  String get nullable;
  String get htmlType;
  String get selectDictType;
  String get example;
  String get templateType;
  String get templateTypeSingle;
  String get templateTypeTree;
  String get templateTypeMasterSub;
  String get frontType;
  String get frontTypeVue3;
  String get frontTypeVue2;
  String get scene;
  String get sceneAdmin;
  String get sceneApp;
  String get moduleName;
  String get moduleNameHelp;
  String get businessName;
  String get businessNameHelp;
  String get classComment;
  String get classCommentHelp;
  String get treeTableInfo;
  String get treeParentColumn;
  String get treeParentColumnHelp;
  String get treeNameColumn;
  String get treeNameColumnHelp;
  String get masterSubTableInfo;
  String get masterTable;
  String get masterTableHelp;
  String get subJoinColumn;
  String get subJoinColumnHelp;
  String get relationType;
  String get relationOneToOne;
  String get relationOneToMany;
  String get htmlTypeInput;
  String get htmlTypeTextarea;
  String get htmlTypeSelect;
  String get htmlTypeRadio;
  String get htmlTypeCheckbox;
  String get htmlTypeDatetime;
  String get htmlTypeImageUpload;
  String get htmlTypeFileUpload;
  String get htmlTypeEditor;
  String get pleaseSelectData;

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
  String get featureNotImplemented;
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

  // Redis 管理
  String get redisOverview;
  String get redisVersion;
  String get redisVersionLabel;
  String get redisMode;
  String get standalone;
  String get cluster;
  String get port;
  String get connectedClients;
  String get uptimeInDays;
  String get usedMemory;
  String get usedCpu;
  String get memoryConfig;
  String get aofEnabled;
  String get rdbLastBgsaveStatus;
  String get keyCount;
  String get networkIO;
  String get memoryUsage;
  String get commandStats;
  String get memoryConsumption;
  String get usedMemoryPeak;
  String get memFragmentationRatio;
  String get usedMemoryRss;
  String get totalSystemMemory;
  String get totalCommands;

  // 参数配置管理
  String get configId;
  String get configCategory;
  String get configName;
  String get configKey;
  String get configValue;
  String get configType;
  String get configList;
  String get addConfig;
  String get editConfig;
  String get confirmDeleteConfig;
  String get systemBuiltIn;

  // 数据源配置管理
  String get dataSourceConfigId;
  String get dataSourceConfigName;
  String get dataSourceUrl;
  String get dataSourceConfigList;
  String get addDataSourceConfig;
  String get editDataSourceConfig;
  String get confirmDeleteDataSourceConfig;
  String get cannotDeleteMainDataSource;

  // 文件管理
  String get fileManagement;
  String get fileList;
  String get fileName;
  String get filePath;
  String get fileSize;
  String get fileType;
  String get fileContent;
  String get uploadFile;
  String get confirmDeleteFile;
  String get copyUrl;
  String get copySuccess;
  String get copyFailed;
  String get clickOrDragToUpload;
  String get supportFileFormats;
  String get pleaseSelectFile;
  String get selectFileFailed;
  String get uploading;
  String get uploadSuccess;
  String get uploadFailed;

  // 文件配置管理
  String get fileConfigManagement;
  String get fileConfigList;
  String get addFileConfig;
  String get editFileConfig;
  String get confirmDeleteFileConfig;
  String get storage;
  String get masterConfig;
  String get setMasterConfig;
  String get confirmSetMasterConfig;
  String get testUploadSuccess;
  String get confirmOpenFile;
  String get visit;
  String get testFailed;
  String get test;

  // 存储配置
  String get basicInfo;
  String get storageConfig;
  String get commonConfig;
  String get basePath;
  String get hostAddress;
  String get hostPort;
  String get connectionMode;
  String get endpoint;
  String get bucket;
  String get pleaseEnterName;
  String get pleaseSelectStorage;
  String get pleaseEnterBasePath;
  String get pleaseEnterHost;
  String get pleaseEnterPort;
  String get pleaseEnterEndpoint;
  String get pleaseEnterBucket;
  String get pleaseEnterAccessKey;
  String get pleaseEnterAccessSecret;
  String get pleaseEnterDomain;
  String get pathStyle;
  String get publicAccess;
  String get public;
  String get private;
  String get region;
  String get regionHint;
  String get customDomain;

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

  // Infra 模块 - 监控相关
  @override
  String get infra => _get('infra', 'Infrastructure');
  @override
  String get serverMonitor => _get('serverMonitor', 'Server Monitor');
  @override
  String get serverMonitorDesc => _get('serverMonitorDesc', 'Spring Boot Admin monitoring console');
  @override
  String get apiDocs => _get('apiDocs', 'API Documentation');
  @override
  String get apiDocsDesc => _get('apiDocsDesc', 'Swagger/Knife4j API documentation');
  @override
  String get druidMonitor => _get('druidMonitor', 'Druid Monitor');
  @override
  String get druidMonitorDesc => _get('druidMonitorDesc', 'Database connection pool monitoring');
  @override
  String get skywalkingMonitor => _get('skywalkingMonitor', 'Skywalking Monitor');
  @override
  String get skywalkingMonitorDesc => _get('skywalkingMonitorDesc', 'Distributed tracing and monitoring');
  @override
  String get webSocketMonitor => _get('webSocketMonitor', 'WebSocket Monitor');
  @override
  String get formDesigner => _get('formDesigner', 'Form Designer');

  // Infra 模块 - WebSocket
  @override
  String get connectionManagement => _get('connectionManagement', 'Connection Management');
  @override
  String get connectionStatus => _get('connectionStatus', 'Connection Status');
  @override
  String get connected => _get('connected', 'Connected');
  @override
  String get disconnected => _get('disconnected', 'Disconnected');
  @override
  String get connect => _get('connect', 'Connect');
  @override
  String get disconnect => _get('disconnect', 'Disconnect');
  @override
  String get connecting => _get('connecting', 'Connecting...');
  @override
  String get serverAddress => _get('serverAddress', 'Server Address');
  @override
  String get sendMessage => _get('sendMessage', 'Send Message');
  @override
  String get selectReceiver => _get('selectReceiver', 'Select Receiver');
  @override
  String get everyone => _get('everyone', 'Everyone');
  @override
  String get messageHistory => _get('messageHistory', 'Message History');
  @override
  String get messagesCount => _get('messagesCount', 'messages');
  @override
  String get messageCannotBeEmpty => _get('messageCannotBeEmpty', 'Message cannot be empty');
  @override
  String get pleaseConnectFirst => _get('pleaseConnectFirst', 'Please connect first');
  @override
  String get groupMessage => _get('groupMessage', 'Group Message');
  @override
  String get singleMessage => _get('singleMessage', 'Direct Message');
  @override
  String get systemMessage => _get('systemMessage', 'System Message');
  @override
  String get copiedToClipboard => _get('copiedToClipboard', 'Copied to clipboard');

  // Infra 模块 - 表单设计器
  @override
  String get componentLibrary => _get('componentLibrary', 'Component Library');
  @override
  String get dragComponentHere => _get('dragComponentHere', 'Drag components here');
  @override
  String get selectFieldToConfig => _get('selectFieldToConfig', 'Select a field to configure');
  @override
  String get fieldProperties => _get('fieldProperties', 'Field Properties');
  @override
  String get fieldName => _get('fieldName', 'Field Name');
  @override
  String get label => _get('label', 'Label');
  @override
  String get placeholder => _get('placeholder', 'Placeholder');
  @override
  String get defaultValue => _get('defaultValue', 'Default Value');
  @override
  String get required => _get('required', 'Required');
  @override
  String get preview => _get('preview', 'Preview');
  @override
  String get clear => _get('clear', 'Clear');

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
  @override
  String get assignMenuPermission => _get('assignMenuPermission', 'Assign Menu Permission');
  @override
  String get assignDataPermission => _get('assignDataPermission', 'Assign Data Permission');
  @override
  String get dataScope => _get('dataScope', 'Data Scope');
  @override
  String get dataScopeAll => _get('dataScopeAll', 'All Data');
  @override
  String get dataScopeCustom => _get('dataScopeCustom', 'Custom Department');
  @override
  String get dataScopeDeptOnly => _get('dataScopeDeptOnly', 'Department Only');
  @override
  String get dataScopeDeptBelow => _get('dataScopeDeptBelow', 'Department and Below');
  @override
  String get dataScopeSelfOnly => _get('dataScopeSelfOnly', 'Self Only');
  @override
  String get customDeptHint => _get('customDeptHint', 'Department selection is only available for custom department scope');

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

  // 定时任务管理
  @override
  String get jobId => _get('jobId', 'Job ID');
  @override
  String get jobName => _get('jobName', 'Job Name');
  @override
  String get jobList => _get('jobList', 'Job List');
  @override
  String get addJob => _get('addJob', 'Add Job');
  @override
  String get editJob => _get('editJob', 'Edit Job');
  @override
  String get jobDetail => _get('jobDetail', 'Job Detail');
  @override
  String get confirmDeleteJob => _get('confirmDeleteJob', 'Are you sure to delete this job?');
  @override
  String get handlerName => _get('handlerName', 'Handler Name');
  @override
  String get handlerParam => _get('handlerParam', 'Handler Param');
  @override
  String get handlerNamePlaceholder => _get('handlerNamePlaceholder', 'Please enter handler name');
  @override
  String get cronExpression => _get('cronExpression', 'CRON Expression');
  @override
  String get cronExpressionPlaceholder => _get('cronExpressionPlaceholder', 'Please enter CRON expression');
  @override
  String get retryCount => _get('retryCount', 'Retry Count');
  @override
  String get retryCountPlaceholder => _get('retryCountPlaceholder', 'Set to 0 for no retry');
  @override
  String get retryInterval => _get('retryInterval', 'Retry Interval');
  @override
  String get retryIntervalPlaceholder => _get('retryIntervalPlaceholder', 'Retry interval in milliseconds, 0 for no interval');
  @override
  String get monitorTimeout => _get('monitorTimeout', 'Monitor Timeout');
  @override
  String get monitorTimeoutPlaceholder => _get('monitorTimeoutPlaceholder', 'Monitor timeout in milliseconds');
  @override
  String get nextExecuteTime => _get('nextExecuteTime', 'Next Execute Time');
  @override
  String get noNextExecuteTime => _get('noNextExecuteTime', 'No next execute time');
  @override
  String get jobStatusNormal => _get('jobStatusNormal', 'Normal');
  @override
  String get jobStatusStop => _get('jobStatusStop', 'Stopped');
  @override
  String get jobStart => _get('jobStart', 'Start');
  @override
  String get jobPause => _get('jobPause', 'Pause');
  @override
  String get jobExecute => _get('jobExecute', 'Execute');
  @override
  String get jobLog => _get('jobLog', 'Job Log');
  @override
  String get milliseconds => _get('milliseconds', 'ms');
  @override
  String get notEnabled => _get('notEnabled', 'Not Enabled');

  // 任务日志管理
  @override
  String get logId => _get('logId', 'Log ID');
  @override
  String get jobLogList => _get('jobLogList', 'Job Log List');
  @override
  String get jobLogDetail => _get('jobLogDetail', 'Job Log Detail');
  @override
  String get executeIndex => _get('executeIndex', 'Execute Index');
  @override
  String get executeTime => _get('executeTime', 'Execute Time');
  @override
  String get jobLogStatusSuccess => _get('jobLogStatusSuccess', 'Success');
  @override
  String get jobLogStatusFailure => _get('jobLogStatusFailure', 'Failure');
  @override
  String get result => _get('result', 'Result');

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
  String get viewDictData => _get('viewDictData', 'View Dict Data');
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
  String get featureNotImplemented => _get('featureNotImplemented', 'Feature not implemented');
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

  // 代码生成
  @override
  String get codegenList => _get('codegenList', 'Code Generation List');
  @override
  String get importTable => _get('importTable', 'Import Table');
  @override
  String get preview => _get('preview', 'Preview');
  @override
  String get generateCode => _get('generateCode', 'Generate Code');
  @override
  String get sync => _get('sync', 'Sync');
  @override
  String get syncSuccess => _get('syncSuccess', 'Sync Success');
  @override
  String get syncFailed => _get('syncFailed', 'Sync Failed');
  @override
  String get confirmSync => _get('confirmSync', 'Confirm Sync');
  @override
  String get confirmSyncTable => _get('confirmSyncTable', 'Are you sure to sync table');
  @override
  String get generateSuccess => _get('generateSuccess', 'Generate Success');
  @override
  String get generateFailed => _get('generateFailed', 'Generate Failed');
  @override
  String get confirmDeleteTable => _get('confirmDeleteTable', 'Are you sure to delete table');
  @override
  String get confirmDeleteTables => _get('confirmDeleteTables', 'Are you sure to delete selected tables');
  @override
  String get confirmDeleteBatch => _get('confirmDeleteBatch', 'Confirm Batch Delete');
  @override
  String get tableName => _get('tableName', 'Table Name');
  @override
  String get tableComment => _get('tableComment', 'Table Comment');
  @override
  String get className => _get('className', 'Class Name');
  @override
  String get classNameHelp => _get('classNameHelp', 'Default prefix removed. If duplicate, add prefix manually.');
  @override
  String get classNameHelp2 => _get('classNameHelp2', 'Class name (capitalized), e.g. SysUser, SysMenu');
  @override
  String get author => _get('author', 'Author');
  @override
  String get dataSource => _get('dataSource', 'Data Source');
  @override
  String get pleaseSelectDataSource => _get('pleaseSelectDataSource', 'Please select data source');
  @override
  String get pleaseSelectTable => _get('pleaseSelectTable', 'Please select table');
  @override
  String get importSuccess => _get('importSuccess', 'Import Success');
  @override
  String get importFailed => _get('importFailed', 'Import Failed');
  @override
  String get codePreview => _get('codePreview', 'Code Preview');
  @override
  String get pleaseSelectFile => _get('pleaseSelectFile', 'Please select a file');
  @override
  String get copySuccess => _get('copySuccess', 'Copy Success');
  @override
  String get editCodegen => _get('editCodegen', 'Edit Code Generation');
  @override
  String get basicInfo => _get('basicInfo', 'Basic Info');
  @override
  String get columnInfo => _get('columnInfo', 'Column Info');
  @override
  String get generationInfo => _get('generationInfo', 'Generation Info');
  @override
  String get prevStep => _get('prevStep', 'Previous');
  @override
  String get nextStep => _get('nextStep', 'Next');
  @override
  String get columnName => _get('columnName', 'Column Name');
  @override
  String get columnComment => _get('columnComment', 'Column Comment');
  @override
  String get dataType => _get('dataType', 'Data Type');
  @override
  String get javaType => _get('javaType', 'Java Type');
  @override
  String get javaField => _get('javaField', 'Java Field');
  @override
  String get insert => _get('insert', 'Insert');
  @override
  String get query => _get('query', 'Query');
  @override
  String get queryType => _get('queryType', 'Query Type');
  @override
  String get nullable => _get('nullable', 'Nullable');
  @override
  String get htmlType => _get('htmlType', 'HTML Type');
  @override
  String get selectDictType => _get('selectDictType', 'Select Dict Type');
  @override
  String get example => _get('example', 'Example');
  @override
  String get templateType => _get('templateType', 'Template Type');
  @override
  String get templateTypeSingle => _get('templateTypeSingle', 'Single Table');
  @override
  String get templateTypeTree => _get('templateTypeTree', 'Tree Table');
  @override
  String get templateTypeMasterSub => _get('templateTypeMasterSub', 'Master-Sub Table');
  @override
  String get frontType => _get('frontType', 'Frontend Type');
  @override
  String get frontTypeVue3 => _get('frontTypeVue3', 'Vue3');
  @override
  String get frontTypeVue2 => _get('frontTypeVue2', 'Vue2');
  @override
  String get scene => _get('scene', 'Scene');
  @override
  String get sceneAdmin => _get('sceneAdmin', 'Admin');
  @override
  String get sceneApp => _get('sceneApp', 'App');
  @override
  String get moduleName => _get('moduleName', 'Module Name');
  @override
  String get moduleNameHelp => _get('moduleNameHelp', 'Module name, e.g. system, infra, tool');
  @override
  String get businessName => _get('businessName', 'Business Name');
  @override
  String get businessNameHelp => _get('businessNameHelp', 'Business name, e.g. user, permission, dict');
  @override
  String get classComment => _get('classComment', 'Class Comment');
  @override
  String get classCommentHelp => _get('classCommentHelp', 'Class description, e.g. User');
  @override
  String get treeTableInfo => _get('treeTableInfo', 'Tree Table Info');
  @override
  String get treeParentColumn => _get('treeParentColumn', 'Parent Column');
  @override
  String get treeParentColumnHelp => _get('treeParentColumnHelp', 'Parent column for tree, e.g. parent_id');
  @override
  String get treeNameColumn => _get('treeNameColumn', 'Name Column');
  @override
  String get treeNameColumnHelp => _get('treeNameColumnHelp', 'Tree node name field, usually name');
  @override
  String get masterSubTableInfo => _get('masterSubTableInfo', 'Master-Sub Table Info');
  @override
  String get masterTable => _get('masterTable', 'Master Table');
  @override
  String get masterTableHelp => _get('masterTableHelp', 'Master table name, e.g. system_user');
  @override
  String get subJoinColumn => _get('subJoinColumn', 'Sub Join Column');
  @override
  String get subJoinColumnHelp => _get('subJoinColumnHelp', 'Sub table join column, e.g. user_id');
  @override
  String get relationType => _get('relationType', 'Relation Type');
  @override
  String get relationOneToOne => _get('relationOneToOne', 'One-to-One');
  @override
  String get relationOneToMany => _get('relationOneToMany', 'One-to-Many');
  @override
  String get htmlTypeInput => _get('htmlTypeInput', 'Input');
  @override
  String get htmlTypeTextarea => _get('htmlTypeTextarea', 'Textarea');
  @override
  String get htmlTypeSelect => _get('htmlTypeSelect', 'Select');
  @override
  String get htmlTypeRadio => _get('htmlTypeRadio', 'Radio');
  @override
  String get htmlTypeCheckbox => _get('htmlTypeCheckbox', 'Checkbox');
  @override
  String get htmlTypeDatetime => _get('htmlTypeDatetime', 'Datetime');
  @override
  String get htmlTypeImageUpload => _get('htmlTypeImageUpload', 'Image Upload');
  @override
  String get htmlTypeFileUpload => _get('htmlTypeFileUpload', 'File Upload');
  @override
  String get htmlTypeEditor => _get('htmlTypeEditor', 'Editor');
  @override
  String get pleaseSelectData => _get('pleaseSelectData', 'Please select data');

  // Redis 管理
  @override
  String get redisOverview => _get('redisOverview', 'Redis Overview');
  @override
  String get redisVersion => _get('redisVersion', 'Redis Version: %s');
  @override
  String get redisVersionLabel => _get('redisVersionLabel', 'Redis Version');
  @override
  String get redisMode => _get('redisMode', 'Redis Mode');
  @override
  String get standalone => _get('standalone', 'Standalone');
  @override
  String get cluster => _get('cluster', 'Cluster');
  @override
  String get port => _get('port', 'Port');
  @override
  String get connectedClients => _get('connectedClients', 'Connected Clients');
  @override
  String get uptimeInDays => _get('uptimeInDays', 'Uptime (days)');
  @override
  String get usedMemory => _get('usedMemory', 'Used Memory');
  @override
  String get usedCpu => _get('usedCpu', 'Used CPU');
  @override
  String get memoryConfig => _get('memoryConfig', 'Memory Config');
  @override
  String get aofEnabled => _get('aofEnabled', 'AOF Enabled');
  @override
  String get rdbLastBgsaveStatus => _get('rdbLastBgsaveStatus', 'RDB Status');
  @override
  String get keyCount => _get('keyCount', 'Key Count');
  @override
  String get networkIO => _get('networkIO', 'Network I/O');
  @override
  String get memoryUsage => _get('memoryUsage', 'Memory Usage');
  @override
  String get commandStats => _get('commandStats', 'Command Stats');
  @override
  String get memoryConsumption => _get('memoryConsumption', 'Memory Consumption');
  @override
  String get usedMemoryPeak => _get('usedMemoryPeak', 'Peak Memory');
  @override
  String get memFragmentationRatio => _get('memFragmentationRatio', 'Fragmentation Ratio');
  @override
  String get usedMemoryRss => _get('usedMemoryRss', 'RSS Memory');
  @override
  String get totalSystemMemory => _get('totalSystemMemory', 'Total System Memory');
  @override
  String get totalCommands => _get('totalCommands', 'Total Commands: %s');

  // 参数配置管理
  @override
  String get configId => _get('configId', 'Config ID');
  @override
  String get configCategory => _get('configCategory', 'Category');
  @override
  String get configName => _get('configName', 'Config Name');
  @override
  String get configKey => _get('configKey', 'Config Key');
  @override
  String get configValue => _get('configValue', 'Config Value');
  @override
  String get configType => _get('configType', 'Built-in');
  @override
  String get configList => _get('configList', 'Config List');
  @override
  String get addConfig => _get('addConfig', 'Add Config');
  @override
  String get editConfig => _get('editConfig', 'Edit Config');
  @override
  String get confirmDeleteConfig => _get('confirmDeleteConfig', 'Are you sure to delete this config?');
  @override
  String get systemBuiltIn => _get('systemBuiltIn', 'System Built-in');

  // 数据源配置管理
  @override
  String get dataSourceConfigId => _get('dataSourceConfigId', 'ID');
  @override
  String get dataSourceConfigName => _get('dataSourceConfigName', 'Data Source Name');
  @override
  String get dataSourceUrl => _get('dataSourceUrl', 'Data Source URL');
  @override
  String get dataSourceConfigList => _get('dataSourceConfigList', 'Data Source List');
  @override
  String get addDataSourceConfig => _get('addDataSourceConfig', 'Add Data Source');
  @override
  String get editDataSourceConfig => _get('editDataSourceConfig', 'Edit Data Source');
  @override
  String get confirmDeleteDataSourceConfig => _get('confirmDeleteDataSourceConfig', 'Are you sure to delete this data source?');
  @override
  String get cannotDeleteMainDataSource => _get('cannotDeleteMainDataSource', 'Main data source cannot be deleted');

  // 文件管理
  @override
  String get fileManagement => _get('fileManagement', 'File Management');
  @override
  String get fileList => _get('fileList', 'File List');
  @override
  String get fileName => _get('fileName', 'File Name');
  @override
  String get filePath => _get('filePath', 'File Path');
  @override
  String get fileSize => _get('fileSize', 'File Size');
  @override
  String get fileType => _get('fileType', 'File Type');
  @override
  String get fileContent => _get('fileContent', 'File Content');
  @override
  String get uploadFile => _get('uploadFile', 'Upload File');
  @override
  String get confirmDeleteFile => _get('confirmDeleteFile', 'Are you sure to delete this file?');
  @override
  String get copyUrl => _get('copyUrl', 'Copy URL');
  @override
  String get copySuccess => _get('copySuccess', 'Copy Success');
  @override
  String get copyFailed => _get('copyFailed', 'Copy Failed');
  @override
  String get clickOrDragToUpload => _get('clickOrDragToUpload', 'Click or drag files to this area to upload');
  @override
  String get supportFileFormats => _get('supportFileFormats', 'Support common image and document formats');
  @override
  String get pleaseSelectFile => _get('pleaseSelectFile', 'Please select a file');
  @override
  String get selectFileFailed => _get('selectFileFailed', 'Select file failed');
  @override
  String get uploading => _get('uploading', 'Uploading...');
  @override
  String get uploadSuccess => _get('uploadSuccess', 'Upload Success');
  @override
  String get uploadFailed => _get('uploadFailed', 'Upload Failed');

  // 文件配置管理
  @override
  String get fileConfigManagement => _get('fileConfigManagement', 'File Config Management');
  @override
  String get fileConfigList => _get('fileConfigList', 'File Config List');
  @override
  String get addFileConfig => _get('addFileConfig', 'Add File Config');
  @override
  String get editFileConfig => _get('editFileConfig', 'Edit File Config');
  @override
  String get confirmDeleteFileConfig => _get('confirmDeleteFileConfig', 'Are you sure to delete this file config?');
  @override
  String get storage => _get('storage', 'Storage');
  @override
  String get masterConfig => _get('masterConfig', 'Master Config');
  @override
  String get setMasterConfig => _get('setMasterConfig', 'Set as Master');
  @override
  String get confirmSetMasterConfig => _get('confirmSetMasterConfig', 'Are you sure to set this config as master?');
  @override
  String get testUploadSuccess => _get('testUploadSuccess', 'Test Upload Success');
  @override
  String get confirmOpenFile => _get('confirmOpenFile', 'Do you want to open the file?');
  @override
  String get visit => _get('visit', 'Visit');
  @override
  String get testFailed => _get('testFailed', 'Test Failed');
  @override
  String get test => _get('test', 'Test');

  // 存储配置
  @override
  String get basicInfo => _get('basicInfo', 'Basic Info');
  @override
  String get storageConfig => _get('storageConfig', 'Storage Config');
  @override
  String get commonConfig => _get('commonConfig', 'Common Config');
  @override
  String get basePath => _get('basePath', 'Base Path');
  @override
  String get hostAddress => _get('hostAddress', 'Host Address');
  @override
  String get hostPort => _get('hostPort', 'Host Port');
  @override
  String get connectionMode => _get('connectionMode', 'Connection Mode');
  @override
  String get endpoint => _get('endpoint', 'Endpoint');
  @override
  String get bucket => _get('bucket', 'Bucket');
  @override
  String get pleaseEnterName => _get('pleaseEnterName', 'Please enter name');
  @override
  String get pleaseSelectStorage => _get('pleaseSelectStorage', 'Please select storage');
  @override
  String get pleaseEnterBasePath => _get('pleaseEnterBasePath', 'Please enter base path');
  @override
  String get pleaseEnterHost => _get('pleaseEnterHost', 'Please enter host address');
  @override
  String get pleaseEnterPort => _get('pleaseEnterPort', 'Please enter port');
  @override
  String get pleaseEnterEndpoint => _get('pleaseEnterEndpoint', 'Please enter endpoint');
  @override
  String get pleaseEnterBucket => _get('pleaseEnterBucket', 'Please enter bucket');
  @override
  String get pleaseEnterAccessKey => _get('pleaseEnterAccessKey', 'Please enter Access Key');
  @override
  String get pleaseEnterAccessSecret => _get('pleaseEnterAccessSecret', 'Please enter Access Secret');
  @override
  String get pleaseEnterDomain => _get('pleaseEnterDomain', 'Please enter custom domain');
  @override
  String get pathStyle => _get('pathStyle', 'Path Style');
  @override
  String get publicAccess => _get('publicAccess', 'Public Access');
  @override
  String get public => _get('public', 'Public');
  @override
  String get private => _get('private', 'Private');
  @override
  String get region => _get('region', 'Region');
  @override
  String get regionHint => _get('regionHint', 'Enter region, usually only required for AWS');
  @override
  String get customDomain => _get('customDomain', 'Custom Domain');

  // 带参数的方法
  @override
  String cacl_common_totalCount(int count) {
    final template = _get('common_totalCount', 'Total: %s');
    return template.replaceAll('%s', count.toString());
  }
}



/// 全局访问点
S get s => S.current;