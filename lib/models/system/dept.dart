/// 部门模型
class Dept {
  final int? id;
  final String name;
  final int? parentId;
  final int? status;
  final int? sort;
  final int? leaderUserId;
  final String? phone;
  final String? email;
  final DateTime? createTime;
  final List<Dept>? children;

  const Dept({
    this.id,
    required this.name,
    this.parentId,
    this.status,
    this.sort,
    this.leaderUserId,
    this.phone,
    this.email,
    this.createTime,
    this.children,
  });

  factory Dept.fromJson(Map<String, dynamic> json) {
    return Dept(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      parentId: json['parentId'] as int?,
      status: json['status'] as int?,
      sort: json['sort'] as int?,
      leaderUserId: json['leaderUserId'] as int?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      createTime: json['createTime'] != null
          ? DateTime.tryParse(json['createTime'] as String)
          : null,
      children: json['children'] != null
          ? (json['children'] as List<dynamic>)
              .map((e) => Dept.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (parentId != null) 'parentId': parentId,
      if (status != null) 'status': status,
      if (sort != null) 'sort': sort,
      if (leaderUserId != null) 'leaderUserId': leaderUserId,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (createTime != null) 'createTime': createTime?.toIso8601String(),
    };
  }

  Dept copyWith({
    int? id,
    String? name,
    int? parentId,
    int? status,
    int? sort,
    int? leaderUserId,
    String? phone,
    String? email,
    DateTime? createTime,
    List<Dept>? children,
  }) {
    return Dept(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      status: status ?? this.status,
      sort: sort ?? this.sort,
      leaderUserId: leaderUserId ?? this.leaderUserId,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      createTime: createTime ?? this.createTime,
      children: children ?? this.children,
    );
  }
}

/// 精简部门信息（用于下拉选择）
class SimpleDept {
  final int id;
  final String name;
  final int? parentId;

  const SimpleDept({
    required this.id,
    required this.name,
    this.parentId,
  });

  factory SimpleDept.fromJson(Map<String, dynamic> json) {
    return SimpleDept(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      parentId: json['parentId'] as int?,
    );
  }
}