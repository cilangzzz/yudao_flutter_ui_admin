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
      id: json['id'] as int?,
      channelId: json['channelId'] as int?,
      channelCode: json['channelCode'] as String?,
      templateId: json['templateId'] as int?,
      templateCode: json['templateCode'] as String?,
      templateType: json['templateType'] as int?,
      templateContent: json['templateContent'] as String?,
      templateParams: json['templateParams'] as Map<String, dynamic>?,
      apiTemplateId: json['apiTemplateId'] as String?,
      mobile: json['mobile'] as String?,
      userId: json['userId'] as int?,
      userType: json['userType'] as int?,
      sendStatus: json['sendStatus'] as int?,
      sendTime: json['sendTime'] as String?,
      apiSendCode: json['apiSendCode'] as String?,
      apiSendMsg: json['apiSendMsg'] as String?,
      apiRequestId: json['apiRequestId'] as String?,
      apiSerialNo: json['apiSerialNo'] as String?,
      receiveStatus: json['receiveStatus'] as int?,
      receiveTime: json['receiveTime'] as String?,
      apiReceiveCode: json['apiReceiveCode'] as String?,
      apiReceiveMsg: json['apiReceiveMsg'] as String?,
      createTime: json['createTime'] as String?,
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