/// 参数配置模型
class Config {
  final int? id;
  final String category;
  final String name;
  final String key;
  final String value;
  final int type;
  final bool visible;
  final String? remark;
  final String? createTime;

  Config({
    this.id,
    required this.category,
    required this.name,
    required this.key,
    required this.value,
    this.type = 0,
    this.visible = true,
    this.remark,
    this.createTime,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      category: json['category']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      key: json['key']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      type: json['type'] is int ? json['type'] : int.tryParse(json['type']?.toString() ?? '') ?? 0,
      visible: json['visible'] is bool ? json['visible'] : json['visible']?.toString() == 'true',
      remark: json['remark']?.toString(),
      createTime: json['createTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'category': category,
      'name': name,
      'key': key,
      'value': value,
      'type': type,
      'visible': visible,
      if (remark != null) 'remark': remark,
    };
  }
}