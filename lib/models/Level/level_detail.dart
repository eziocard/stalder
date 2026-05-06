class LevelDetail {
  final int id;
  final String name;
  final int? teacherId;
  final String teacherName;
  final String teacherLastname;

  LevelDetail({
    required this.id,
    required this.name,
    this.teacherId,
    required this.teacherName,
    required this.teacherLastname,
  });

  factory LevelDetail.fromJson(Map<String, dynamic> json) {
    return LevelDetail(
      id: json['id'],
      name: json['name'],
      teacherId: json['teacher'],
      teacherName: json['teacher_name'] ?? '',
      teacherLastname: json['teacher_lastname'] ?? '',
    );
  }
}