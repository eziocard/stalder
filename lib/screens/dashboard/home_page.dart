import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stalder/models/Auth/auth.dart';
import 'package:stalder/screens/components/boxSelector.dart';
import 'package:stalder/screens/dashboard/attendance/attendance_screen.dart';
import 'package:stalder/screens/dashboard/level/level_screen.dart';
import 'package:stalder/screens/dashboard/personal/info_screen.dart';
import 'package:stalder/screens/dashboard/settings/settings_screen.dart';
import 'package:stalder/screens/dashboard/users/users_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  int _currentIndex = 1;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  // ← cada índice es una vista distinta
  late final List<Widget> _screens = [
    InfoScreen(),                
    _buildHomeBody(),            
    SettingsScreen(), 
  ];

  Widget _buildHomeBody() {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Boxselector(
                icon: Icons.people,
                backgroundColor: Colors.blue,
                color: Colors.white,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserScreen())),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Boxselector(
                      icon: Icons.list,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceScreen())),
                      color: Colors.white,
                      backgroundColor: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Boxselector(
                      icon: Icons.info,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InfoScreen())),
                      color: Colors.white,
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Boxselector(
                icon: Icons.analytics,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LevelScreen())),
                color: Colors.white,
                backgroundColor: Colors.green,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Boxselector(
                icon: Icons.logout,
                backgroundColor: Colors.red,
                color: Colors.white,
                onTap: () async => await signOut(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // ← muestra la vista del tab activo
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index), // ← cambia el tab
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Información'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ],
      ),
    );
  }
}