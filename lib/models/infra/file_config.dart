/// 文件客户端配置
class FileClientConfig {
  final String basePath;
  final String? host;
  final int? port;
  final String? username;
  final String? password;
  final String? mode;
  final String? endpoint;
  final String? bucket;
  final String? accessKey;
  final String? accessSecret;
  final bool? pathStyle;
  final bool? enablePublicAccess;
  final String? region;
  final String domain;

  FileClientConfig({
    required this.basePath,
    this.host,
    this.port,
    this.username,
    this.password,
    this.mode,
    this.endpoint,
    this.bucket,
    this.accessKey,
    this.accessSecret,
    this.pathStyle,
    this.enablePublicAccess,
    this.region,
    required this.domain,
  });

  factory FileClientConfig.fromJson(Map<String, dynamic> json) {
    return FileClientConfig(
      basePath: json['basePath']?.toString() ?? '',
      host: json['host']?.toString(),
      port: json['port'] is int ? json['port'] : int.tryParse(json['port']?.toString() ?? ''),
      username: json['username']?.toString(),
      password: json['password']?.toString(),
      mode: json['mode']?.toString(),
      endpoint: json['endpoint']?.toString(),
      bucket: json['bucket']?.toString(),
      accessKey: json['accessKey']?.toString(),
      accessSecret: json['accessSecret']?.toString(),
      pathStyle: json['pathStyle'] is bool ? json['pathStyle'] : json['pathStyle'] == 'true',
      enablePublicAccess: json['enablePublicAccess'] is bool
          ? json['enablePublicAccess']
          : json['enablePublicAccess'] == 'true',
      region: json['region']?.toString(),
      domain: json['domain']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basePath': basePath,
      if (host != null) 'host': host,
      if (port != null) 'port': port,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (mode != null) 'mode': mode,
      if (endpoint != null) 'endpoint': endpoint,
      if (bucket != null) 'bucket': bucket,
      if (accessKey != null) 'accessKey': accessKey,
      if (accessSecret != null) 'accessSecret': accessSecret,
      if (pathStyle != null) 'pathStyle': pathStyle,
      if (enablePublicAccess != null) 'enablePublicAccess': enablePublicAccess,
      if (region != null) 'region': region,
      'domain': domain,
    };
  }
}

/// 文件配置模型
class FileConfig {
  final int? id;
  final String name;
  final int? storage;
  final bool master;
  final bool visible;
  final FileClientConfig? config;
  final String? remark;
  final String? createTime;

  FileConfig({
    this.id,
    required this.name,
    this.storage,
    this.master = false,
    this.visible = true,
    this.config,
    this.remark,
    this.createTime,
  });

  factory FileConfig.fromJson(Map<String, dynamic> json) {
    return FileConfig(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      storage: json['storage'] is int ? json['storage'] : int.tryParse(json['storage']?.toString() ?? ''),
      master: json['master'] is bool ? json['master'] : json['master'] == 'true',
      visible: json['visible'] is bool ? json['visible'] : json['visible'] != false,
      config: json['config'] != null
          ? FileClientConfig.fromJson(json['config'] as Map<String, dynamic>)
          : null,
      remark: json['remark']?.toString(),
      createTime: json['createTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (storage != null) 'storage': storage,
      'master': master,
      'visible': visible,
      if (config != null) 'config': config!.toJson(),
      if (remark != null) 'remark': remark,
    };
  }
}

/// 存储器类型枚举
enum StorageType {
  database(1, '数据库'),
  db(10, 'DB'),
  ftp(11, 'FTP'),
  sftp(12, 'SFTP'),
  s3(20, 'S3');

  final int value;
  final String label;
  const StorageType(this.value, this.label);

  static StorageType? fromValue(int? value) {
    if (value == null) return null;
    return StorageType.values.cast<StorageType?>().firstWhere(
          (e) => e?.value == value,
          orElse: () => null,
        );
  }

  static String getLabel(int? value) {
    return fromValue(value)?.label ?? '-';
  }
}