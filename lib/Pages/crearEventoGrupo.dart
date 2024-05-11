import 'dart:ui';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:friendship/Pages//create-event.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart' as provider;

import '../Class/appbar.dart';
import 'home.dart';

class CrearEventoGrupo extends StatefulWidget {
  late bool isFriendGroup;
  CrearEventoGrupo({super.key, required this.isFriendGroup});

  @override
  CrearEventoGrupoState createState() => CrearEventoGrupoState();
}

class CrearEventoGrupoState extends State<CrearEventoGrupo> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var controller = EventController();

    return CalendarControllerProvider(
      controller: controller,
      child: MaterialApp(
          builder: (context, widget) => ResponsiveWrapper.builder(
            ClampingScrollWrapper.builder(context, widget!),
            breakpoints: const [
              ResponsiveBreakpoint.resize(350, name: MOBILE),
              ResponsiveBreakpoint.autoScale(600, name: TABLET),
              ResponsiveBreakpoint.resize(800, name: DESKTOP),
              ResponsiveBreakpoint.autoScale(1700, name: 'XL'),
            ],
          ),
          title: "friend.ship",
          theme: ThemeData(primarySwatch: Colors.indigo),
          scrollBehavior: ScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.trackpad,
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
            },
          ),
          home: Scaffold(
              appBar: AppBar(title: const Text("Crear Evento"), centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => Home(indiceInicial: 2,isFriendGroup: false,)),
                    );
                    provider.Provider.of<AppBarProvider>(context, listen: false).updateAppBar(
                      AppBar(title: const Text("Grupos de amigos"), centerTitle: true,
                        flexibleSpace: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[300]!, // Color del borde sombreado
                                width: 3.0, // Ancho del borde
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300]!, // Color del borde sombreado
                        width: 3.0, // Ancho del borde
                      ),
                    ),
                  ),
                ),
              ),
              body: const createEvent(isFriendGroup: true),
        ),
      ),
    );
  }
}
