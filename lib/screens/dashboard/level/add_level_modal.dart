import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stalder/models/Auth/auth.dart';
import 'package:stalder/models/Level/level_repository.dart';
import 'package:stalder/models/User/user_detail.dart';
import 'package:stalder/screens/components/entryfield.dart';

class AddLevelModal extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final List<UserDetail> teachers;

  const AddLevelModal({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.teachers,
  });

  @override
  State<AddLevelModal> createState() => _AddLevelModalState();
}

class _AddLevelModalState extends State<AddLevelModal> {
  final User? firebaseUser = Auth().currentUser;
  final _levelRepository = LevelRepository();

  UserDetail? _selectedTeacher;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!widget.formKey.currentState!.validate()) return;

    final token = await firebaseUser?.getIdToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de autenticación')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _levelRepository.createLevel(token, {
      'name': widget.titleController.text,
      'teacher': _selectedTeacher?.id,
    });

    setState(() => _isLoading = false);

    if (success) {
      widget.titleController.clear();
      setState(() => _selectedTeacher = null);
      Navigator.pop(context, true); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('grupo creado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear el grupo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: widget.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Agregar Nivel',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Entryfield(title: 'Nombre del nivel', controller: widget.titleController),
            const SizedBox(height: 16),

            DropdownButtonFormField<UserDetail>(
              value: _selectedTeacher,
              hint: const Text('Seleccionar profesor'),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                labelText: 'Profesor',
              ),
              items: widget.teachers.map((teacher) {
                return DropdownMenuItem<UserDetail>(
                  value: teacher,
                  child: Text('${teacher.name} ${teacher.lastname}'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedTeacher = value),
              validator: (value) {
                if (value == null) return 'El profesor es requerido';
                return null;
              },
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}