/// 地区模型
class Area {
  final int? id;
  final String name;
  final String code;
  final int? parentId;
  final int? sort;
  final int? status;
  final String? createTime;
  final List<Area>? children;

  Area({
    this.id,
    required this.name,
    required this.code,
    this.parentId,
    this.sort,
    this.status,
    this.createTime,
    this.children,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      parentId: json['parentId'] as int?,
      sort: json['sort'] as int?,
      status: json['status'] as int?,
      createTime: json['createTime'] as String?,
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => Area.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'code': code,
      if (parentId != null) 'parentId': parentId,
      if (sort != null) 'sort': sort,
      if (status != null) 'status': status,
      if (createTime != null) 'createTime': createTime,
    };
  }
}