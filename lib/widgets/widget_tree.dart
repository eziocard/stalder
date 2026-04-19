import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages

import 'package:stalder/models/Auth/auth.dart';
import 'package:stalder/screens/dashboard/home_page.dart';
import 'package:stalder/screens/login_page.dart';


class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(stream: Auth().authStateChanges, builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.active) {
        User? user = snapshot.data;
        if (user == null) {
          return const LoginPage();
        } else {
          return HomePage();
        }
      } else {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    });
  }
}