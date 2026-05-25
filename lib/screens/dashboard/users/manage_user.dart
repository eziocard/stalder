import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stalder/models/Auth/auth.dart';
import 'package:stalder/models/User/repository/user_repository.dart';
import 'package:stalder/models/User/user_detail.dart';
import 'package:stalder/screens/components/entryfield.dart';

class ManageUser extends StatefulWidget {
  final UserDetail user;
  const ManageUser({super.key, required this.user});

  @override
  State<ManageUser> createState() => _ManageUserState();
}

class _ManageUserState extends State<ManageUser> {
  final User? user = Auth().currentUser;
  final _userRepository = UserRepository();

  late TextEditingController _nameController;
  late TextEditingController _lastnameController;
  late TextEditingController _genderController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _lastnameController = TextEditingController(text: widget.user.lastname);
    _genderController = TextEditingController(text: widget.user.gender);
    _emailController = TextEditingController(text: widget.user.email);
    _contactController = TextEditingController(text: widget.user.contactNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _genderController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    final token = await user?.getIdToken();
    if (token == null) return;

    final fields = <String, dynamic>{};
    if (_nameController.text != widget.user.name) fields['name'] = _nameController.text;
    if (_lastnameController.text != widget.user.lastname) fields['last_name'] = _lastnameController.text;
    if (_genderController.text != widget.user.gender) fields['gender'] = _genderController.text;
    if (_emailController.text != widget.user.email) fields['email'] = _emailController.text;
    if (_contactController.text != widget.user.contactNumber) fields['contact_number'] = _contactController.text;

    if (fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay cambios para guardar')),
      );
      return;
    }

    final result = await _userRepository.updateUser(token, widget.user.id, fields);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario actualizado correctamente')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar')),
      );
    }
  }

  Future<void> _deleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Estás seguro de eliminar a "${widget.user.name} ${widget.user.lastname}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final token = await user?.getIdToken();
    if (token == null) return;

    final success = await _userRepository.deleteUser(token, widget.user.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario eliminado correctamente')),
      );
      Navigator.pop(context, true); // ← vuelve y recarga la lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al eliminar el usuario'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu de usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Eliminar usuario',
            onPressed: _deleteUser,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Entryfield(title: "Name", controller: _nameController),
            const SizedBox(height: 16.0),
            Entryfield(title: "Lastname", controller: _lastnameController),
            const SizedBox(height: 16.0),
            Entryfield(title: "Gender", controller: _genderController),
            const SizedBox(height: 16.0),
            Entryfield(title: "Email", controller: _emailController),
            const SizedBox(height: 16.0),
            Entryfield(title: "Contact", controller: _contactController),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateUser,
                child: const Text('Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}