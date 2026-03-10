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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? ''),
      userType: json['userType'] is int ? json['userType'] : int.tryParse(json['userType']?.toString() ?? ''),
      toMails: (json['toMails'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      ccMails: (json['ccMails'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      bccMails: (json['bccMails'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      accountId: json['accountId'] is int ? json['accountId'] : int.tryParse(json['accountId']?.toString() ?? ''),
      fromMail: json['fromMail']?.toString(),
      templateId: json['templateId'] is int ? json['templateId'] : int.tryParse(json['templateId']?.toString() ?? ''),
      templateCode: json['templateCode']?.toString(),
      templateNickname: json['templateNickname']?.toString(),
      templateTitle: json['templateTitle']?.toString(),
      templateContent: json['templateContent']?.toString(),
      templateParams: json['templateParams']?.toString(),
      sendStatus: json['sendStatus'] is int ? json['sendStatus'] : int.tryParse(json['sendStatus']?.toString() ?? ''),
      sendTime: json['sendTime']?.toString(),
      sendMessageId: json['sendMessageId']?.toString(),
      sendException: json['sendException']?.toString(),
      createTime: json['createTime']?.toString(),
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