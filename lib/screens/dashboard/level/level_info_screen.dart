import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stalder/models/Auth/auth.dart';
import 'package:stalder/models/Level/level_detail.dart';
import 'package:stalder/models/Level/level_repository.dart';
import 'package:stalder/models/Role/StudentLevel.dart';
import 'package:stalder/models/User/repository/user_repository.dart';
import 'package:stalder/models/User/user_detail.dart';
import 'package:stalder/screens/dashboard/level/add_student_modal.dart';

class LevelInfoScreen extends StatefulWidget {
  final LevelDetail level;

  const LevelInfoScreen({super.key, required this.level});

  @override
  State<LevelInfoScreen> createState() => _LevelInfoScreenState();
}

class _LevelInfoScreenState extends State<LevelInfoScreen> {
  final User? firebaseUser = Auth().currentUser;
  final _levelRepository = LevelRepository();
  final _userRepository = UserRepository();

  List<StudentLevel> _students = [];
  List<UserDetail> _availableStudents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = await firebaseUser?.getIdToken();
    if (token == null) return;

    final students = await _levelRepository.fetchStudentsByLevel(token, widget.level.id);
    final allUsers = await _userRepository.fetchUser(token);

    final enrolledIds = students?.map((s) => s.studentId).toSet() ?? {};
    final available = allUsers
            ?.where((u) => u.roleName == 'Student' && !enrolledIds.contains(u.id))
            .toList() ??
        [];
    if (!mounted) return;
    setState(() {
      _students = students ?? [];
      _availableStudents = available;
      _isLoading = false;
    });
  }

  void _showAddStudentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddStudentModal(
        students: _availableStudents,
        onAdd: (student) async {
          final token = await firebaseUser?.getIdToken();
          if (token == null) return;
          final success = await _levelRepository.addStudentToLevel(
            token,
            widget.level.id,
            student.id,
          );
          if (success) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Alumno agregado correctamente')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error al agregar alumno')),
            );
          }
        },
      ),
    ).then((added) {
      if (added == true) _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.level.name)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info del nivel
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.level.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16),
                          const SizedBox(width: 4),
                          Text('${widget.level.teacherName} ${widget.level.teacherLastname}'),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Alumnos inscritos (${_students.length})',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),

                // Lista de alumnos
                Expanded(
                  child: _students.isEmpty
                      ? const Center(child: Text('No hay alumnos inscritos'))
                      : ListView.builder(
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final s = _students[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(s.studentName[0].toUpperCase()),
                              ),
                              title: Text('${s.studentName} ${s.studentLastname}'),
                              subtitle: Text(s.studentEmail),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () async {
                                  final token = await firebaseUser?.getIdToken();
                                  if (token == null) return;
                                  final success = await _levelRepository.removeStudentFromLevel(
                                    token,
                                    widget.level.id,
                                    s.studentId,
                                  );
                                  if (success) _loadData();
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}