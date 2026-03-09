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
      id: json['id'] as int?,
      mail: json['mail'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      host: json['host'] as String? ?? '',
      port: json['port'] as int? ?? 0,
      sslEnable: json['sslEnable'] as bool? ?? false,
      starttlsEnable: json['starttlsEnable'] as bool? ?? false,
      status: json['status'] as int? ?? 0,
      createTime: json['createTime'] as String?,
      remark: json['remark'] as String?,
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