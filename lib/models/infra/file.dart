/// 文件模型
class File {
  final int? id;
  final int? configId;
  final String path;
  final String? name;
  final String? url;
  final int? size;
  final String? type;
  final String? createTime;

  File({
    this.id,
    this.configId,
    required this.path,
    this.name,
    this.url,
    this.size,
    this.type,
    this.createTime,
  });

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      configId: json['configId'] is int ? json['configId'] : int.tryParse(json['configId']?.toString() ?? ''),
      path: json['path']?.toString() ?? '',
      name: json['name']?.toString(),
      url: json['url']?.toString(),
      size: json['size'] is int ? json['size'] : int.tryParse(json['size']?.toString() ?? ''),
      type: json['type']?.toString(),
      createTime: json['createTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (configId != null) 'configId': configId,
      'path': path,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (size != null) 'size': size,
      if (type != null) 'type': type,
    };
  }

  /// 获取格式化的文件大小
  String get formattedSize {
    if (size == null || size == 0) return '-';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unitIndex = 0;
    double fileSize = size!.toDouble();
    while (fileSize >= 1024 && unitIndex < units.length - 1) {
      fileSize /= 1024;
      unitIndex++;
    }
    return '${fileSize.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  /// 判断是否为图片类型
  bool get isImage => type != null && type!.contains('image');

  /// 判断是否为 PDF 类型
  bool get isPdf => type != null && type!.contains('pdf');
}