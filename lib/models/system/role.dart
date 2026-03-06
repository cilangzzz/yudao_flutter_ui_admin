import '../common/page_param.dart';

/// 角色模型
class Role {
  final int? id;
  final String name;
  final String code;
  final int? sort;
  final int? status;
  final int? type;
  final int? dataScope;
  final List<int>? dataScopeDeptIds;
  final DateTime? createTime;

  const Role({
    this.id,
    required this.name,
    required this.code,
    this.sort,
    this.status,
    this.type,
    this.dataScope,
    this.dataScopeDeptIds,
    this.createTime,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      sort: json['sort'] as int?,
      status: json['status'] as int?,
      type: json['type'] as int?,
      dataScope: json['dataScope'] as int?,
      dataScopeDeptIds: (json['dataScopeDeptIds'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      createTime: json['createTime'] != null
          ? DateTime.tryParse(json['createTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'code': code,
      if (sort != null) 'sort': sort,
      if (status != null) 'status': status,
      if (type != null) 'type': type,
      if (dataScope != null) 'dataScope': dataScope,
      if (dataScopeDeptIds != null) 'dataScopeDeptIds': dataScopeDeptIds,
      if (createTime != null) 'createTime': createTime?.toIso8601String(),
    };
  }

  Role copyWith({
    int? id,
    String? name,
    String? code,
    int? sort,
    int? status,
    int? type,
    int? dataScope,
    List<int>? dataScopeDeptIds,
    DateTime? createTime,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      sort: sort ?? this.sort,
      status: status ?? this.status,
      type: type ?? this.type,
      dataScope: dataScope ?? this.dataScope,
      dataScopeDeptIds: dataScopeDeptIds ?? this.dataScopeDeptIds,
      createTime: createTime ?? this.createTime,
    );
  }
}

/// 精简角色信息（用于下拉选择）
class SimpleRole {
  final int id;
  final String name;
  final String code;

  const SimpleRole({
    required this.id,
    required this.name,
    required this.code,
  });

  factory SimpleRole.fromJson(Map<String, dynamic> json) {
    return SimpleRole(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }
}

/// 角色查询参数
class RolePageParam extends PageParam {
  final String? name;
  final String? code;
  final int? status;

  const RolePageParam({
    super.pageNum = 1,
    super.pageSize = 10,
    this.name,
    this.code,
    this.status,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (name != null && name!.isNotEmpty) {
      json['name'] = name;
    }
    if (code != null && code!.isNotEmpty) {
      json['code'] = code;
    }
    if (status != null) {
      json['status'] = status;
    }
    return json;
  }
}