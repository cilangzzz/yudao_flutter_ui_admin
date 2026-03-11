/// 邮箱账号模型
class MailAccount {
  final int? id;
  final String mail;
  final String username;
  final String password;
  final String host;
  final int port;
  final bool sslEnable;
  final bool starttlsEnable;
  final int status;
  final String? createTime;
  final String? remark;

  MailAccount({
    this.id,
    required this.mail,
    required this.username,
    required this.password,
    required this.host,
    required this.port,
    this.sslEnable = false,
    this.starttlsEnable = false,
    this.status = 0,
    this.createTime,
    this.remark,
  });

  factory MailAccount.fromJson(Map<String, dynamic> json) {
    return MailAccount(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      mail: json['mail']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      host: json['host']?.toString() ?? '',
      port: json['port'] is int ? json['port'] : int.tryParse(json['port']?.toString() ?? '') ?? 0,
      sslEnable: json['sslEnable'] is bool ? json['sslEnable'] : bool.tryParse(json['sslEnable']?.toString() ?? '') ?? false,
      starttlsEnable: json['starttlsEnable'] is bool ? json['starttlsEnable'] : bool.tryParse(json['starttlsEnable']?.toString() ?? '') ?? false,
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      createTime: json['createTime']?.toString(),
      remark: json['remark']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'mail': mail,
      'username': username,
      'password': password,
      'host': host,
      'port': port,
      'sslEnable': sslEnable,
      'starttlsEnable': starttlsEnable,
      'status': status,
      if (remark != null) 'remark': remark,
    };
  }
}