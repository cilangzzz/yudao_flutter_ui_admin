/// 短信模板模型
class SmsTemplate {
  final int? id;
  final int? type;
  final int status;
  final String code;
  final String name;
  final String content;
  final String? remark;
  final String? apiTemplateId;
  final int? channelId;
  final String? channelCode;
  final List<String>? params;
  final String? createTime;

  SmsTemplate({
    this.id,
    this.type,
    this.status = 0,
    required this.code,
    required this.name,
    required this.content,
    this.remark,
    this.apiTemplateId,
    this.channelId,
    this.channelCode,
    this.params,
    this.createTime,
  });

  factory SmsTemplate.fromJson(Map<String, dynamic> json) {
    return SmsTemplate(
      id: json['id'] as int?,
      type: json['type'] as int?,
      status: json['status'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      content: json['content'] as String? ?? '',
      remark: json['remark'] as String?,
      apiTemplateId: json['apiTemplateId'] as String?,
      channelId: json['channelId'] as int?,
      channelCode: json['channelCode'] as String?,
      params: (json['params'] as List<dynamic>?)?.map((e) => e as String).toList(),
      createTime: json['createTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      'status': status,
      'code': code,
      'name': name,
      'content': content,
      if (remark != null) 'remark': remark,
      if (apiTemplateId != null) 'apiTemplateId': apiTemplateId,
      if (channelId != null) 'channelId': channelId,
      if (channelCode != null) 'channelCode': channelCode,
      if (params != null) 'params': params,
    };
  }
}

/// 发送短信请求
class SmsSendReqVO {
  final String mobile;
  final String templateCode;
  final Map<String, dynamic> templateParams;

  SmsSendReqVO({
    required this.mobile,
    required this.templateCode,
    this.templateParams = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
      'templateCode': templateCode,
      'templateParams': templateParams,
    };
  }
}