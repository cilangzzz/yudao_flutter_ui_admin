/// 字典数据模型
class DictData {
  final int? id;
  final String label;
  final String value;
  final String? dictType;
  final int? sort;
  final int? status;
  final String? colorType;
  final String? cssClass;
  final String? remark;
  final DateTime? createTime;

  const DictData({
    this.id,
    required this.label,
    required this.value,
    this.dictType,
    this.sort,
    this.status,
    this.colorType,
    this.cssClass,
    this.remark,
    this.createTime,
  });

  factory DictData.fromJson(Map<String, dynamic> json) {
    return DictData(
      id: json['id'] as int?,
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
      dictType: json['dictType'] as String?,
      sort: json['sort'] as int?,
      status: json['status'] as int?,
      colorType: json['colorType'] as String?,
      cssClass: json['cssClass'] as String?,
      remark: json['remark'] as String?,
      createTime: json['createTime'] != null
          ? DateTime.tryParse(json['createTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'label': label,
      'value': value,
      if (dictType != null) 'dictType': dictType,
      if (sort != null) 'sort': sort,
      if (status != null) 'status': status,
      if (colorType != null) 'colorType': colorType,
      if (cssClass != null) 'cssClass': cssClass,
      if (remark != null) 'remark': remark,
      if (createTime != null) 'createTime': createTime?.toIso8601String(),
    };
  }

  DictData copyWith({
    int? id,
    String? label,
    String? value,
    String? dictType,
    int? sort,
    int? status,
    String? colorType,
    String? cssClass,
    String? remark,
    DateTime? createTime,
  }) {
    return DictData(
      id: id ?? this.id,
      label: label ?? this.label,
      value: value ?? this.value,
      dictType: dictType ?? this.dictType,
      sort: sort ?? this.sort,
      status: status ?? this.status,
      colorType: colorType ?? this.colorType,
      cssClass: cssClass ?? this.cssClass,
      remark: remark ?? this.remark,
      createTime: createTime ?? this.createTime,
    );
  }
}

/// 精简字典数据（用于下拉选择）
class SimpleDictData {
  final int? id;
  final String label;
  final String value;

  const SimpleDictData({
    this.id,
    required this.label,
    required this.value,
  });

  factory SimpleDictData.fromJson(Map<String, dynamic> json) {
    return SimpleDictData(
      id: json['id'] as int?,
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }
}