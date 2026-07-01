import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stalder/providers/user_provider.dart';
import 'package:stalder/screens/components/labelRow.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userDetail = context.watch<UserProvider>().userDetail;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Información Personal'),
      ),
      body: userDetail == null
          ? const Center(child: Text('No se encontraron datos del usuario'))
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabelRow(label: 'Nombre', value: '${userDetail.name} ${userDetail.lastname}'),
                    LabelRow(label: 'Email', value: userDetail.email),
                    LabelRow(label: 'Rol', value: userDetail.roleName),
                    LabelRow(label: 'Genero', value: userDetail.gender),
                    LabelRow(label: 'Contacto', value: userDetail.contactNumber),
                    LabelRow(label: 'Contacto de Emergencia', value: userDetail.emergencyContactNumber),
                  ],
                ),
              ),
            ),
    );
  }
}