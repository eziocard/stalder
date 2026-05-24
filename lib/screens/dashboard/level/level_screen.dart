import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stalder/models/Auth/auth.dart';
import 'package:stalder/models/Level/level_detail.dart';
import 'package:stalder/models/Level/level_repository.dart';
import 'package:stalder/models/User/repository/user_repository.dart';
import 'package:stalder/models/User/user_detail.dart';
import 'package:stalder/screens/components/cardlevel.dart';
import 'package:stalder/screens/dashboard/level/add_level_modal.dart';
import 'package:stalder/screens/dashboard/level/level_info_screen.dart';

class LevelScreen extends StatefulWidget {
  final UserDetail? currentUser; 

  const LevelScreen({super.key, this.currentUser});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  final User? firebaseUser = Auth().currentUser;
  final _levelRepository = LevelRepository();
  final _userRepository = UserRepository();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  List<LevelDetail> _levels = [];
  List<UserDetail> _teachers = [];
  bool _isLoading = true;

  bool get _isAdmin => widget.currentUser?.roleName == 'Administrador';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final token = await firebaseUser?.getIdToken();
    if (token == null) return;

    final levels = await _levelRepository.fetchLevels(token);
    final teachers = await _userRepository.fetchTeachers(token);

    if (!mounted) return;

    List<LevelDetail> filteredLevels = levels ?? [];
    if (!_isAdmin && widget.currentUser != null) {
      filteredLevels = filteredLevels.where((l) =>
        l.teacherId == widget.currentUser!.id
      ).toList();
    }

    setState(() {
      _levels = filteredLevels;
      _teachers = teachers ?? [];
      _isLoading = false;
    });
  }

  void _showAddLevelModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddLevelModal(
        formKey: _formKey,
        titleController: _titleController,
        teachers: _teachers,
      ),
    ).then((created) {
      if (created == true) _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manejo de Grupos')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _levels.isEmpty
              ? const Center(child: Text('No hay Grupos registrados'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _levels.length,
                  itemBuilder: (context, index) {
                    return Cardlevel(
                      level: _levels[index],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LevelInfoScreen(level: _levels[index],currentUser: widget.currentUser,),
                        ),
                      ).then((_) => _loadData()),
                    );
                  },
                ),

   
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: _showAddLevelModal,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}