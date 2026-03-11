/// 字典类型模型
class DictType {
  final int? id;
  final String name;
  final String type;
  final int? status;
  final String? remark;
  final DateTime? createTime;

  const DictType({
    this.id,
    required this.name,
    required this.type,
    this.status,
    this.remark,
    this.createTime,
  });

  factory DictType.fromJson(Map<String, dynamic> json) {
    return DictType(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? ''),
      remark: json['remark']?.toString(),
      createTime: json['createTime'] != null
          ? DateTime.tryParse(json['createTime'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type,
      if (status != null) 'status': status,
      if (remark != null) 'remark': remark,
      if (createTime != null) 'createTime': createTime?.toIso8601String(),
    };
  }

  DictType copyWith({
    int? id,
    String? name,
    String? type,
    int? status,
    String? remark,
    DateTime? createTime,
  }) {
    return DictType(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      remark: remark ?? this.remark,
      createTime: createTime ?? this.createTime,
    );
  }
}

/// 精简字典类型（用于下拉选择）
class SimpleDictType {
  final int? id;
  final String name;
  final String type;

  const SimpleDictType({
    this.id,
    required this.name,
    required this.type,
  });

  factory SimpleDictType.fromJson(Map<String, dynamic> json) {
    return SimpleDictType(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}