/// 分页响应结果
class PageResult<T> {
  final List<T> list;
  final int total;

  const PageResult({
    required this.list,
    required this.total,
  });

  factory PageResult.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final dataList = json['list'] as List<dynamic>? ?? [];
    return PageResult(
      list: dataList.map((e) => fromJsonT(e)).toList(),
      total: json['total'] as int? ?? 0,
    );
  }

  bool get isEmpty => list.isEmpty;
  bool get isNotEmpty => list.isNotEmpty;

  PageResult<R> map<R>(R Function(T) mapper) {
    return PageResult(
      list: list.map(mapper).toList(),
      total: total,
    );
  }
}