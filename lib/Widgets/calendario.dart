
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../Class/consultas.dart';
import '../Class/evento.dart';
import '../Class/usernameAuxiliar.dart';
import '../Class/utils.dart';
import '../Pages/EditEventPage.dart';
import '../Pages/home.dart';


class Calendario extends StatefulWidget {
  @override
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  final LinkedHashMap<DateTime, List<Event>> _eventosPorFecha = LinkedHashMap(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  late Future<void> _fetchDataFuture;

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchData();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    String user = UserData.usuarioLog!.username;
    var eventosG = await supabase.from('eventos')
        .select('*')
        .or('usuario.eq.${user}, amigos.cs.{${user}}')
        .order('horainicio', ascending: true);

    // Limpia los datos anteriores
    _eventosPorFecha.clear();

    // Recorre la respuesta y agrega los eventos al LinkedHashMap
    for (var evento in eventosG) {

      String horaString = evento["horainicio"];
      String fechaString = evento["fechainicio"];
      String textoSinUltimosTres = horaString.substring(0, horaString.length - 3);

      // Parsear la hora y la fecha en objetos DateTime
      DateTime hora = parseHora(horaString);
      DateTime fecha = parseFecha(fechaString);

      // Combina la fecha y la hora para obtener un objeto DateTime completo
      DateTime fechaEvento = combinarFechaYHora(fecha, hora);

      // Crea el evento
      Event nuevoEvento = Event(evento["nombre"], evento["id"], textoSinUltimosTres);

      // Si la fecha ya existe en el mapa, agrega el evento a la lista correspondiente
      if (_eventosPorFecha.containsKey(fechaEvento)) {
        _eventosPorFecha[fechaEvento]!.add(nuevoEvento);
      } else {
        _eventosPorFecha[fechaEvento] = [nuevoEvento];
      }
    }

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  // Función para parsear la hora en un objeto DateTime
  DateTime parseHora(String horaString) {
    // Parsear la cadena de texto en un objeto DateTime utilizando un formato específico
    return DateFormat('HH:mm:ss').parse(horaString);
  }

  // Función para parsear la fecha en un objeto DateTime
  DateTime parseFecha(String fechaString) {
    // Parsear la cadena de texto en un objeto DateTime utilizando un formato específico
    return DateFormat('yyyy-MM-dd').parse(fechaString);
  }

  // Función para combinar la fecha y la hora en un objeto DateTime
  DateTime combinarFechaYHora(DateTime fecha, DateTime hora) {
    // Combina la fecha y la hora utilizando los componentes de DateTime
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      hora.hour,
      hora.minute,
      hora.second,
    );
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return _eventosPorFecha[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  Color containerColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Column(
            children: [
              Stack(
                children: [
                  TableCalendar<Event>(
                    firstDay: kFirstDay,
                    lastDay: kLastDay,
                    calendarBuilders: CalendarBuilders(
                      dowBuilder: (context, day) {
                        if (day.weekday == DateTime.sunday || day.weekday == DateTime.saturday) {
                          final text = DateFormat.E().format(day);

                          return Center(
                            child: Text(
                              text,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                      },
                    ),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    rangeStartDay: _rangeStart,
                    rangeEndDay: _rangeEnd,
                    calendarFormat: _calendarFormat,
                    rangeSelectionMode: _rangeSelectionMode,
                    eventLoader: _getEventsForDay,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: CalendarStyle(
                      // Use `CalendarStyle` to customize the UI
                      outsideDaysVisible: false,
                      markerDecoration: const BoxDecoration(color: Color.fromRGBO(98, 69, 108, 1), shape: BoxShape.circle),
                      todayDecoration: const BoxDecoration(
                          color: Color.fromRGBO(136, 93, 152, 1),
                          shape: BoxShape.circle
                      ),
                      selectedDecoration: BoxDecoration(
                          color: const Color.fromRGBO(215, 146, 240, 1),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color.fromRGBO(178, 122, 199, 1))
                      ),
                      weekNumberTextStyle:const TextStyle(color: Colors.red),
                      weekendTextStyle:const TextStyle(color: Colors.red),
                    ),
                    onDaySelected: _onDaySelected,
                    onRangeSelected: _onRangeSelected,
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0, left: 55),
                    child: Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => Home(indiceInicial: 0, isFriendGroup: false,)),
                          );
                          Navigator.of(context).pop();
                        },
                        child: MouseRegion(
                          onEnter: (_) {
                            // Cambia el color de fondo cuando el puntero del ratón entra
                            setState(() {
                              containerColor = Color.fromRGBO(244, 240, 244, 1); // Define containerColor como una variable de estado en tu StatefulWidget
                            });
                          },
                          onExit: (_) {
                            // Restaura el color de fondo cuando el puntero del ratón sale
                            setState(() {
                              containerColor = Colors.transparent; // Define containerColor como una variable de estado en tu StatefulWidget
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 8,
                            height: 29,
                            decoration: BoxDecoration(
                              color: containerColor, // Usa la variable de color definida
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.all(3.0),
                            child: const Text(
                              'Hoy',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: ValueListenableBuilder<List<Event>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            Evento eventoActual = await Consultas().obtenerEventoId(value[index].id);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateEventPage(event: eventoActual, esCalendario: true,),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color.fromRGBO(109, 77, 121, 1)),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        bottomLeft: Radius.circular(10.0),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      value[index].title,
                                      style: const TextStyle(
                                        color: Color.fromRGBO(109, 77, 121, 1),
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color.fromRGBO(215, 146, 240, 1),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(11.0),
                                        bottomRight: Radius.circular(11.0),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      value[index].hora,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}