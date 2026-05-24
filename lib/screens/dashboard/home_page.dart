import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stalder/models/Auth/auth.dart';
import 'package:stalder/models/User/repository/user_repository.dart';
import 'package:stalder/models/User/user_detail.dart';
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
  final User? firebaseUser = Auth().currentUser;
  final _userRepository = UserRepository();

  int _currentIndex = 0;
  UserDetail? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final token = await firebaseUser?.getIdToken();
    if (token == null) return;
    final user = await _userRepository.fetchUserDetail(token);
    if (!mounted) return;
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  bool get _isAdmin => _currentUser?.roleName == 'Administrador';
  bool get _isCoach => _currentUser?.roleName == 'Entrenador';

  late final List<Widget> _screens = [
    _buildHomeBody(),
    SettingsScreen(),
  ];

  Widget _buildHomeBody() {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        child: Column(
          children: [
   
            if (_isAdmin)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Boxselector(
                  icon: Icons.people,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  color: Colors.white,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UserScreen()),
                  ),
                ),
              ),

            if (_isAdmin || _isCoach)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Boxselector(
                  icon: Icons.list,
                  color: Colors.white,
                  backgroundColor: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AttendanceScreen(currentUser: _currentUser)),
                  ),
                ),
              ),

            if (_isAdmin || _isCoach)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Boxselector(
                  icon: Icons.analytics,
                  color: Colors.white,
                  backgroundColor: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LevelScreen(currentUser: _currentUser),
                    ),
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
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _screens[_currentIndex],
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