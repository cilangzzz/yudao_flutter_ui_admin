/// 定时任务模型
class Job {
  final int? id;
  final String name;
  final int status;
  final String handlerName;
  final String handlerParam;
  final String cronExpression;
  final int retryCount;
  final int retryInterval;
  final int? monitorTimeout;
  final String? createTime;
  final List<String>? nextTimes;

  Job({
    this.id,
    required this.name,
    this.status = 0,
    required this.handlerName,
    this.handlerParam = '',
    required this.cronExpression,
    this.retryCount = 0,
    this.retryInterval = 0,
    this.monitorTimeout,
    this.createTime,
    this.nextTimes,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      handlerName: json['handlerName']?.toString() ?? '',
      handlerParam: json['handlerParam']?.toString() ?? '',
      cronExpression: json['cronExpression']?.toString() ?? '',
      retryCount: json['retryCount'] is int ? json['retryCount'] : int.tryParse(json['retryCount']?.toString() ?? '') ?? 0,
      retryInterval: json['retryInterval'] is int ? json['retryInterval'] : int.tryParse(json['retryInterval']?.toString() ?? '') ?? 0,
      monitorTimeout: json['monitorTimeout'] is int ? json['monitorTimeout'] : int.tryParse(json['monitorTimeout']?.toString() ?? ''),
      createTime: json['createTime']?.toString(),
      nextTimes: json['nextTimes'] != null
          ? (json['nextTimes'] as List<dynamic>).map((e) => e.toString()).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'status': status,
      'handlerName': handlerName,
      'handlerParam': handlerParam,
      'cronExpression': cronExpression,
      'retryCount': retryCount,
      'retryInterval': retryInterval,
      if (monitorTimeout != null) 'monitorTimeout': monitorTimeout,
    };
  }
}

/// 定时任务状态枚举
class JobStatus {
  static const int normal = 0; // 正常
  static const int stop = 1;   // 暂停
}