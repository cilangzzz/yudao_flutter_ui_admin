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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? ''),
      userType: json['userType'] is int ? json['userType'] : int.tryParse(json['userType']?.toString() ?? ''),
      templateId: json['templateId'] is int ? json['templateId'] : int.tryParse(json['templateId']?.toString() ?? ''),
      templateCode: json['templateCode']?.toString(),
      templateNickname: json['templateNickname']?.toString(),
      templateContent: json['templateContent']?.toString(),
      templateType: json['templateType'] is int ? json['templateType'] : int.tryParse(json['templateType']?.toString() ?? ''),
      templateParams: json['templateParams']?.toString(),
      readStatus: json['readStatus'] is bool ? json['readStatus'] : bool.tryParse(json['readStatus']?.toString() ?? ''),
      readTime: json['readTime']?.toString(),
      createTime: json['createTime']?.toString(),
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