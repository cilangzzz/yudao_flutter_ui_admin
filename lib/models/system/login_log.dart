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
      id: json['id'] as int?,
      logType: json['logType'] as int?,
      traceId: json['traceId'] as int?,
      userId: json['userId'] as int?,
      userType: json['userType'] as int?,
      username: json['username'] as String?,
      result: json['result'] as int?,
      status: json['status'] as int?,
      userIp: json['userIp'] as String?,
      userAgent: json['userAgent'] as String?,
      createTime: json['createTime'] as String?,
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