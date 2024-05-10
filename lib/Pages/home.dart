import 'dart:io';
import 'dart:ui';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:friendship/Class/evento.dart';
import 'package:friendship/Class/grupo-amigos.dart';
import 'package:friendship/Pages/planes.dart';
import 'package:friendship/Pages/listfriends.dart';
import 'package:friendship/Pages/perfil.dart';
import 'package:friendship/Pages//create-event.dart';
import 'package:friendship/Class//compartir_enlace.dart';
import 'package:friendship/Pages/searching.dart';
import 'package:friendship/Pages/perfil.dart';
import 'package:friendship/Widgets/dayview.dart';
import 'package:uni_links/uni_links.dart';
import 'package:friendship/Class/pantalla_confirmacion.dart';
import 'package:friendship/Widgets/calendario.dart';
import 'package:friendship/Class/usernameAuxiliar.dart';
import 'package:friendship/Class/consultas.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:friendship/Pages/perfil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart' as provider;

import '../Class/appbar.dart';

class Home extends StatefulWidget {
  late int indiceInicial;
  late bool isFriendGroup;
   Home({super.key, required this.indiceInicial, required this.isFriendGroup});

  @override
  HomeState createState() => HomeState();
}

DateTime get _now => DateTime.now();

class HomeState extends State<Home> {
  int actualPage = 0;
  List<Evento> eventos = [
  ]; // Lista para almacenar los eventos de la base de datos


  final supabase = SupabaseClient(
    'https://peaoifidogwgoxzrpjft.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBlYW9pZmlkb2d3Z294enJwamZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTY2MDExNDcsImV4cCI6MjAxMjE3NzE0N30.xPOHo3wz93O9S0kWU9gbGofVWlFOZuA7JB9UMAMoBbA',
  );

  @override
  Widget build(BuildContext context) {
    var controller = EventController();


    List<Widget> pages = [
      Calendario(),
      Planes(),
      FriendList(),
      createEvent(isFriendGroup: widget.isFriendGroup),
      Search(),
      Perfil()
    ];

    return CalendarControllerProvider(
      controller: controller,
      child: MaterialApp(
          builder: (context, widget) =>
              ResponsiveWrapper.builder(
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
              appBar: provider.Provider
                  .of<AppBarProvider>(context)
                  .appBar,
              body: pages[actualPage],
              bottomNavigationBar: BottomNavigationBar(
                  fixedColor: Colors.black,
                  backgroundColor: Colors.indigo,
                  unselectedItemColor: Colors.grey,
                  onTap: (index) {
                    setState(() {
                      switch (index) {
                        case 0:
                          provider.Provider.of<AppBarProvider>(
                              context, listen: false).updateAppBar(
                            AppBar(title: Text("Eventos"), centerTitle: true,
                              flexibleSpace: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[300]!,
                                      // Color del borde sombreado
                                      width: 3.0, // Ancho del borde
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                          break;
                        case 1:
                          provider.Provider.of<AppBarProvider>(
                              context, listen: false).updateAppBar(
                            AppBar(
                              title: Text("Sugerencias"), centerTitle: true,
                              flexibleSpace: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[300]!,
                                      // Color del borde sombreado
                                      width: 3.0, // Ancho del borde
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                          break;
                        case 2:
                          provider.Provider.of<AppBarProvider>(
                              context, listen: false).updateAppBar(
                            AppBar(title: Text("Grupos de amigos"),
                              centerTitle: true,
                              flexibleSpace: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[300]!,
                                      // Color del borde sombreado
                                      width: 3.0, // Ancho del borde
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                          break;
                        case 3:
                          provider.Provider.of<AppBarProvider>(
                              context, listen: false).updateAppBar(
                            AppBar(
                              title: Text("Crear Evento"), centerTitle: true,
                              flexibleSpace: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[300]!,
                                      // Color del borde sombreado
                                      width: 3.0, // Ancho del borde
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                          break;
                        case 4:
                          provider.Provider.of<AppBarProvider>(
                              context, listen: false).updateAppBar(
                            AppBar(
                              title: Text("Buscar Eventos"), centerTitle: true,
                              flexibleSpace: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[300]!,
                                      // Color del borde sombreado
                                      width: 3.0, // Ancho del borde
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                          break;
                        case 5:
                          provider.Provider.of<AppBarProvider>(
                              context, listen: false).clearAppBar();
                          break;
                        default:
                          provider.Provider.of<AppBarProvider>(
                              context, listen: false).updateAppBar(
                            AppBar(title: Text("Eventos"), centerTitle: true,
                              flexibleSpace: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[300]!,
                                      // Color del borde sombreado
                                      width: 3.0, // Ancho del borde
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                      }

                      widget.isFriendGroup = false;
                      actualPage = index;
                    });
                  },
                  currentIndex: actualPage,
                  items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home), label: "Home"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.airplane_ticket), label: "Planes"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.workspaces_sharp),
                        label: "Friend List"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.add), label: "AddEvent"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.search), label: "search"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.account_circle), label: "Account"),
                  ]))),
    );
  }

  //Links profundos

  @override
  void initState() {
    super.initState();
    //initUniLinks();
    sleep(Duration(milliseconds: 1000));
    actualPage = widget.indiceInicial;
  }

}
/*
  void initUniLinks() async {
    // Maneja los enlaces profundos cuando la aplicación se inicia
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      handleDeepLink(initialLink); // Convierte la cadena a un objeto Uri
    }

    // Escucha enlaces profundos en tiempo real
    linkStream.listen((String? link) {
      handleDeepLink(link); // Pasa la cadena directamente
    });
  }

  void handleDeepLink(String? link) {
    if (link != null) {
      final uri = Uri.parse(link);
      if (link.contains('miapp://pantalla_confirmacion')) {
        final username = uri.queryParameters['username'];
        if (username != null) {
          UserData.username = username;
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Confirmacion(),
          ));
        }
      }
    }
  }
}



List<CalendarEventData<Evento>> _events = [
  CalendarEventData(
    date: _now,
    event: Evento(title: "Joe's Birthday"),
    title: "Project meeting",
    description: "Today is project meeting.",
    startTime: DateTime(_now.year, _now.month, _now.day, 18, 30),
    endTime: DateTime(_now.year, _now.month, _now.day, 22),
  ),
  CalendarEventData(
    date: _now.add(Duration(days: 1)),
    startTime: DateTime(_now.year, _now.month, _now.day, 18),
    endTime: DateTime(_now.year, _now.month, _now.day, 19),
    event: Event(title: "Wedding anniversary"),
    title: "Wedding anniversary",
    description: "Attend uncle's wedding anniversary.",
  ),
  CalendarEventData(
    date: _now,
    startTime: DateTime(_now.year, _now.month, _now.day, 14),
    endTime: DateTime(_now.year, _now.month, _now.day, 17),
    event: Event(title: "Football Tournament"),
    title: "Football Tournament",
    description: "Go to football tournament.",
  ),
  CalendarEventData(
    date: _now.add(Duration(days: 3)),
    startTime: DateTime(_now.add(Duration(days: 3)).year,
        _now.add(Duration(days: 3)).month, _now.add(Duration(days: 3)).day, 10),
    endTime: DateTime(_now.add(Duration(days: 3)).year,
        _now.add(Duration(days: 3)).month, _now.add(Duration(days: 3)).day, 14),
    event: Event(title: "Sprint Meeting."),
    title: "Sprint Meeting.",
    description: "Last day of project submission for last year.",
  ),
  CalendarEventData(
    date: _now.subtract(Duration(days: 2)),
    startTime: DateTime(
        _now.subtract(Duration(days: 2)).year,
        _now.subtract(Duration(days: 2)).month,
        _now.subtract(Duration(days: 2)).day,
        14),
    endTime: DateTime(
        _now.subtract(Duration(days: 2)).year,
        _now.subtract(Duration(days: 2)).month,
        _now.subtract(Duration(days: 2)).day,
        16),
    event: Event(title: "Team Meeting"),
    title: "Team Meeting",
    description: "Team Meeting",
  ),
  CalendarEventData(
    date: _now.subtract(Duration(days: 2)),
    startTime: DateTime(
        _now.subtract(Duration(days: 2)).year,
        _now.subtract(Duration(days: 2)).month,
        _now.subtract(Duration(days: 2)).day,
        10),
    endTime: DateTime(
        _now.subtract(Duration(days: 2)).year,
        _now.subtract(Duration(days: 2)).month,
        _now.subtract(Duration(days: 2)).day,
        12),
    event: Event(title: "Chemistry Viva"),
    title: "Chemistry Viva",
    description: "Today is Joe's birthday.",
  ),
];
*/
