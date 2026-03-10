/// 站内信模板模型
class NotifyTemplate {
  final int? id;
  final String name;
  final String? nickname;
  final String code;
  final String? content;
  final int? type;
  final List<String>? params;
  final int? status;
  final String? remark;

  const NotifyTemplate({
    this.id,
    required this.name,
    this.nickname,
    required this.code,
    this.content,
    this.type,
    this.params,
    this.status,
    this.remark,
  });

  factory NotifyTemplate.fromJson(Map<String, dynamic> json) {
    return NotifyTemplate(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      nickname: json['nickname']?.toString(),
      code: json['code']?.toString() ?? '',
      content: json['content']?.toString(),
      type: json['type'] is int ? json['type'] : int.tryParse(json['type']?.toString() ?? ''),
      params: (json['params'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? ''),
      remark: json['remark']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (nickname != null) 'nickname': nickname,
      'code': code,
      if (content != null) 'content': content,
      if (type != null) 'type': type,
      if (params != null) 'params': params,
      if (status != null) 'status': status,
      if (remark != null) 'remark': remark,
    };
  }
}

/// 发送站内信请求
class NotifySendReq {
  final int userId;
  final int userType;
  final String templateCode;
  final Map<String, dynamic> templateParams;

  const NotifySendReq({
    required this.userId,
    required this.userType,
    required this.templateCode,
    this.templateParams = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userType': userType,
      'templateCode': templateCode,
      'templateParams': templateParams,
    };
  }
}