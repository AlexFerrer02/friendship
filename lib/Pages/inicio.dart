import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Class/consultas.dart';
import '../Class/evento.dart';
import '../Widgets/listEventoBusqueda.dart';
import '../Widgets/listEventos.dart';
import '../Widgets/listEventosPendientes.dart';

class inicio extends StatefulWidget {
  const inicio({super.key});

  @override
  State<inicio> createState() => inicioState();
}

class inicioState extends State<inicio> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 50,
          child: Text("recomendados",  style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          ),
        ),
        FutureBuilder<List<Evento>>(
          future: Consultas().Recomendaciones(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<Evento> eventos = snapshot.data ?? [];
              return Center(
                child: EventosWidget(eventos: eventos),
              );
            }
          },
        ),
        const SizedBox(
          height: 50,
          child: Text("Pendientes",  style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            ),
          ),
        ),
        FutureBuilder<List<Evento>>(
          future: Consultas().EventosPropios(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<Evento> eventos = snapshot.data ?? [];
              return Expanded(child: Center(
                child: EventosPendientesWidget(eventos: eventos),
              ));
            }
          },
        ),
      ],
    );
  }
}
