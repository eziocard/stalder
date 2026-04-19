import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stalder/screens/components/entryfield.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerLastname = TextEditingController();
  final TextEditingController _controllerContactNumber = TextEditingController();
  final TextEditingController _controllerContactEmergency = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();

  String? _selectedValue = 'Male';
  int? _selectedValueDropdown;

  Future<void> onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final url = Uri.parse("http://10.0.2.2:8000/api/users/");
        // 👆 Android emulator

        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "name": _controllerName.text,
            "last_name": _controllerLastname.text,
            "contact_number": _controllerContactNumber.text,
            "emergency_contact_number": _controllerContactEmergency.text,
            "email": _controllerEmail.text,
            "gender": _selectedValue,
            "role": _selectedValueDropdown,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Usuario creado. Revisa tu email"),
            ),
          );

          // limpiar formulario
          _formKey.currentState!.reset();
          setState(() {
            _selectedValue = 'Male';
            _selectedValueDropdown = null;
          });

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${response.body}"),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error de conexión: $e"),
          ),
        );
      }
    }
  }



  @override
  void dispose() {
    _controllerName.dispose();
    _controllerLastname.dispose();
    _controllerContactNumber.dispose();
    _controllerContactEmergency.dispose();
    _controllerEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Entryfield(title: 'Name', controller: _controllerName),
                const SizedBox(height: 16.0),
                Entryfield(title: 'Lastname', controller: _controllerLastname),
                const SizedBox(height: 16.0),
                Entryfield(title: 'Contact Number', controller: _controllerContactNumber),
                const SizedBox(height: 16.0),
                Entryfield(title: 'Contact Emergency', controller: _controllerContactEmergency),
                const SizedBox(height: 16.0),
                Entryfield(title: 'Email', controller: _controllerEmail),
                const SizedBox(height: 16.0),

                // Gender
                RadioGroup<String>(
                  groupValue: _selectedValue,
                  onChanged: (value) => setState(() => _selectedValue = value),
                  child: Column(
                    children: const [
                      RadioListTile<String>(
                        title: Text('Male'),
                        value: 'Male',
                      ),
                      RadioListTile<String>(
                        title: Text('Female'),
                        value: 'Female',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16.0),

                // Role dropdown
                DropdownButtonFormField<int>(
                  initialValue: _selectedValueDropdown,
                  hint: const Text('Choose a role'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Student')),
                    DropdownMenuItem(value: 2, child: Text('Coach')),
                    DropdownMenuItem(value: 3, child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedValueDropdown = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) return 'Role is required';
                    return null;
                  },
                ),

                const SizedBox(height: 24.0),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    child: const Text('Register'),
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