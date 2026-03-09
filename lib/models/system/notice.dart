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
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      type: json['type'] as int? ?? 0,
      content: json['content'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      remark: json['remark'] as String?,
      creator: json['creator'] as String?,
      createTime: json['createTime'] as String?,
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