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
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      nickname: json['nickname'] as String?,
      code: json['code'] as String? ?? '',
      content: json['content'] as String?,
      type: json['type'] as int?,
      params: (json['params'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      status: json['status'] as int?,
      remark: json['remark'] as String?,
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