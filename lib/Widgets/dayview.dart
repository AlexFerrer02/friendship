import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

class Day extends StatefulWidget {
  final EventController controller;
  final List<CalendarEventData> events; // Cambio a una lista de eventos
  const Day({Key? key, required this.controller, required this.events});

  @override
  State<Day> createState() => _DayViewState();
}

class _DayViewState extends State<Day> {
  @override
  Widget build(BuildContext context) {
    return DayView(
      controller: widget.controller,
      onDateLongPress: (ca) {
        // Ejemplo: Añadir el primer evento al presionar la fecha
        widget.controller.addAll(widget.events);
      },
    );
  }
}