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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      code: json['code']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      signature: json['signature']?.toString() ?? '',
      remark: json['remark']?.toString(),
      apiKey: json['apiKey']?.toString() ?? '',
      apiSecret: json['apiSecret']?.toString(),
      callbackUrl: json['callbackUrl']?.toString(),
      createTime: json['createTime']?.toString(),
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