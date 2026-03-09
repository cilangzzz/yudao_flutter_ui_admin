/// 租户套餐模型
class TenantPackage {
  final int? id;
  final String name;
  final int? status;
  final String? remark;
  final List<int>? menuIds;
  final String? createTime;

  const TenantPackage({
    this.id,
    required this.name,
    this.status,
    this.remark,
    this.menuIds,
    this.createTime,
  });

  factory TenantPackage.fromJson(Map<String, dynamic> json) {
    return TenantPackage(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      status: json['status'] as int?,
      remark: json['remark'] as String?,
      menuIds: (json['menuIds'] as List<dynamic>?)
          ?.map((e) => e is int ? e : int.parse(e.toString()))
          .toList(),
      createTime: json['createTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (status != null) 'status': status,
      if (remark != null) 'remark': remark,
      if (menuIds != null) 'menuIds': menuIds,
    };
  }
}