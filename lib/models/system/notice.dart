/// 通知公告模型
class Notice {
  final int? id;
  final String title;
  final int type;
  final String content;
  final int status;
  final String? remark;
  final String? creator;
  final String? createTime;

  Notice({
    this.id,
    required this.title,
    this.type = 0,
    this.content = '',
    this.status = 0,
    this.remark,
    this.creator,
    this.createTime,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      title: json['title']?.toString() ?? '',
      type: json['type'] is int ? json['type'] : int.tryParse(json['type']?.toString() ?? '') ?? 0,
      content: json['content']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      remark: json['remark']?.toString(),
      creator: json['creator']?.toString(),
      createTime: json['createTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'type': type,
      'content': content,
      'status': status,
      if (remark != null) 'remark': remark,
    };
  }
}