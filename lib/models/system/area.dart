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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      parentId: json['parentId'] is int ? json['parentId'] : int.tryParse(json['parentId']?.toString() ?? ''),
      sort: json['sort'] is int ? json['sort'] : int.tryParse(json['sort']?.toString() ?? ''),
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? ''),
      createTime: json['createTime']?.toString(),
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