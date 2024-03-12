import 'type.dart';
import 'package:friendship/Class/filtro.dart';

class Evento {
  late final int id;
  late String name;
  late Type type;
  late String descripcion;
  late List<String> filtros;
  late String fechaInicio;
  late String fechaFin;
  late String horaInicio;
  late String horaFin;
  late String lugar;
  late String userName;
  Evento(this.id, this.name, this.type, this.descripcion,
      this.filtros, this.fechaInicio, this.fechaFin, this.horaInicio,
      this.horaFin, this.lugar, this.userName);
}
