
import 'package:flutter/material.dart';

class Boxselector extends StatelessWidget {
  final IconData icon;       
  final VoidCallback onTap;
  final Color color;
  final Color backgroundColor;
  const Boxselector({super.key, required this.icon, required this.onTap, required this.color, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, 
        height: 120,  
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16)
        ),
        child:Padding(padding: const EdgeInsets.all(25),
        child: Icon(icon,size: 80,color: color,)) ,
      ),
    );
  }
}