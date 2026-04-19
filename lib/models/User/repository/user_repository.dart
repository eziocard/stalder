import 'dart:convert';
import 'package:stalder/models/User/user_detail.dart';
import 'package:http/http.dart' as http;
class UserRepository {
  static const String _baseUrl = "http://10.0.2.2:8000/api";
  Future<UserDetail?> fetchUserDetail(String token) async{
    final response = await http.get(
      Uri.parse('$_baseUrl/users/me/'),
      headers:{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }
    );
    if(response.statusCode == 200){
      var decodedJson = jsonDecode(response.body);
      UserDetail userDetail = UserDetail.fromJson(decodedJson);
      return userDetail;
    } else {
      return null;  
    }}
}