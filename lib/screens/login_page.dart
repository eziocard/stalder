import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stalder/models/Auth/auth.dart';
import 'package:stalder/screens/components/entryfield.dart';


// 👇 CREA ESTA PANTALLA (ejemplo básico)

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String? errorMessage = '';
  bool _isLoading = false;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
  if (!mounted) return;
  setState(() {
    _isLoading = true;
    errorMessage = '';
  });

  try {
    if (_controllerEmail.text.isEmpty || _controllerPassword.text.isEmpty) {
      if (mounted) setState(() { errorMessage = 'Por favor ingresa email y contraseña'; });
      return;
    }

    await Auth().signInWithEmailAndPassword(
      _controllerEmail.text,
      _controllerPassword.text,
    );
    

  } on FirebaseAuthException catch (e) {
    if (mounted) setState(() { errorMessage = e.message; });
  } finally {
    if (mounted) setState(() { _isLoading = false; });
  }
}

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : 'Error: $errorMessage',
      style: const TextStyle(color: Colors.red),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : signInWithEmailAndPassword,
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Login'),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Entryfield(title: 'Email', controller: _controllerEmail),
            const SizedBox(height: 16.0),
            Entryfield(title: 'Password', controller: _controllerPassword, isPassword: true),

            const SizedBox(height: 16.0),
            _submitButton(),
            const SizedBox(height: 8.0),
            _errorMessage(),
          ],
        ),
      ),
    );
  }
}