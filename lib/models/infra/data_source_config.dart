/// 数据源配置模型
class DataSourceConfig {
  final int? id;
  final String name;
  final String url;
  final String username;
  final String password;
  final String? createTime;

  DataSourceConfig({
    this.id,
    required this.name,
    required this.url,
    required this.username,
    required this.password,
    this.createTime,
  });

  factory DataSourceConfig.fromJson(Map<String, dynamic> json) {
    return DataSourceConfig(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      createTime: json['createTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'url': url,
      'username': username,
      'password': password,
    };
  }
}