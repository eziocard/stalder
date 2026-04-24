import 'dart:convert';
import 'package:stalder/models/User/user_detail.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  static const String _baseUrl = "http://10.0.2.2:8000/api";

  Future<UserDetail?> fetchUserDetail(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/me/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      var decodedJson = jsonDecode(response.body);
      return UserDetail.fromJson(decodedJson);
    }
    return null;
  }

  Future<List<UserDetail>?> fetchUser(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      var decodedJson = jsonDecode(response.body) as List;
      return decodedJson.map((item) => UserDetail.fromJson(item)).toList();
    }
    return null;
  }

  Future<UserDetail?> updateUser(String token, int id, Map<String, dynamic> fields) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/users/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(fields),
    );
    if (response.statusCode == 200) {
      var decodedJson = jsonDecode(response.body);
      return UserDetail.fromJson(decodedJson);
    }
    return null;
  }

  // ← NUEVO
  Future<bool> createUser(String token, Map<String, dynamic> fields) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(fields),
    );
    return response.statusCode == 201;
  }
}

class StudentRepository {
  static const String _baseUrl = "http://10.0.2.2:8000/api";

  Future<List<UserDetail>?> fetchStudents(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/students/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      var decodedJson = jsonDecode(response.body) as List;
      return decodedJson.map((item) => UserDetail.fromJson(item)).toList();
    }
    return null;
  }
}