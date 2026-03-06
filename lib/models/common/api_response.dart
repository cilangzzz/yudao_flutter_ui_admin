/// API 响应模型
class ApiResponse<T> {
  final int code;
  final String msg;
  final T? data;

  ApiResponse({
    required this.code,
    required this.msg,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    // 兼容 httpbin 响应格式（没有 code/msg 字段时视为成功）
    final hasCode = json.containsKey('code');
    final code = hasCode ? (json['code'] as int? ?? -1) : 0;
    final msg = hasCode ? (json['msg'] as String? ?? '') : 'success';

    // httpbin 响应：数据在 json 字段中；标准响应：数据在 data 字段中
    final dataJson = json['json'] ?? json['data'];

    return ApiResponse(
      code: code,
      msg: msg,
      data: dataJson != null && fromJsonT != null
          ? fromJsonT(dataJson)
          : dataJson as T?,
    );
  }

  bool get isSuccess => code == 0;

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T)? toJsonT) {
    return {
      'code': code,
      'msg': msg,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
    };
  }
}