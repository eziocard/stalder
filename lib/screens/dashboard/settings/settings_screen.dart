import 'package:flutter/material.dart';
import 'package:stalder/main.dart';
import 'package:stalder/screens/dashboard/personal/info_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: Column(
        children: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, themeMode, _) {
              return SwitchListTile(
                title: const Text('Modo oscuro'),
                subtitle: Text(themeMode == ThemeMode.dark ? 'Activado' : 'Desactivado'),
                secondary: Icon(
                  themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                ),
                value: themeMode == ThemeMode.dark,
                onChanged: (isDark) {
                  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
                },
              );
            },
          ),

          const Divider(),

          ListTile(
            title: const Text('Información de cuenta'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => InfoScreen()),
            ),
          ),
        ],
      ),
    );
  }
}