
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../Class/usernameAuxiliar.dart';
import '../Class/utils.dart';


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

  LinkedHashMap<DateTime, List<Event>> _eventosPorFecha = LinkedHashMap(
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
    var eventosG = await supabase.from('eventos')
        .select('*')
        .eq('usuario', UserData.usuarioLog?.username);

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Column(
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
                          style: TextStyle(color: Colors.red),
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
                  weekNumberTextStyle:TextStyle(color: Colors.red),
                  weekendTextStyle:TextStyle(color: Colors.red),
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
              const SizedBox(height: 8.0),
              Expanded(
                child: ValueListenableBuilder<List<Event>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            onTap: () => print('${value[index]}'),
                            title: Text(value[index].title+ '  ' +value[index].hora),
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