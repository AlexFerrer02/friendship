import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final int maxLength;

  const PhoneTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.maxLength = 9,
  }): super(key: key);



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        maxLength: maxLength,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Esto permite solo números
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade500),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Este campo es obligatorio';
          } else if (value.length != maxLength) {
            return 'Debe tener exactamente $maxLength letras';
          }
          return null; // La validación es exitosa
        },
      ),
    );
  }
}
/*
extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }
}*/