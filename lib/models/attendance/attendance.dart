class Attendance {
  final int id;
  final int studentId;
  final String studentName;
  final String studentLastname;
  final int levelId;
  final String levelName;
  final int? recordedById;
  final String? recordedByName;
  final String date;
  final String status;
  final String? notes;
  final String createdAt;

  Attendance({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentLastname,
    required this.levelId,
    required this.levelName,
    this.recordedById,
    this.recordedByName,
    required this.date,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      studentId: json['student'],
      studentName: json['student_name'] ?? '',
      studentLastname: json['student_lastname'] ?? '',
      levelId: json['level'],
      levelName: json['level_name'] ?? '',
      recordedById: json['recorded_by'],
      recordedByName: json['recorded_by_name'],
      date: json['date'] ?? '',
      status: json['status'] ?? 'present',
      notes: json['notes'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student': studentId,
      'level': levelId,
      'recorded_by': recordedById,
      'date': date,
      'status': status,
      'notes': notes,
    };
  }
}