/// 操作日志模型
class OperateLog {
  final int? id;
  final String? traceId;
  final int? userType;
  final int? userId;
  final String? userName;
  final String? type;
  final String? subType;
  final int? bizId;
  final String? action;
  final String? extra;
  final String? requestMethod;
  final String? requestUrl;
  final String? userIp;
  final String? userAgent;
  final String? creator;
  final String? creatorName;
  final String? createTime;

  OperateLog({
    this.id,
    this.traceId,
    this.userType,
    this.userId,
    this.userName,
    this.type,
    this.subType,
    this.bizId,
    this.action,
    this.extra,
    this.requestMethod,
    this.requestUrl,
    this.userIp,
    this.userAgent,
    this.creator,
    this.creatorName,
    this.createTime,
  });

  factory OperateLog.fromJson(Map<String, dynamic> json) {
    return OperateLog(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      traceId: json['traceId']?.toString(),
      userType: json['userType'] is int ? json['userType'] : int.tryParse(json['userType']?.toString() ?? ''),
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? ''),
      userName: json['userName']?.toString(),
      type: json['type']?.toString(),
      subType: json['subType']?.toString(),
      bizId: json['bizId'] is int ? json['bizId'] : int.tryParse(json['bizId']?.toString() ?? ''),
      action: json['action']?.toString(),
      extra: json['extra']?.toString(),
      requestMethod: json['requestMethod']?.toString(),
      requestUrl: json['requestUrl']?.toString(),
      userIp: json['userIp']?.toString(),
      userAgent: json['userAgent']?.toString(),
      creator: json['creator']?.toString(),
      creatorName: json['creatorName']?.toString(),
      createTime: json['createTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (traceId != null) 'traceId': traceId,
      if (userType != null) 'userType': userType,
      if (userId != null) 'userId': userId,
      if (userName != null) 'userName': userName,
      if (type != null) 'type': type,
      if (subType != null) 'subType': subType,
      if (bizId != null) 'bizId': bizId,
      if (action != null) 'action': action,
      if (extra != null) 'extra': extra,
      if (requestMethod != null) 'requestMethod': requestMethod,
      if (requestUrl != null) 'requestUrl': requestUrl,
      if (userIp != null) 'userIp': userIp,
      if (userAgent != null) 'userAgent': userAgent,
      if (creator != null) 'creator': creator,
      if (creatorName != null) 'creatorName': creatorName,
      if (createTime != null) 'createTime': createTime,
    };
  }
}