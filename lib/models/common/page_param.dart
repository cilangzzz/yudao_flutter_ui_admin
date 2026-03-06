/// 分页请求参数
class PageParam {
  final int pageNum;
  final int pageSize;

  const PageParam({
    this.pageNum = 1,
    this.pageSize = 10,
  });

  Map<String, dynamic> toJson() => {
        'pageNo': pageNum,
        'pageSize': pageSize,
      };

  PageParam copyWith({
    int? pageNum,
    int? pageSize,
  }) {
    return PageParam(
      pageNum: pageNum ?? this.pageNum,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}