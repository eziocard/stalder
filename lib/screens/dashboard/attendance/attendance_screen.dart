import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stalder/models/Auth/auth.dart';
import 'package:stalder/models/Level/level_detail.dart';
import 'package:stalder/models/Level/level_repository.dart';
import 'package:stalder/models/Role/StudentLevel.dart';
import 'package:stalder/models/User/repository/user_repository.dart';
import 'package:stalder/models/attendance/attendance_repository.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final User? firebaseUser = Auth().currentUser;
  final _levelRepository = LevelRepository();
  final _attendanceRepository = AttendanceRepository();
  final _userRepository = UserRepository();

  List<LevelDetail> _levels = [];
  LevelDetail? _selectedLevel;
  List<StudentLevel> _students = [];
  Map<int, String> _attendanceMap = {}; 
  bool _isLoadingLevels = true;
  bool _isLoadingStudents = false;
  bool _isSaving = false;
  bool _isEditing = false; // ← modo edición
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _statusOptions = [
    {'value': 'present',   'label': 'Presente',    'color': Colors.green,  'icon': Icons.check_circle},
    {'value': 'absent',    'label': 'Ausente',     'color': Colors.red,    'icon': Icons.cancel},
    {'value': 'late',      'label': 'Atrasado',    'color': Colors.orange, 'icon': Icons.watch_later},
    {'value': 'justified', 'label': 'Justificado', 'color': Colors.blue,   'icon': Icons.assignment},
  ];

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    final token = await firebaseUser?.getIdToken();
    if (token == null) return;

    final levels = await _levelRepository.fetchLevels(token);

    if (!mounted) return;
    setState(() {
      _levels = levels ?? [];
      _isLoadingLevels = false;
    });
  }

  Future<void> _loadStudents(int levelId) async {
    setState(() => _isLoadingStudents = true);

    final token = await firebaseUser?.getIdToken();
    if (token == null) return;

    final students = await _levelRepository.fetchStudentsByLevel(token, levelId);

    // Verifica si ya existe asistencia para este nivel y fecha
    final dateStr = _formatDate(_selectedDate);
    final existing = await _attendanceRepository.fetchByLevel(token, levelId, dateStr);

    if (!mounted) return;

  
    final attendanceMap = <int, String>{};
    if (existing != null && existing.isNotEmpty) {
      for (final a in existing) {
        attendanceMap[a.studentId] = a.status;
      }
      setState(() => _isEditing = true);
    } else {
      // Por defecto todos presentes
      for (final s in students ?? []) {
        attendanceMap[s.studentId] = 'present';
      }
      setState(() => _isEditing = false);
    }

    setState(() {
      _students = students ?? [];
      _attendanceMap = attendanceMap;
      _isLoadingStudents = false;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      if (_selectedLevel != null) {
        _loadStudents(_selectedLevel!.id);
      }
    }
  }

  Future<void> _saveAttendance() async {
    if (_selectedLevel == null || _students.isEmpty) return;

    final token = await firebaseUser?.getIdToken();
    if (token == null) return;

  
    final me = await _userRepository.fetchUserDetail(token);
    if (me == null) return;

    setState(() => _isSaving = true);

    final attendances = _attendanceMap.entries.map((e) => {
      'student': e.key,
      'status': e.value,
    }).toList();

    bool success;

    if (_isEditing) {
      // Modifica asistencia existente
      success = await _attendanceRepository.bulkUpdate(
        token,
        _selectedLevel!.id,
        _formatDate(_selectedDate),
        attendances,
      );
    } else {
      // Crea nueva asistencia
      success = await _attendanceRepository.bulkCreate(
        token,
        _selectedLevel!.id,
        _formatDate(_selectedDate),
        me.id,
        attendances,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? _isEditing
                  ? 'Asistencia actualizada correctamente'
                  : 'Asistencia registrada correctamente'
              : 'Error al guardar asistencia',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) setState(() => _isEditing = true);
  }

  Color _statusColor(String status) {
    return _statusOptions.firstWhere(
      (s) => s['value'] == status,
      orElse: () => {'color': Colors.grey},
    )['color'] as Color;
  }

  IconData _statusIcon(String status) {
    return _statusOptions.firstWhere(
      (s) => s['value'] == status,
      orElse: () => {'icon': Icons.help},
    )['icon'] as IconData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencia'),
        actions: [
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: const Text('Editando', style: TextStyle(fontSize: 12)),
                backgroundColor: Colors.orange.shade100,
              ),
            ),
        ],
      ),
      body: _isLoadingLevels
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [

                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color.fromARGB(125, 11, 127, 162),
                  child: Column(
                    children: [
                      // Fecha
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(_selectedDate),
                                style: const TextStyle(fontSize: 15),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      
                      DropdownButtonFormField<LevelDetail>(
                        value: _selectedLevel,
                        hint: const Text('Seleccionar grupo'),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.group),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        items: _levels.map((level) {
                          return DropdownMenuItem<LevelDetail>(
                            value: level,
                            child: Text(level.name),
                          );
                        }).toList(),
                        onChanged: (level) {
                          setState(() => _selectedLevel = level);
                          if (level != null) _loadStudents(level.id);
                        },
                      ),
                    ],
                  ),
                ),

                // Lista de alumnos
                Expanded(
                  child: _selectedLevel == null
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.group, size: 64, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Selecciona un grupo para pasar asistencia'),
                            ],
                          ),
                        )
                      : _isLoadingStudents
                          ? const Center(child: CircularProgressIndicator())
                          : _students.isEmpty
                              ? const Center(child: Text('No hay alumnos en este grupo'))
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: _students.length,
                                  itemBuilder: (context, index) {
                                    final s = _students[index];
                                    final status = _attendanceMap[s.studentId] ?? 'present';

                                    return Card(
                                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        child: Row(
                                          children: [
                                            // Avatar
                                            CircleAvatar(
                                              backgroundColor: _statusColor(status).withOpacity(0.2),
                                              child: Icon(
                                                _statusIcon(status),
                                                color: _statusColor(status),
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // Nombre
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${s.studentName} ${s.studentLastname}',
                                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                                  ),
                                                  Text(
                                                    s.studentEmail,
                                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Selector de estado
                                            DropdownButton<String>(
                                              value: status,
                                              underline: const SizedBox(),
                                              icon: const SizedBox(),
                                              items: _statusOptions.map((opt) {
                                                return DropdownMenuItem<String>(
                                                  value: opt['value'] as String,
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        opt['icon'] as IconData,
                                                        color: opt['color'] as Color,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        opt['label'] as String,
                                                        style: TextStyle(
                                                          color: opt['color'] as Color,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(() => _attendanceMap[s.studentId] = value);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                ),

                // Botón guardar
                if (_selectedLevel != null && _students.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveAttendance,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                _isEditing ? 'Actualizar Asistencia' : 'Guardar Asistencia',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}