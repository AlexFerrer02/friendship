import 'dart:math';

import 'package:flutter/material.dart';
import 'package:friendship/Class/evento.dart';
import 'package:friendship/Widgets/filtroWidget.dart';

import '../Class/filtro.dart';

class EventoBusquedaWidget extends StatelessWidget {
  final Evento evento;

  const EventoBusquedaWidget({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    const double width = 200;
    final Random random = Random();
    final List<Color> colores = [
      const Color(0xFFD287F6),
      //Color(0xFF84CEEB),
      //Color(0xFFFFB347),
      //Color(0xFF20BD8E),
    ];

    Color getColor() {
      return colores[random.nextInt(colores.length)];
    }
    Color colorSeleccionado = getColor();
    return GestureDetector(
        onLongPress: () {},
        child: SizedBox(
          width: width,
          height: (width),
          child: Card(
            color: colorSeleccionado,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text(
                    evento.name,
                    style: const TextStyle(fontSize: 25),
                  ),
                  subtitle: Text(
                    evento.descripcion,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    softWrap: true,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Row(children: <Widget>[
                      FiltroWidget(filtro: Filtro(1,evento.filtros.isNotEmpty ? evento.filtros[0] : "")),
                      const SizedBox(
                        width: 10,
                      ),
                      FiltroWidget(filtro: Filtro(2,evento.filtros.length > 1 ? evento.filtros[1] : ""))
                    ]),
                    Container(
                        padding: const EdgeInsets.only(left: 30),
                        child: IconButton(
                          style: const ButtonStyle(
                            backgroundColor:
                            MaterialStatePropertyAll(Colors.black12),
                          ),
                          onPressed: () => {},
                          icon: const Center(child: Icon(Icons.share_rounded)),
                        )),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
