import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stalder/models/Auth/auth.dart';
import 'package:stalder/models/User/repository/user_repository.dart';
import 'package:stalder/screens/components/entryfield.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _userRepository = UserRepository();
  final User? firebaseUser = Auth().currentUser;

  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerLastname = TextEditingController();
  final TextEditingController _controllerContactNumber = TextEditingController();
  final TextEditingController _controllerContactEmergency = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();

  String? _selectedGender = 'Male';
  int? _selectedRoleId;
  bool _isLoading = false;

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerLastname.dispose();
    _controllerContactNumber.dispose();
    _controllerContactEmergency.dispose();
    _controllerEmail.dispose();
    super.dispose();
  }

  Future<void> onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await firebaseUser?.getIdToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de autenticación')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _userRepository.createUser(token, {
      "name": _controllerName.text,
      "last_name": _controllerLastname.text,
      "contact_number": _controllerContactNumber.text,
      "emergency_contact_number": _controllerContactEmergency.text,
      "email": _controllerEmail.text,
      "gender": _selectedGender,
      "role": _selectedRoleId,
    });

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario creado. Revisa tu email')),
      );
      _formKey.currentState!.reset();
      setState(() {
        _selectedGender = 'Male';
        _selectedRoleId = null;
      });
      Navigator.pop(context); // vuelve a la lista y recarga
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear el usuario')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Entryfield(title: 'Nombre', controller: _controllerName),
                const SizedBox(height: 16),
                Entryfield(title: 'Apellido', controller: _controllerLastname),
                const SizedBox(height: 16),
                Entryfield(title: 'Número de Contacto', controller: _controllerContactNumber),
                const SizedBox(height: 16),
                Entryfield(title: 'Contacto de Emergencia', controller: _controllerContactEmergency),
                const SizedBox(height: 16),
                Entryfield(title: 'Email', controller: _controllerEmail),
                const SizedBox(height: 16),

                // Gender
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Género', style: TextStyle(fontWeight: FontWeight.w500)),
                    RadioListTile<String>(
                      title: const Text('Hombre'),
                      value: 'Male',
                      groupValue: _selectedGender,
                      onChanged: (value) => setState(() => _selectedGender = value),
                    ),
                    RadioListTile<String>(
                      title: const Text('Mujer'),
                      value: 'Female',
                      groupValue: _selectedGender,
                      onChanged: (value) => setState(() => _selectedGender = value),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Role dropdown - hardcodeado igual que antes
                DropdownButtonFormField<int>(
                  value: _selectedRoleId,
                  hint: const Text('Elige un rol'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Alumno')),
                    DropdownMenuItem(value: 2, child: Text('Entrenador')),
                    DropdownMenuItem(value: 3, child: Text('Administrador')),
                  ],
                  onChanged: (value) => setState(() => _selectedRoleId = value),
                  validator: (value) => value == null ? 'El rol es requerido' : null,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : onSubmit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Registrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}