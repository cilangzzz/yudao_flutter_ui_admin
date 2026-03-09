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
      id: json['id'] as int?,
      traceId: json['traceId'] as String?,
      userType: json['userType'] as int?,
      userId: json['userId'] as int?,
      userName: json['userName'] as String?,
      type: json['type'] as String?,
      subType: json['subType'] as String?,
      bizId: json['bizId'] as int?,
      action: json['action'] as String?,
      extra: json['extra'] as String?,
      requestMethod: json['requestMethod'] as String?,
      requestUrl: json['requestUrl'] as String?,
      userIp: json['userIp'] as String?,
      userAgent: json['userAgent'] as String?,
      creator: json['creator'] as String?,
      creatorName: json['creatorName'] as String?,
      createTime: json['createTime'] as String?,
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