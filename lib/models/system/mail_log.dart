/// 邮件日志模型
class MailLog {
  final int? id;
  final int? userId;
  final int? userType;
  final List<String> toMails;
  final List<String>? ccMails;
  final List<String>? bccMails;
  final int? accountId;
  final String? fromMail;
  final int? templateId;
  final String? templateCode;
  final String? templateNickname;
  final String? templateTitle;
  final String? templateContent;
  final String? templateParams;
  final int? sendStatus;
  final String? sendTime;
  final String? sendMessageId;
  final String? sendException;
  final String? createTime;

  MailLog({
    this.id,
    this.userId,
    this.userType,
    this.toMails = const [],
    this.ccMails,
    this.bccMails,
    this.accountId,
    this.fromMail,
    this.templateId,
    this.templateCode,
    this.templateNickname,
    this.templateTitle,
    this.templateContent,
    this.templateParams,
    this.sendStatus,
    this.sendTime,
    this.sendMessageId,
    this.sendException,
    this.createTime,
  });

  factory MailLog.fromJson(Map<String, dynamic> json) {
    return MailLog(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      userType: json['userType'] as int?,
      toMails: (json['toMails'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      ccMails: (json['ccMails'] as List<dynamic>?)?.map((e) => e as String).toList(),
      bccMails: (json['bccMails'] as List<dynamic>?)?.map((e) => e as String).toList(),
      accountId: json['accountId'] as int?,
      fromMail: json['fromMail'] as String?,
      templateId: json['templateId'] as int?,
      templateCode: json['templateCode'] as String?,
      templateNickname: json['templateNickname'] as String?,
      templateTitle: json['templateTitle'] as String?,
      templateContent: json['templateContent'] as String?,
      templateParams: json['templateParams'] as String?,
      sendStatus: json['sendStatus'] as int?,
      sendTime: json['sendTime'] as String?,
      sendMessageId: json['sendMessageId'] as String?,
      sendException: json['sendException'] as String?,
      createTime: json['createTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      if (userType != null) 'userType': userType,
      'toMails': toMails,
      if (ccMails != null) 'ccMails': ccMails,
      if (bccMails != null) 'bccMails': bccMails,
      if (accountId != null) 'accountId': accountId,
      if (fromMail != null) 'fromMail': fromMail,
      if (templateId != null) 'templateId': templateId,
      if (templateCode != null) 'templateCode': templateCode,
      if (templateNickname != null) 'templateNickname': templateNickname,
      if (templateTitle != null) 'templateTitle': templateTitle,
      if (templateContent != null) 'templateContent': templateContent,
      if (templateParams != null) 'templateParams': templateParams,
      if (sendStatus != null) 'sendStatus': sendStatus,
      if (sendTime != null) 'sendTime': sendTime,
      if (sendMessageId != null) 'sendMessageId': sendMessageId,
      if (sendException != null) 'sendException': sendException,
      if (createTime != null) 'createTime': createTime,
    };
  }
}