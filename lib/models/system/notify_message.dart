/// 站内信消息模型
class NotifyMessage {
  final int? id;
  final int? userId;
  final int? userType;
  final int? templateId;
  final String? templateCode;
  final String? templateNickname;
  final String? templateContent;
  final int? templateType;
  final String? templateParams;
  final bool? readStatus;
  final String? readTime;
  final String? createTime;

  const NotifyMessage({
    this.id,
    this.userId,
    this.userType,
    this.templateId,
    this.templateCode,
    this.templateNickname,
    this.templateContent,
    this.templateType,
    this.templateParams,
    this.readStatus,
    this.readTime,
    this.createTime,
  });

  factory NotifyMessage.fromJson(Map<String, dynamic> json) {
    return NotifyMessage(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      userType: json['userType'] as int?,
      templateId: json['templateId'] as int?,
      templateCode: json['templateCode'] as String?,
      templateNickname: json['templateNickname'] as String?,
      templateContent: json['templateContent'] as String?,
      templateType: json['templateType'] as int?,
      templateParams: json['templateParams'] as String?,
      readStatus: json['readStatus'] as bool?,
      readTime: json['readTime'] as String?,
      createTime: json['createTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      if (userType != null) 'userType': userType,
      if (templateId != null) 'templateId': templateId,
      if (templateCode != null) 'templateCode': templateCode,
      if (templateNickname != null) 'templateNickname': templateNickname,
      if (templateContent != null) 'templateContent': templateContent,
      if (templateType != null) 'templateType': templateType,
      if (templateParams != null) 'templateParams': templateParams,
      if (readStatus != null) 'readStatus': readStatus,
      if (readTime != null) 'readTime': readTime,
      if (createTime != null) 'createTime': createTime,
    };
  }
}