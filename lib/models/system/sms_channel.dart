/// 短信渠道模型
class SmsChannel {
  final int? id;
  final String code;
  final int status;
  final String signature;
  final String? remark;
  final String apiKey;
  final String? apiSecret;
  final String? callbackUrl;
  final String? createTime;

  SmsChannel({
    this.id,
    required this.code,
    this.status = 0,
    required this.signature,
    this.remark,
    required this.apiKey,
    this.apiSecret,
    this.callbackUrl,
    this.createTime,
  });

  factory SmsChannel.fromJson(Map<String, dynamic> json) {
    return SmsChannel(
      id: json['id'] as int?,
      code: json['code'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      signature: json['signature'] as String? ?? '',
      remark: json['remark'] as String?,
      apiKey: json['apiKey'] as String? ?? '',
      apiSecret: json['apiSecret'] as String?,
      callbackUrl: json['callbackUrl'] as String?,
      createTime: json['createTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'code': code,
      'status': status,
      'signature': signature,
      if (remark != null) 'remark': remark,
      'apiKey': apiKey,
      if (apiSecret != null) 'apiSecret': apiSecret,
      if (callbackUrl != null) 'callbackUrl': callbackUrl,
    };
  }
}