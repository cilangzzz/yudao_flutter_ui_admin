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
    return ApiResponse(
      code: json['code'] as int? ?? -1,
      msg: json['msg'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
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