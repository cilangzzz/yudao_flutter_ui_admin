/// 社交客户端模型
class SocialClient {
  final int? id;
  final String name;
  final int? socialType;
  final int? userType;
  final String clientId;
  final String? clientSecret;
  final String? agentId;
  final String? publicKey;
  final int? status;
  final String? createTime;

  const SocialClient({
    this.id,
    required this.name,
    this.socialType,
    this.userType,
    required this.clientId,
    this.clientSecret,
    this.agentId,
    this.publicKey,
    this.status,
    this.createTime,
  });

  factory SocialClient.fromJson(Map<String, dynamic> json) {
    return SocialClient(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      socialType: json['socialType'] as int?,
      userType: json['userType'] as int?,
      clientId: json['clientId'] as String? ?? '',
      clientSecret: json['clientSecret'] as String?,
      agentId: json['agentId'] as String?,
      publicKey: json['publicKey'] as String?,
      status: json['status'] as int?,
      createTime: json['createTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (socialType != null) 'socialType': socialType,
      if (userType != null) 'userType': userType,
      'clientId': clientId,
      if (clientSecret != null) 'clientSecret': clientSecret,
      if (agentId != null) 'agentId': agentId,
      if (publicKey != null) 'publicKey': publicKey,
      if (status != null) 'status': status,
    };
  }
}