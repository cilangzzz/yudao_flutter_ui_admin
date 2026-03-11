/// 示例分类模型 - Demo02 (树形结构)
class Demo02Category {
  final int? id;
  final String name;
  final int parentId;
  final String? createTime;
  List<Demo02Category>? children;

  Demo02Category({
    this.id,
    required this.name,
    this.parentId = 0,
    this.createTime,
    this.children,
  });

  factory Demo02Category.fromJson(Map<String, dynamic> json) {
    return Demo02Category(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      parentId: json['parentId'] is int ? json['parentId'] : int.tryParse(json['parentId']?.toString() ?? '') ?? 0,
      createTime: json['createTime']?.toString(),
      children: json['children'] != null
          ? (json['children'] as List).map((e) => Demo02Category.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'parentId': parentId,
    };
  }

  Demo02Category copyWith({
    int? id,
    String? name,
    int? parentId,
    String? createTime,
    List<Demo02Category>? children,
  }) {
    return Demo02Category(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      createTime: createTime ?? this.createTime,
      children: children ?? this.children,
    );
  }
}