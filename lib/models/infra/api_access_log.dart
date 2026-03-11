/// API 访问日志模型
class ApiAccessLog {
  final int? id;
  final String? traceId;
  final int? userId;
  final int? userType;
  final String? applicationName;
  final String? requestMethod;
  final String? requestParams;
  final String? responseBody;
  final String? requestUrl;
  final String? userIp;
  final String? userAgent;
  final String? operateModule;
  final String? operateName;
  final int? operateType;
  final String? beginTime;
  final String? endTime;
  final int? duration;
  final int? resultCode;
  final String? resultMsg;
  final String? createTime;

  ApiAccessLog({
    this.id,
    this.traceId,
    this.userId,
    this.userType,
    this.applicationName,
    this.requestMethod,
    this.requestParams,
    this.responseBody,
    this.requestUrl,
    this.userIp,
    this.userAgent,
    this.operateModule,
    this.operateName,
    this.operateType,
    this.beginTime,
    this.endTime,
    this.duration,
    this.resultCode,
    this.resultMsg,
    this.createTime,
  });

  factory ApiAccessLog.fromJson(Map<String, dynamic> json) {
    return ApiAccessLog(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      traceId: json['traceId']?.toString(),
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? ''),
      userType: json['userType'] is int ? json['userType'] : int.tryParse(json['userType']?.toString() ?? ''),
      applicationName: json['applicationName']?.toString(),
      requestMethod: json['requestMethod']?.toString(),
      requestParams: json['requestParams']?.toString(),
      responseBody: json['responseBody']?.toString(),
      requestUrl: json['requestUrl']?.toString(),
      userIp: json['userIp']?.toString(),
      userAgent: json['userAgent']?.toString(),
      operateModule: json['operateModule']?.toString(),
      operateName: json['operateName']?.toString(),
      operateType: json['operateType'] is int ? json['operateType'] : int.tryParse(json['operateType']?.toString() ?? ''),
      beginTime: json['beginTime']?.toString(),
      endTime: json['endTime']?.toString(),
      duration: json['duration'] is int ? json['duration'] : int.tryParse(json['duration']?.toString() ?? ''),
      resultCode: json['resultCode'] is int ? json['resultCode'] : int.tryParse(json['resultCode']?.toString() ?? ''),
      resultMsg: json['resultMsg']?.toString(),
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
      if (responseBody != null) 'responseBody': responseBody,
      if (requestUrl != null) 'requestUrl': requestUrl,
      if (userIp != null) 'userIp': userIp,
      if (userAgent != null) 'userAgent': userAgent,
      if (operateModule != null) 'operateModule': operateModule,
      if (operateName != null) 'operateName': operateName,
      if (operateType != null) 'operateType': operateType,
      if (beginTime != null) 'beginTime': beginTime,
      if (endTime != null) 'endTime': endTime,
      if (duration != null) 'duration': duration,
      if (resultCode != null) 'resultCode': resultCode,
      if (resultMsg != null) 'resultMsg': resultMsg,
      if (createTime != null) 'createTime': createTime,
    };
  }
}