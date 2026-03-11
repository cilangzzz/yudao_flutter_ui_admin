/// 学生课程模型 - Demo03 子表
class Demo03Course {
  final int? id;
  final int? studentId;
  final String name;
  final int score;

  Demo03Course({
    this.id,
    this.studentId,
    required this.name,
    this.score = 0,
  });

  factory Demo03Course.fromJson(Map<String, dynamic> json) {
    return Demo03Course(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      studentId: json['studentId'] is int ? json['studentId'] : int.tryParse(json['studentId']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      score: json['score'] is int ? json['score'] : int.tryParse(json['score']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (studentId != null) 'studentId': studentId,
      'name': name,
      'score': score,
    };
  }

  Demo03Course copyWith({
    int? id,
    int? studentId,
    String? name,
    int? score,
  }) {
    return Demo03Course(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      score: score ?? this.score,
    );
  }
}

/// 学生班级模型 - Demo03 子表
class Demo03Grade {
  final int? id;
  final int? studentId;
  final String name;
  final String teacher;

  Demo03Grade({
    this.id,
    this.studentId,
    required this.name,
    required this.teacher,
  });

  factory Demo03Grade.fromJson(Map<String, dynamic> json) {
    return Demo03Grade(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      studentId: json['studentId'] is int ? json['studentId'] : int.tryParse(json['studentId']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      teacher: json['teacher']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (studentId != null) 'studentId': studentId,
      'name': name,
      'teacher': teacher,
    };
  }

  Demo03Grade copyWith({
    int? id,
    int? studentId,
    String? name,
    String? teacher,
  }) {
    return Demo03Grade(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
    );
  }
}

/// 学生模型 - Demo03 (主子表)
class Demo03Student {
  final int? id;
  final String name;
  final int sex;
  final int? birthday;
  final String? description;
  final String? createTime;
  final Demo03Grade? demo03Grade;
  final List<Demo03Course>? demo03Courses;

  Demo03Student({
    this.id,
    required this.name,
    this.sex = 1,
    this.birthday,
    this.description,
    this.createTime,
    this.demo03Grade,
    this.demo03Courses,
  });

  factory Demo03Student.fromJson(Map<String, dynamic> json) {
    return Demo03Student(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      sex: json['sex'] is int ? json['sex'] : int.tryParse(json['sex']?.toString() ?? '') ?? 1,
      birthday: json['birthday'] is int ? json['birthday'] : int.tryParse(json['birthday']?.toString() ?? ''),
      description: json['description']?.toString(),
      createTime: json['createTime']?.toString(),
      demo03Grade: json['demo03Grade'] != null
          ? Demo03Grade.fromJson(json['demo03Grade'])
          : null,
      demo03Courses: json['demo03Courses'] != null
          ? (json['demo03Courses'] as List).map((e) => Demo03Course.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'sex': sex,
      if (birthday != null) 'birthday': birthday,
      if (description != null) 'description': description,
      if (demo03Grade != null) 'demo03Grade': demo03Grade!.toJson(),
      if (demo03Courses != null) 'demo03Courses': demo03Courses!.map((e) => e.toJson()).toList(),
    };
  }

  Demo03Student copyWith({
    int? id,
    String? name,
    int? sex,
    int? birthday,
    String? description,
    String? createTime,
    Demo03Grade? demo03Grade,
    List<Demo03Course>? demo03Courses,
  }) {
    return Demo03Student(
      id: id ?? this.id,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      birthday: birthday ?? this.birthday,
      description: description ?? this.description,
      createTime: createTime ?? this.createTime,
      demo03Grade: demo03Grade ?? this.demo03Grade,
      demo03Courses: demo03Courses ?? this.demo03Courses,
    );
  }
}