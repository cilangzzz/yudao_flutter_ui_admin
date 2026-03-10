/// 登录日志模型
class LoginLog {
  final int? id;
  final int? logType;
  final int? traceId;
  final int? userId;
  final int? userType;
  final String? username;
  final int? result;
  final int? status;
  final String? userIp;
  final String? userAgent;
  final String? createTime;

  LoginLog({
    this.id,
    this.logType,
    this.traceId,
    this.userId,
    this.userType,
    this.username,
    this.result,
    this.status,
    this.userIp,
    this.userAgent,
    this.createTime,
  });

  factory LoginLog.fromJson(Map<String, dynamic> json) {
    return LoginLog(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      logType: json['logType'] is int ? json['logType'] : int.tryParse(json['logType']?.toString() ?? ''),
      traceId: json['traceId'] is int ? json['traceId'] : int.tryParse(json['traceId']?.toString() ?? ''),
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? ''),
      userType: json['userType'] is int ? json['userType'] : int.tryParse(json['userType']?.toString() ?? ''),
      username: json['username']?.toString(),
      result: json['result'] is int ? json['result'] : int.tryParse(json['result']?.toString() ?? ''),
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? ''),
      userIp: json['userIp']?.toString(),
      userAgent: json['userAgent']?.toString(),
      createTime: json['createTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (logType != null) 'logType': logType,
      if (traceId != null) 'traceId': traceId,
      if (userId != null) 'userId': userId,
      if (userType != null) 'userType': userType,
      if (username != null) 'username': username,
      if (result != null) 'result': result,
      if (status != null) 'status': status,
      if (userIp != null) 'userIp': userIp,
      if (userAgent != null) 'userAgent': userAgent,
      if (createTime != null) 'createTime': createTime,
    };
  }
}