/// 邮件模版模型
class MailTemplate {
  final int? id;
  final String name;
  final String code;
  final int accountId;
  final String? nickname;
  final String title;
  final String content;
  final List<String> params;
  final int status;
  final String? createTime;

  MailTemplate({
    this.id,
    required this.name,
    required this.code,
    required this.accountId,
    this.nickname,
    required this.title,
    required this.content,
    this.params = const [],
    this.status = 0,
    this.createTime,
  });

  factory MailTemplate.fromJson(Map<String, dynamic> json) {
    return MailTemplate(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      accountId: json['accountId'] as int? ?? 0,
      nickname: json['nickname'] as String?,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      params: (json['params'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      status: json['status'] as int? ?? 0,
      createTime: json['createTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'code': code,
      'accountId': accountId,
      if (nickname != null) 'nickname': nickname,
      'title': title,
      'content': content,
      'params': params,
      'status': status,
      if (createTime != null) 'createTime': createTime,
    };
  }
}

/// 邮件发送请求
class MailSendReqVO {
  final List<String> toMails;
  final List<String>? ccMails;
  final List<String>? bccMails;
  final String templateCode;
  final Map<String, dynamic> templateParams;

  MailSendReqVO({
    required this.toMails,
    this.ccMails,
    this.bccMails,
    required this.templateCode,
    this.templateParams = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'toMails': toMails,
      if (ccMails != null) 'ccMails': ccMails,
      if (bccMails != null) 'bccMails': bccMails,
      'templateCode': templateCode,
      'templateParams': templateParams,
    };
  }
}