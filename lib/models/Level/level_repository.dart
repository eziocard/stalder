import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stalder/models/Level/level_detail.dart';

import 'package:stalder/models/Role/StudentLevel.dart';

class LevelRepository {
  static const String _baseUrl = "http://10.0.2.2:8000/api";

  Future<List<LevelDetail>?> fetchLevels(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/levels/'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      var decodedJson = jsonDecode(response.body) as List;
      return decodedJson.map((item) => LevelDetail.fromJson(item)).toList();
    }
    return null;
  }

  Future<bool> createLevel(String token, Map<String, dynamic> fields) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/levels/'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode(fields),
    );
    return response.statusCode == 201;
  }

  Future<List<StudentLevel>?> fetchStudentsByLevel(String token, int levelId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/levels/$levelId/students/'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      var decodedJson = jsonDecode(response.body) as List;
      return decodedJson.map((item) => StudentLevel.fromJson(item)).toList();
    }
    return null;
  }

  Future<bool> addStudentToLevel(String token, int levelId, int studentId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/levels/$levelId/add_student/'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'student': studentId}),
    );
    return response.statusCode == 201;
  }

  Future<bool> removeStudentFromLevel(String token, int levelId, int studentId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/levels/$levelId/remove_student/'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'student': studentId}),
    );
    return response.statusCode == 204;
  }
}