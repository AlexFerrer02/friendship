import 'package:flutter/material.dart';
import 'package:friendship/Class/consultas.dart';
import 'package:friendship/Class/evento.dart';
import 'package:responsive_framework/responsive_wrapper.dart';

import '../Widgets/listEventos.dart';
class RecomendacionPage extends StatelessWidget {

  const RecomendacionPage({super.key});

  // You can perform your search logic here based on the searchTerm

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      maxWidth: 1200,
      minWidth: 480,
      defaultScale: true,
      breakpoints: const [
        ResponsiveBreakpoint.resize(420, name: MOBILE),
        ResponsiveBreakpoint.autoScale(600, name: TABLET),
        ResponsiveBreakpoint.resize(800, name: DESKTOP),
        ResponsiveBreakpoint.autoScale(1700, name: 'XL'),
      ],
      child: Material(
        child: SingleChildScrollView(
            child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 50,
                    child: Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text("De tus amigos",
                          style: TextStyle(
                            fontSize: 25,
                            color: Color.fromRGBO(98, 69, 108, 1),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Google Sans',
                          ),
                        ),
                    ),
                  ),
                  FutureBuilder<List<Evento>>(

                    future: Consultas().EventosAmigos(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
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
                  const SizedBox(height: 80,),
                  const SizedBox(
                    height: 50,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text("Recomendados",
                        style: TextStyle(
                          fontSize: 25,
                          color: Color.fromRGBO(98, 69, 108, 1),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Google Sans',
                        ),
                      ),
                    ),
                  ),
                  FutureBuilder<List<Evento>>(

                    future: Consultas().EventosRecomendados(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
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
                ]
            ),
        ),
      ),
    );
  }
}