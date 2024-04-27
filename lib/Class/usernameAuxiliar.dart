import 'package:friendship/Class/user.dart' as usuario;
import 'package:supabase_flutter/supabase_flutter.dart';

class UserData {
  static String? username;
  static String? emailActual;
  static usuario.User? usuarioLog;
  static int? idGrupoAmigos;

  final supabase = SupabaseClient(
    'https://peaoifidogwgoxzrpjft.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBlYW9pZmlkb2d3Z294enJwamZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTY2MDExNDcsImV4cCI6MjAxMjE3NzE0N30.xPOHo3wz93O9S0kWU9gbGofVWlFOZuA7JB9UMAMoBbA',
  );

  Future<void> actualizarContadorEventos() async {
    usuarioLog!.eventosCreados++;
    await supabase
        .from('usuarios')
        .update({ 'num_eventos': usuarioLog!.eventosCreados})
        .match({ 'username': usuarioLog!.username });
  }

  Future<void> construirUsuarioPorEmail(String? email) async {
    var usernameAux = '';
    var telefonoAux = 0;
    var eventosAux = 0;
    List<String> gustos = [];
    final Response = await supabase
        .from('usuarios')
        .select('username')
        .eq('email', email);

    final ResponseTel = await supabase
        .from('usuarios')
        .select('telefono')
        .eq('email', email);

    final ResponseEv = await supabase
        .from('usuarios')
        .select('num_eventos')
        .eq('email', email);

    final ResponseGust = await supabase
        .from('usuarios')
        .select('gustos')
        .eq('email', email);

    if (Response.isNotEmpty) {
      usernameAux = Response[0]['username'];
    }
    if (ResponseTel.isNotEmpty) {
      telefonoAux = ResponseTel[0]['telefono'];
    }
    if (ResponseEv.isNotEmpty) {
      eventosAux = ResponseEv[0]['num_eventos'];
    }
    if (ResponseGust.isNotEmpty) {
      for(var gusto in ResponseGust[0]['gustos']){
        gustos.add(gusto);
      }
    }
    usuarioLog = new usuario.User(usernameAux, email!, telefonoAux, eventosAux, gustos);
    //print(usuarioLog!.username + "evento");
    }
  }