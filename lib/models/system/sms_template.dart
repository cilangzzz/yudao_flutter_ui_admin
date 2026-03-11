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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      type: json['type'] is int ? json['type'] : int.tryParse(json['type']?.toString() ?? ''),
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      remark: json['remark']?.toString(),
      apiTemplateId: json['apiTemplateId']?.toString(),
      channelId: json['channelId'] is int ? json['channelId'] : int.tryParse(json['channelId']?.toString() ?? ''),
      channelCode: json['channelCode']?.toString(),
      params: (json['params'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      createTime: json['createTime']?.toString(),
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