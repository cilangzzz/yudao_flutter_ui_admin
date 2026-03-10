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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      sort: json['sort'] is int ? json['sort'] : int.tryParse(json['sort']?.toString() ?? '') ?? 0,
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      remark: json['remark']?.toString(),
      createTime: json['createTime']?.toString(),
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