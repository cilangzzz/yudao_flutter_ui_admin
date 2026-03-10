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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      socialType: json['socialType'] is int ? json['socialType'] : int.tryParse(json['socialType']?.toString() ?? ''),
      userType: json['userType'] is int ? json['userType'] : int.tryParse(json['userType']?.toString() ?? ''),
      clientId: json['clientId']?.toString() ?? '',
      clientSecret: json['clientSecret']?.toString(),
      agentId: json['agentId']?.toString(),
      publicKey: json['publicKey']?.toString(),
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? ''),
      createTime: json['createTime']?.toString(),
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