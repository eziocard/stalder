import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stalder/models/User/repository/user_repository.dart';
import 'package:stalder/models/User/user_detail.dart';

class UserProvider extends ChangeNotifier {
  final _userRepository = UserRepository();

  User? firebaseUser;
  UserDetail? userDetail;
  bool isLoading = true;

  bool get isAdmin => userDetail?.roleName == 'Administrador';
  bool get isCoach => userDetail?.roleName == 'Entrenador';

 Future<void> loadUser(User user) async {
  firebaseUser = user;
  isLoading = true;
  notifyListeners();

  final token = await user.getIdToken();
  print('TOKEN: ${token != null ? token.substring(0, 20) : "NULL"}');
  
  if (token != null) {
    userDetail = await _userRepository.fetchUserDetail(token);
    print('USER DETAIL: ${userDetail?.name ?? "NULL"}');
  }

  isLoading = false;
  notifyListeners();
}

  Future<String?> getToken() async {
    return await firebaseUser?.getIdToken();
  }

  void clear() {
    firebaseUser = null;
    userDetail = null;
    isLoading = false;
    notifyListeners();
  }
}