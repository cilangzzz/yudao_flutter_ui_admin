/// 租户模型
class Tenant {
  final int? id;
  final String name;
  final int? packageId;
  final String? contactName;
  final String? contactMobile;
  final int? accountCount;
  final String? expireTime;
  final List<String>? websites;
  final int? status;
  final String? createTime;

  const Tenant({
    this.id,
    required this.name,
    this.packageId,
    this.contactName,
    this.contactMobile,
    this.accountCount,
    this.expireTime,
    this.websites,
    this.status,
    this.createTime,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      packageId: json['packageId'] as int?,
      contactName: json['contactName'] as String?,
      contactMobile: json['contactMobile'] as String?,
      accountCount: json['accountCount'] as int?,
      expireTime: json['expireTime'] as String?,
      websites: (json['websites'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      status: json['status'] as int?,
      createTime: json['createTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (packageId != null) 'packageId': packageId,
      if (contactName != null) 'contactName': contactName,
      if (contactMobile != null) 'contactMobile': contactMobile,
      if (accountCount != null) 'accountCount': accountCount,
      if (expireTime != null) 'expireTime': expireTime,
      if (websites != null) 'websites': websites,
      if (status != null) 'status': status,
    };
  }
}