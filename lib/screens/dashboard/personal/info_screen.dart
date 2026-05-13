import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stalder/models/Auth/auth.dart';
import 'package:stalder/models/User/repository/user_repository.dart';
import 'package:stalder/models/User/user_detail.dart';
import 'package:stalder/screens/components/labelRow.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final User? user = Auth().currentUser;
  final _userRepository = UserRepository();
  Future<UserDetail?> _fetchUserDetail() async {
    final token = await user?.getIdToken();
    if (token == null) return null;
    return await _userRepository.fetchUserDetail(token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información Personal'),
        ),
        body: FutureBuilder<UserDetail?>(
        future: _fetchUserDetail(),
        builder: (context, snapshot) {
          // Cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Sin datos
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No se encontraron datos del usuario'));
          }

          final userDetail = snapshot.data!;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabelRow(label: 'Nombre', value: '${userDetail.name} ${userDetail.lastname}' ),
                  LabelRow(label: 'Email', value: userDetail.email),
                  LabelRow(label: 'Rol', value: userDetail.roleName),
                  LabelRow(label: 'Genero', value: userDetail.gender),
                  LabelRow(label: 'Contacto', value: userDetail.contactNumber),
                  LabelRow(label: 'Contacto de Emergencia', value: userDetail.emergencyContactNumber),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}