import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stalder/models/Auth/auth.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String ? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        _controllerEmail.text,
        _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
         if (_controllerEmail.text.isEmpty && _controllerPassword.text.isEmpty) {
          errorMessage = 'Please enter email or password';          
        }
        print('ERROR: ${e.message}');
      });
    }
  }


  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        _controllerEmail.text,
        _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
        if (_controllerEmail.text.isEmpty && _controllerPassword.text.isEmpty) {
          errorMessage = 'Please enter email or password';          
        }

        if(errorMessage == 'The email address is already in use by another account.'){
          errorMessage = 'The email address is already in use by another account. Please try again with a different email.';
        }
      });
    }
  }


  Widget _entryField(String title, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: title,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Error: $errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      child: Text(isLogin ? 'Login' : 'Register'),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(isLogin ? 'Don\'t have an account? Register' : 'Already have an account? Login'),
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
            _entryField('Email', _controllerEmail),
            const SizedBox(height: 16.0),
            _entryField('Password', _controllerPassword, isPassword: true),
            const SizedBox(height: 16.0),
            _submitButton(),
            _loginOrRegisterButton(),
            _errorMessage(),
          ],
        ),
      ),
    );
  }
}