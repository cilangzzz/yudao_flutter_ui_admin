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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      parentId: json['parentId'] is int ? json['parentId'] : int.tryParse(json['parentId']?.toString() ?? ''),
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? ''),
      sort: json['sort'] is int ? json['sort'] : int.tryParse(json['sort']?.toString() ?? ''),
      leaderUserId: json['leaderUserId'] is int ? json['leaderUserId'] : int.tryParse(json['leaderUserId']?.toString() ?? ''),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      createTime: json['createTime'] != null
          ? DateTime.tryParse(json['createTime'].toString())
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
  final List<SimpleDept>? children;

  const SimpleDept({
    required this.id,
    required this.name,
    this.parentId,
    this.children,
  });

  factory SimpleDept.fromJson(Map<String, dynamic> json) {
    return SimpleDept(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      parentId: json['parentId'] is int ? json['parentId'] : int.tryParse(json['parentId']?.toString() ?? ''),
      children: json['children'] != null
          ? (json['children'] as List<dynamic>)
              .map((e) => SimpleDept.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  SimpleDept copyWith({
    int? id,
    String? name,
    int? parentId,
    List<SimpleDept>? children,
  }) {
    return SimpleDept(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      children: children ?? this.children,
    );
  }
}