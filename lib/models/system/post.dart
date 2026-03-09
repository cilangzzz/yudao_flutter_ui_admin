/// 岗位模型
class Post {
  final int? id;
  final String name;
  final String code;
  final int sort;
  final int status;
  final String? remark;
  final String? createTime;

  Post({
    this.id,
    required this.name,
    required this.code,
    this.sort = 0,
    this.status = 0,
    this.remark,
    this.createTime,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      sort: json['sort'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      remark: json['remark'] as String?,
      createTime: json['createTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'code': code,
      'sort': sort,
      'status': status,
      if (remark != null) 'remark': remark,
    };
  }
}