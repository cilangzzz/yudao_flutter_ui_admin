import '../common/page_param.dart';

/// 用户模型
class User {
  final int? id;
  final String username;
  final String nickname;
  final int? deptId;
  final String? deptName;
  final List<int>? postIds;
  final String? email;
  final String? mobile;
  final int? sex;
  final String? avatar;
  final String? loginIp;
  final DateTime? loginDate;
  final int? status;
  final String? remark;
  final DateTime? createTime;

  const User({
    this.id,
    required this.username,
    required this.nickname,
    this.deptId,
    this.deptName,
    this.postIds,
    this.email,
    this.mobile,
    this.sex,
    this.avatar,
    this.loginIp,
    this.loginDate,
    this.status,
    this.remark,
    this.createTime,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      username: json['username']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      deptId: json['deptId'] is int ? json['deptId'] : int.tryParse(json['deptId']?.toString() ?? ''),
      deptName: json['deptName']?.toString(),
      postIds: (json['postIds'] as List<dynamic>?)
          ?.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .toList(),
      email: json['email']?.toString(),
      mobile: json['mobile']?.toString(),
      sex: json['sex'] is int ? json['sex'] : int.tryParse(json['sex']?.toString() ?? ''),
      avatar: json['avatar']?.toString(),
      loginIp: json['loginIp']?.toString(),
      loginDate: json['loginDate'] != null
          ? DateTime.tryParse(json['loginDate'].toString())
          : null,
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
      'username': username,
      'nickname': nickname,
      if (deptId != null) 'deptId': deptId,
      if (postIds != null) 'postIds': postIds,
      if (email != null) 'email': email,
      if (mobile != null) 'mobile': mobile,
      if (sex != null) 'sex': sex,
      if (avatar != null) 'avatar': avatar,
      if (loginIp != null) 'loginIp': loginIp,
      if (status != null) 'status': status,
      if (remark != null) 'remark': remark,
      if (createTime != null) 'createTime': createTime?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? nickname,
    int? deptId,
    String? deptName,
    List<int>? postIds,
    String? email,
    String? mobile,
    int? sex,
    String? avatar,
    String? loginIp,
    DateTime? loginDate,
    int? status,
    String? remark,
    DateTime? createTime,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      deptId: deptId ?? this.deptId,
      deptName: deptName ?? this.deptName,
      postIds: postIds ?? this.postIds,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      sex: sex ?? this.sex,
      avatar: avatar ?? this.avatar,
      loginIp: loginIp ?? this.loginIp,
      loginDate: loginDate ?? this.loginDate,
      status: status ?? this.status,
      remark: remark ?? this.remark,
      createTime: createTime ?? this.createTime,
    );
  }
}

/// 精简用户信息（用于下拉选择）
class SimpleUser {
  final int id;
  final String username;
  final String nickname;

  const SimpleUser({
    required this.id,
    required this.username,
    required this.nickname,
  });

  factory SimpleUser.fromJson(Map<String, dynamic> json) {
    return SimpleUser(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
    );
  }
}

/// 用户查询参数
class UserPageParam extends PageParam {
  final String? username;
  final String? mobile;
  final int? status;
  final int? deptId;
  final DateTime? createTime;

  const UserPageParam({
    super.pageNum = 1,
    super.pageSize = 10,
    this.username,
    this.mobile,
    this.status,
    this.deptId,
    this.createTime,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (username != null && username!.isNotEmpty) {
      json['username'] = username;
    }
    if (mobile != null && mobile!.isNotEmpty) {
      json['mobile'] = mobile;
    }
    if (status != null) {
      json['status'] = status;
    }
    if (deptId != null) {
      json['deptId'] = deptId;
    }
    if (createTime != null) {
      json['createTime'] = createTime!.toIso8601String();
    }
    return json;
  }
}

/// 用户导出参数
class UserExportParam {
  final String? username;
  final String? mobile;
  final int? status;
  final int? deptId;
  final DateTime? createTime;

  const UserExportParam({
    this.username,
    this.mobile,
    this.status,
    this.deptId,
    this.createTime,
  });

  Map<String, dynamic> toJson() {
    return {
      if (username != null && username!.isNotEmpty) 'username': username,
      if (mobile != null && mobile!.isNotEmpty) 'mobile': mobile,
      if (status != null) 'status': status,
      if (deptId != null) 'deptId': deptId,
      if (createTime != null) 'createTime': createTime!.toIso8601String(),
    };
  }
}