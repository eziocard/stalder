// models/Level/student_level.dart
class StudentLevel {
  final int id;
  final int studentId;
  final String studentName;
  final String studentLastname;
  final String studentEmail;

  StudentLevel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentLastname,
    required this.studentEmail,
  });

  factory StudentLevel.fromJson(Map<String, dynamic> json) {
    return StudentLevel(
      id: json['id'],
      studentId: json['student'],
      studentName: json['student_name'] ?? '',
      studentLastname: json['student_lastname'] ?? '',
      studentEmail: json['student_email'] ?? '',
    );
  }
}