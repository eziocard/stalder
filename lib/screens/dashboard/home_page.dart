import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stalder/models/Auth/auth.dart';
import 'package:stalder/screens/components/boxSelector.dart';
import 'package:stalder/screens/dashboard/attendance/attendance_screen.dart';
import 'package:stalder/screens/dashboard/info_screen.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final User? user = Auth().currentUser;
  

  Future<void> signOut() async {
    await Auth().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Boxselector(icon: Icons.people,backgroundColor: Colors.blue,color: Colors.white, onTap: (){print('informacon');})),
             Padding(
  padding: const EdgeInsets.all(12),
  child: Row(
    children: [
      Expanded(
        child: Boxselector(
          icon: Icons.list,
          onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => AttendanceScreen())),
          color: Colors.white,
          backgroundColor: Colors.orange,
        ),
      ),
      const SizedBox(width: 12), // espacio entre los dos
      Expanded(
        child: Boxselector(
          icon: Icons.info,
          onTap:() => Navigator.push(context,MaterialPageRoute(builder: (context) => InfoScreen())),
          color: Colors.white,
          backgroundColor: Colors.orange,
        ),
      ),
    ],
  ),
),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Boxselector(icon: Icons.logout,backgroundColor: Colors.red,color: Colors.white, onTap: () async => await signOut()) ),
          
         
        ],
      )
    );
  }


  }
