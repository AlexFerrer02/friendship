import 'dart:io';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Class/consultas.dart';
import '../Class/evento.dart';
import '../Class/usernameAuxiliar.dart';
import '../Pages/EditEventPage.dart';

class Day extends StatefulWidget {

  @override
  State<Day> createState() => _DayViewState();
}

class _DayViewState extends State<Day> {
   List<CalendarEventData> eventos = [];

   EventController controller = EventController();
  @override
  Widget build(BuildContext context) {
    String myDateStringBuilder(DateTime date, {DateTime? secondaryDate}) {
      if (secondaryDate != null) {
        // Personalización basada en la fecha secundaria si está presente
        return '${DateFormat('dd de MMMM').format(date)}, Fecha secundaria: ${DateFormat('d MMM y').format(secondaryDate)}';
      } else {
        // Personalización solo con la fecha primaria si no hay fecha secundaria
        return '${DateFormat('EEEE, dd of MMMM').format(date)}';
      }
    }

    obtenerEventos();
    return DayView(
      controller: controller,
      dateStringBuilder: myDateStringBuilder,
      onEventTap: (event, date) async {
        Evento eventoActual = await Consultas().obtenerEventoNombre(event.first.title, event.first.description);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateEventPage(event: eventoActual, esCalendario: true,),
          ),
        );
      },
    );
  }

   Future<void> obtenerEventos() async {
     List<Evento> eventosObtenidos = await Consultas().EventosPropios();
     List<CalendarEventData> nuevosEventos = [];
     Color colorCalendario;
     Color colorYo = Color(0xFF5094F9);

     Color colorAmigo = Color(0xFF20BD8E);

     for (var evento in eventosObtenidos) {
       if (!eventos.contains(evento)) {
         String fechaHoraInicio = evento.fechaInicio + " " + evento.horaInicio;
         String fechaHoraFin = evento.fechaFin + " " + evento.horaFin;

         String formattedDateStringIni = fechaHoraInicio.substring(0, 10) + ' ' + fechaHoraInicio.substring(10);
         String formattedDateStringFin = fechaHoraFin.substring(0, 10) + ' ' + fechaHoraFin.substring(10);
         //print(formattedDateStringIni);
         //print(formattedDateStringFin);
         DateTime dateTimeInicio = DateTime.parse(fechaHoraInicio);
         DateTime dateTimeFin = DateTime.parse(fechaHoraFin);
         if (evento.userName == UserData.usuarioLog?.username) {
           // Asigna una decoración específica para este filtro
           colorCalendario = colorYo;
         }else {
           // Asigna una decoración predeterminada o por defecto
           colorCalendario = colorAmigo;
         }


         var nuevoEvento = CalendarEventData(
           title: evento.name,
           date: dateTimeInicio, // Usa la fecha del evento
           event: evento.name,
           description: evento.descripcion,
           startTime: dateTimeInicio, // Usa la hora de inicio del evento
           endTime: dateTimeFin, // Usa la hora de finalización del evento
           color: colorCalendario,
         );
         nuevosEventos.add(nuevoEvento);
       }
     }

     setState(() {
       eventos.addAll(nuevosEventos);
       controller.addAll(nuevosEventos);
     });
   }


}