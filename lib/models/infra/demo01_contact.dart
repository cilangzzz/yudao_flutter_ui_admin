/// 示例联系人模型 - Demo01
class Demo01Contact {
  final int? id;
  final String name;
  final int sex;
  final int? birthday;
  final String? description;
  final String? avatar;
  final String? createTime;

  Demo01Contact({
    this.id,
    required this.name,
    this.sex = 1,
    this.birthday,
    this.description,
    this.avatar,
    this.createTime,
  });

  factory Demo01Contact.fromJson(Map<String, dynamic> json) {
    return Demo01Contact(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      sex: json['sex'] is int ? json['sex'] : int.tryParse(json['sex']?.toString() ?? '') ?? 1,
      birthday: json['birthday'] is int ? json['birthday'] : int.tryParse(json['birthday']?.toString() ?? ''),
      description: json['description']?.toString(),
      avatar: json['avatar']?.toString(),
      createTime: json['createTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'sex': sex,
      if (birthday != null) 'birthday': birthday,
      if (description != null) 'description': description,
      if (avatar != null) 'avatar': avatar,
    };
  }

  Demo01Contact copyWith({
    int? id,
    String? name,
    int? sex,
    int? birthday,
    String? description,
    String? avatar,
    String? createTime,
  }) {
    return Demo01Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      birthday: birthday ?? this.birthday,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      createTime: createTime ?? this.createTime,
    );
  }
}