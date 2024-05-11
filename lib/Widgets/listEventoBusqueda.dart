import 'package:flutter/material.dart';
import 'package:friendship/Class/evento.dart';
import 'package:friendship/Widgets/eventoWidget.dart';

import 'eventoWidgetBusqueda.dart';

class ListEventosBusqueda extends StatelessWidget {
  final List<Evento> eventos;

  const ListEventosBusqueda({Key? key, required this.eventos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(eventos.isEmpty){return const Center(child:Text("Ninguna coincidencia"));}
    else{return SizedBox(
      width: 500,
      child: ListView.builder(
        itemCount: (eventos.length / 2).ceil(),
        itemBuilder: (context, index) {
          final firstIndex = index * 2;
          final secondIndex = firstIndex + 1;
          final hasSecondItem = secondIndex < eventos.length;

          return Column(
            children: [
              Row(
                children: [
                  EventoBusquedaWidget(evento: eventos[firstIndex]),
                  if (hasSecondItem) EventoBusquedaWidget(evento: eventos[secondIndex]),
                ],
              ),
              const SizedBox(height: 20), // Espacio entre elementos
            ],
          );
        },
      ),
    );
    }
  }
}
