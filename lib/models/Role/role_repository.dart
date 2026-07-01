import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stalder/models/Role/role.dart';

class RoleRepository {
  static const String _baseUrl = "https://got.rjlopezdiaz.xyz/api";

  Future<List<Role>?> fetchRoles(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/roles/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      var decodedJson = jsonDecode(response.body) as List;
      return decodedJson.map((item) => Role.fromjson(item)).toList();
    }
    return null;
  }
}