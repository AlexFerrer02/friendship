import 'package:flutter/material.dart';

class Cuadrado extends StatelessWidget {
  final String imagePath;
  const Cuadrado({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[250],
        ),
        child: Image.asset(imagePath, height: 40,)

    );
  }
}
