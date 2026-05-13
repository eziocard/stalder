// models/Attendance/attendance_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stalder/models/attendance/attendance.dart';

class AttendanceRepository {
  static const String _baseUrl = "http://10.0.2.2:8000/api";

  // GET /api/attendance/by_level/?level_id=1&date=2026-05-01
  Future<List<Attendance>?> fetchByLevel(String token, int levelId, String date) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/attendance/by_level/?level_id=$levelId&date=$date'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      var decodedJson = jsonDecode(response.body) as List;
      return decodedJson.map((item) => Attendance.fromJson(item)).toList();
    }
    return null;
  }

  // GET /api/attendance/by_student/?student_id=1
  Future<List<Attendance>?> fetchByStudent(String token, int studentId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/attendance/by_student/?student_id=$studentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      var decodedJson = jsonDecode(response.body) as List;
      return decodedJson.map((item) => Attendance.fromJson(item)).toList();
    }
    return null;
  }

  // POST /api/attendance/bulk/
  Future<bool> bulkCreate(String token, int levelId, String date, int recordedById, List<Map<String, dynamic>> attendances) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/attendance/bulk/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'level': levelId,
        'date': date,
        'recorded_by': recordedById,
        'attendances': attendances,
      }),
    );
    return response.statusCode == 201;
  }

  // PATCH /api/attendance/bulk_update/
  Future<bool> bulkUpdate(String token, int levelId, String date, List<Map<String, dynamic>> attendances) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/attendance/bulk_update/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'level': levelId,
        'date': date,
        'attendances': attendances,
      }),
    );
    return response.statusCode == 200;
  }
}