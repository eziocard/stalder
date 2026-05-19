import 'package:flutter/material.dart';
import 'package:stalder/main.dart';
import 'package:stalder/screens/dashboard/personal/info_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = MainApp.of(context);

    final isDark = appState.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Modo oscuro'),
            value: isDark,
            onChanged: (value) {
              appState.changeTheme(value);
            },
          ),

          ListTile(
            title: const Text('Información de cuenta'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InfoScreen())),
          ),
        ],
      ),
    );
  }
}