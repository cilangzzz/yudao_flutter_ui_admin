/// API 错误日志模型
class ApiErrorLog {
  final int? id;
  final String? traceId;
  final int? userId;
  final int? userType;
  final String? applicationName;
  final String? requestMethod;
  final String? requestParams;
  final String? requestUrl;
  final String? userIp;
  final String? userAgent;
  final String? exceptionTime;
  final String? exceptionName;
  final String? exceptionMessage;
  final String? exceptionRootCauseMessage;
  final String? exceptionStackTrace;
  final String? exceptionClassName;
  final String? exceptionFileName;
  final String? exceptionMethodName;
  final int? exceptionLineNumber;
  final int? processUserId;
  final int? processStatus;
  final String? processTime;
  final int? resultCode;
  final String? createTime;

  ApiErrorLog({
    this.id,
    this.traceId,
    this.userId,
    this.userType,
    this.applicationName,
    this.requestMethod,
    this.requestParams,
    this.requestUrl,
    this.userIp,
    this.userAgent,
    this.exceptionTime,
    this.exceptionName,
    this.exceptionMessage,
    this.exceptionRootCauseMessage,
    this.exceptionStackTrace,
    this.exceptionClassName,
    this.exceptionFileName,
    this.exceptionMethodName,
    this.exceptionLineNumber,
    this.processUserId,
    this.processStatus,
    this.processTime,
    this.resultCode,
    this.createTime,
  });

  factory ApiErrorLog.fromJson(Map<String, dynamic> json) {
    return ApiErrorLog(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      traceId: json['traceId']?.toString(),
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? ''),
      userType: json['userType'] is int ? json['userType'] : int.tryParse(json['userType']?.toString() ?? ''),
      applicationName: json['applicationName']?.toString(),
      requestMethod: json['requestMethod']?.toString(),
      requestParams: json['requestParams']?.toString(),
      requestUrl: json['requestUrl']?.toString(),
      userIp: json['userIp']?.toString(),
      userAgent: json['userAgent']?.toString(),
      exceptionTime: json['exceptionTime']?.toString(),
      exceptionName: json['exceptionName']?.toString(),
      exceptionMessage: json['exceptionMessage']?.toString(),
      exceptionRootCauseMessage: json['exceptionRootCauseMessage']?.toString(),
      exceptionStackTrace: json['exceptionStackTrace']?.toString(),
      exceptionClassName: json['exceptionClassName']?.toString(),
      exceptionFileName: json['exceptionFileName']?.toString(),
      exceptionMethodName: json['exceptionMethodName']?.toString(),
      exceptionLineNumber: json['exceptionLineNumber'] is int ? json['exceptionLineNumber'] : int.tryParse(json['exceptionLineNumber']?.toString() ?? ''),
      processUserId: json['processUserId'] is int ? json['processUserId'] : int.tryParse(json['processUserId']?.toString() ?? ''),
      processStatus: json['processStatus'] is int ? json['processStatus'] : int.tryParse(json['processStatus']?.toString() ?? ''),
      processTime: json['processTime']?.toString(),
      resultCode: json['resultCode'] is int ? json['resultCode'] : int.tryParse(json['resultCode']?.toString() ?? ''),
      createTime: json['createTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (traceId != null) 'traceId': traceId,
      if (userId != null) 'userId': userId,
      if (userType != null) 'userType': userType,
      if (applicationName != null) 'applicationName': applicationName,
      if (requestMethod != null) 'requestMethod': requestMethod,
      if (requestParams != null) 'requestParams': requestParams,
      if (requestUrl != null) 'requestUrl': requestUrl,
      if (userIp != null) 'userIp': userIp,
      if (userAgent != null) 'userAgent': userAgent,
      if (exceptionTime != null) 'exceptionTime': exceptionTime,
      if (exceptionName != null) 'exceptionName': exceptionName,
      if (exceptionMessage != null) 'exceptionMessage': exceptionMessage,
      if (exceptionRootCauseMessage != null) 'exceptionRootCauseMessage': exceptionRootCauseMessage,
      if (exceptionStackTrace != null) 'exceptionStackTrace': exceptionStackTrace,
      if (exceptionClassName != null) 'exceptionClassName': exceptionClassName,
      if (exceptionFileName != null) 'exceptionFileName': exceptionFileName,
      if (exceptionMethodName != null) 'exceptionMethodName': exceptionMethodName,
      if (exceptionLineNumber != null) 'exceptionLineNumber': exceptionLineNumber,
      if (processUserId != null) 'processUserId': processUserId,
      if (processStatus != null) 'processStatus': processStatus,
      if (processTime != null) 'processTime': processTime,
      if (resultCode != null) 'resultCode': resultCode,
      if (createTime != null) 'createTime': createTime,
    };
  }
}

/// API 错误日志处理状态枚举
class ApiErrorLogProcessStatus {
  static const int init = 0;    // 待处理
  static const int done = 1;    // 已处理
  static const int ignore = 2;  // 已忽略
}