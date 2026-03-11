/// 任务执行日志模型
class JobLog {
  final int? id;
  final int jobId;
  final String handlerName;
  final String handlerParam;
  final String cronExpression;
  final String executeIndex;
  final String? beginTime;
  final String? endTime;
  final String duration;
  final int status;
  final String? createTime;
  final String? result;

  JobLog({
    this.id,
    required this.jobId,
    required this.handlerName,
    this.handlerParam = '',
    this.cronExpression = '',
    this.executeIndex = '',
    this.beginTime,
    this.endTime,
    this.duration = '',
    this.status = 0,
    this.createTime,
    this.result,
  });

  factory JobLog.fromJson(Map<String, dynamic> json) {
    return JobLog(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      jobId: json['jobId'] is int ? json['jobId'] : int.tryParse(json['jobId']?.toString() ?? '') ?? 0,
      handlerName: json['handlerName']?.toString() ?? '',
      handlerParam: json['handlerParam']?.toString() ?? '',
      cronExpression: json['cronExpression']?.toString() ?? '',
      executeIndex: json['executeIndex']?.toString() ?? '',
      beginTime: json['beginTime']?.toString(),
      endTime: json['endTime']?.toString(),
      duration: json['duration']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      createTime: json['createTime']?.toString(),
      result: json['result']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'jobId': jobId,
      'handlerName': handlerName,
      'handlerParam': handlerParam,
      'cronExpression': cronExpression,
      'executeIndex': executeIndex,
      if (beginTime != null) 'beginTime': beginTime,
      if (endTime != null) 'endTime': endTime,
      'duration': duration,
      'status': status,
      if (result != null) 'result': result,
    };
  }
}

/// 任务日志状态枚举
class JobLogStatus {
  static const int success = 0; // 成功
  static const int failure = 1; // 失败
}