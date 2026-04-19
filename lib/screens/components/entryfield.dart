import 'package:flutter/material.dart';

class Entryfield extends StatelessWidget {
  final String? title;
  final TextEditingController? controller;
  final bool isPassword;

  const Entryfield({super.key, this.title, this.controller, this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: title,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$title is required';
        }
        return null;
      },
    );
  }
}