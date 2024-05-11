import 'package:flutter/material.dart';
import 'package:friendship/Class/filtro.dart';

class FiltroWidget extends StatelessWidget {
  final Filtro filtro;

  const FiltroWidget({super.key, required this.filtro});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.black12),
      width: 50,
      height: 20,
      child: Center(
          child: Text(
        filtro.nombre,
        style: const TextStyle(fontSize: 10, color: Color.fromRGBO(98, 69, 108, 1)),
      )),
    );
  }
}
