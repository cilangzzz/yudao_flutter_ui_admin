/// 短信日志模型
class SmsLog {
  final int? id;
  final int? channelId;
  final String? channelCode;
  final int? templateId;
  final String? templateCode;
  final int? templateType;
  final String? templateContent;
  final Map<String, dynamic>? templateParams;
  final String? apiTemplateId;
  final String? mobile;
  final int? userId;
  final int? userType;
  final int? sendStatus;
  final String? sendTime;
  final String? apiSendCode;
  final String? apiSendMsg;
  final String? apiRequestId;
  final String? apiSerialNo;
  final int? receiveStatus;
  final String? receiveTime;
  final String? apiReceiveCode;
  final String? apiReceiveMsg;
  final String? createTime;

  SmsLog({
    this.id,
    this.channelId,
    this.channelCode,
    this.templateId,
    this.templateCode,
    this.templateType,
    this.templateContent,
    this.templateParams,
    this.apiTemplateId,
    this.mobile,
    this.userId,
    this.userType,
    this.sendStatus,
    this.sendTime,
    this.apiSendCode,
    this.apiSendMsg,
    this.apiRequestId,
    this.apiSerialNo,
    this.receiveStatus,
    this.receiveTime,
    this.apiReceiveCode,
    this.apiReceiveMsg,
    this.createTime,
  });

  factory SmsLog.fromJson(Map<String, dynamic> json) {
    return SmsLog(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      channelId: json['channelId'] is int ? json['channelId'] : int.tryParse(json['channelId']?.toString() ?? ''),
      channelCode: json['channelCode']?.toString(),
      templateId: json['templateId'] is int ? json['templateId'] : int.tryParse(json['templateId']?.toString() ?? ''),
      templateCode: json['templateCode']?.toString(),
      templateType: json['templateType'] is int ? json['templateType'] : int.tryParse(json['templateType']?.toString() ?? ''),
      templateContent: json['templateContent']?.toString(),
      templateParams: json['templateParams'] as Map<String, dynamic>?,
      apiTemplateId: json['apiTemplateId']?.toString(),
      mobile: json['mobile']?.toString(),
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? ''),
      userType: json['userType'] is int ? json['userType'] : int.tryParse(json['userType']?.toString() ?? ''),
      sendStatus: json['sendStatus'] is int ? json['sendStatus'] : int.tryParse(json['sendStatus']?.toString() ?? ''),
      sendTime: json['sendTime']?.toString(),
      apiSendCode: json['apiSendCode']?.toString(),
      apiSendMsg: json['apiSendMsg']?.toString(),
      apiRequestId: json['apiRequestId']?.toString(),
      apiSerialNo: json['apiSerialNo']?.toString(),
      receiveStatus: json['receiveStatus'] is int ? json['receiveStatus'] : int.tryParse(json['receiveStatus']?.toString() ?? ''),
      receiveTime: json['receiveTime']?.toString(),
      apiReceiveCode: json['apiReceiveCode']?.toString(),
      apiReceiveMsg: json['apiReceiveMsg']?.toString(),
      createTime: json['createTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (channelId != null) 'channelId': channelId,
      if (channelCode != null) 'channelCode': channelCode,
      if (templateId != null) 'templateId': templateId,
      if (templateCode != null) 'templateCode': templateCode,
      if (templateType != null) 'templateType': templateType,
      if (templateContent != null) 'templateContent': templateContent,
      if (templateParams != null) 'templateParams': templateParams,
      if (apiTemplateId != null) 'apiTemplateId': apiTemplateId,
      if (mobile != null) 'mobile': mobile,
      if (userId != null) 'userId': userId,
      if (userType != null) 'userType': userType,
      if (sendStatus != null) 'sendStatus': sendStatus,
      if (sendTime != null) 'sendTime': sendTime,
      if (apiSendCode != null) 'apiSendCode': apiSendCode,
      if (apiSendMsg != null) 'apiSendMsg': apiSendMsg,
      if (apiRequestId != null) 'apiRequestId': apiRequestId,
      if (apiSerialNo != null) 'apiSerialNo': apiSerialNo,
      if (receiveStatus != null) 'receiveStatus': receiveStatus,
      if (receiveTime != null) 'receiveTime': receiveTime,
      if (apiReceiveCode != null) 'apiReceiveCode': apiReceiveCode,
      if (apiReceiveMsg != null) 'apiReceiveMsg': apiReceiveMsg,
      if (createTime != null) 'createTime': createTime,
    };
  }
}