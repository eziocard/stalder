import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stalder/models/Auth/auth.dart';
import 'package:stalder/providers/user_provider.dart';
import 'package:stalder/screens/components/boxSelector.dart';
import 'package:stalder/screens/dashboard/attendance/attendance_screen.dart';
import 'package:stalder/screens/dashboard/level/level_screen.dart';
import 'package:stalder/screens/dashboard/settings/settings_screen.dart';
import 'package:stalder/screens/dashboard/users/users_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _buildHomeBody(UserProvider userProvider) {
    final isAdmin = userProvider.isAdmin;
    final isCoach = userProvider.isCoach;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Boxselector(
                  icon: Icons.people,
                  backgroundColor: Colors.blue,
                  color: Colors.white,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UserScreen()),
                  ),
                ),
              ),
            if (isAdmin || isCoach)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Boxselector(
                  icon: Icons.list,
                  color: Colors.white,
                  backgroundColor: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                  ),
                ),
              ),
            if (isAdmin || isCoach)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Boxselector(
                  icon: Icons.analytics,
                  color: Colors.white,
                  backgroundColor: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LevelScreen()),
                  ),
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
    final userProvider = context.watch<UserProvider>();

    if (userProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screens = [
      _buildHomeBody(userProvider),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ],
      ),
    );
  }
}