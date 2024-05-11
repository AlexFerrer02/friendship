import 'dart:math';

import 'package:friendship/Class/grupo-amigos.dart';
import 'package:friendship/Class/usernameAuxiliar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'evento.dart';
import 'package:friendship/Class/filtro.dart';
import 'type.dart';
import 'package:friendship/Class/user.dart' as user;

class Consultas{
  final supabase = SupabaseClient(
    'https://peaoifidogwgoxzrpjft.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBlYW9pZmlkb2d3Z294enJwamZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTY2MDExNDcsImV4cCI6MjAxMjE3NzE0N30.xPOHo3wz93O9S0kWU9gbGofVWlFOZuA7JB9UMAMoBbA',
  );

  Future<List<Evento>> BuscarEventos({required String nombreEvento}) async
  {
    var response = await  supabase.from('eventos')
        .select('*')
        .eq("tipo", "publico")
        .gte("fechainicio", DateTime.now())
        .ilike("nombre", '$nombreEvento%');
    List<Evento> eventos = [];
    for (var item in response) {
      //print(item);
      //List<Filtro> filtros = [Filtro(1, item["filtro"]), Filtro(2, item["filtro2"])];
      var filtrosAux = item["filtros"];
      List<String> filtros = [];
      for (var item in filtrosAux) {
        filtros.add(item);
      }
      Type tipo = Type(1, item["tipo"]);
      eventos.add(Evento(item["id"], item["nombre"], tipo , item["descripcion"], filtros, item["fechainicio"],item["fechafin"], item["horainicio"], item["horafin"],item["lugar"],item["usuario"] ));
    }
    return eventos;

  }
  Future<List<Evento>> EventosAmigos() async
  {
    List<Evento> eventos = [];
    final username =UserData.usuarioLog?.username;
    var response = await  supabase.from('usuarios')
        .select('*')
        .eq("username", username);

    if(response[0]["lista_amigos"]!=null){
      for (var amigo in response[0]["lista_amigos"]) {
        var rowAmigo = await  supabase.from('eventos')
            .select('*')
            .gte("fechainicio", DateTime.now())
            .eq("usuario", amigo)
            .eq("tipo", "publico");
        for(var evento in rowAmigo){
          //print(rowAmigo);
          //List<Filtro> filtros = [Filtro(1, evento["filtro"]), Filtro(2, evento["filtro2"])];
          var filtrosAux = evento["filtros"];
          List<String> filtros = [];
          for (var item in filtrosAux) {
            filtros.add(item);
          }
          Type tipo = Type(1, evento["tipo"]);
          eventos.add(Evento(evento["id"], evento["nombre"], tipo , evento["descripcion"], filtros, evento["fechainicio"],evento["fechafin"], evento["horainicio"], evento["horafin"],evento["lugar"],evento["usuario"] ));
        }
      }
    }
    return eventos;

  }

  Future<List<Evento>> EventosGustos() async
  {
    List<Evento> eventos = [];
    final username =UserData.usuarioLog?.username;
    final gustosUsuario = UserData.usuarioLog!.gustos;
    var eventosG = await  supabase.from('eventos')
        .select('*')
        .neq("usuario", username)
        .eq("tipo", "publico").gte("fechainicio", DateTime.now());

    for(var eventoAux in eventosG){
      List<String> gustosAux = [];
      for(var gusto in eventoAux['filtros']){
        gustosAux.add(gusto);
      }
      for(var gustoUsuario in gustosUsuario){
        if(gustosAux.contains(gustoUsuario)){
          Type tipo = Type(1, eventoAux["tipo"]);
          eventos.add(Evento(eventoAux["id"], eventoAux["nombre"], tipo , eventoAux["descripcion"], gustosAux, eventoAux["fechainicio"],eventoAux["fechafin"], eventoAux["horainicio"], eventoAux["horafin"],eventoAux["lugar"],eventoAux["usuario"] ));
          break;
        }
      }
    }
    return eventos;
  }

  Future<List<Evento>> EventosRecomendados() async
  {
    List<Evento> eventos = [];
    var response = await  supabase.from('eventos')
        .select('*')
        .eq("tipo", "publico")
        .neq("usuario", UserData.usuarioLog?.username)
        .gte("fechainicio", DateTime.now())
    ;

    for (var item in response) {
      List<String> participantes = [];

      for(var participante in item["amigos"]){
        participantes.add(participante);
      }

      if(!participantes.contains(UserData.usuarioLog!.username)){
        var filtrosAux = item["filtros"];
        List<String> filtros = [];
        for (var item in filtrosAux) {
          filtros.add(item);
        }
        Type tipo = Type(1, item["tipo"]);
        eventos.add(Evento(item["id"], item["nombre"], tipo , item["descripcion"], filtros, item["fechainicio"],item["fechafin"], item["horainicio"], item["horafin"],item["lugar"],item["usuario"] ));
      }
    }

    return eventos;

  }

  Future<bool> checkUsername (String username) async {
    var response = await  supabase.from('usuarios')
        .select('*')
        .eq("username", username);

    print(response);
    if(response.toString() != '[]'){
      return true;
    } else {
      return false;
    }
  }

  Future<List<String>> getGustosUsuario(String usuario) async {
    var response = await  supabase.from('usuarios')
        .select('*')
        .eq("username", usuario);
    List<String> gustos = [];

    for(var item in response){
      for(var gusto in item["gustos"]) {
        gustos.add(gusto);
      }
    }

    return gustos;
  }

  Future<List<Evento>> EventosFiltro({required String filtro1, required String filtro2}) async
  {
    var response = await  supabase.from('eventos')
        .select('*')
        .eq("tipo", "publico")
        .gte("fechainicio", DateTime.now());
    List<Evento> eventos = [];
    for (var item in response) {
      if(item["filtro1"] == filtro1 || item["filtro2"] == filtro1 || item["filtro1"] == filtro2 || item["filtro2"] == filtro2){
        //List<Filtro> filtros = [Filtro(1, item["filtro"]), Filtro(2, item["filtro2"])];
        var filtrosAux = item["filtros"];
        List<String> filtros = [];
        for (var item in filtrosAux) {
          filtros.add(item);
        }
        Type tipo = Type(1, item["tipo"]);
        eventos.add(Evento(item["id"], item["nombre"], tipo , item["descripcion"], filtros, item["fechainicio"],item["fechafin"], item["horainicio"], item["horafin"],item["lugar"],item["usuario"] ));
      }
    }
    return eventos;

  }
  Future<List<Evento>> EventosFiltro1({required String filtro1}) async
  {
    var response = await  supabase.from('eventos')
        .select('*')
        .eq("tipo", "publico")
        .gte("fechainicio", DateTime.now());
    List<Evento> eventos = [];
    for (var item in response) {
      if(item["filtro1"] == filtro1 || item["filtro2"] == filtro1){
        //List<Filtro> filtros = [Filtro(1, item["filtro"]), Filtro(2, item["filtro2"])];
        var filtrosAux = item["filtros"];
        List<String> filtros = [];
        for (var item in filtrosAux) {
          filtros.add(item);
        }
        Type tipo = Type(1, item["tipo"]);
        eventos.add(Evento(item["id"], item["nombre"], tipo , item["descripcion"], filtros, item["fechainicio"],item["fechafin"], item["horainicio"], item["horafin"],item["lugar"],item["usuario"] ));
      }
    }
    eventos.shuffle();
    return eventos;

  }
  Future<List<Filtro>> FiltrosDisponibles() async{
    return [Filtro(1, "musica"),Filtro(2, "fiesta"),Filtro(3, "gastronomia"),Filtro(4, "aventura"),];
  }
  Future<List<Evento>> EventosPropios() async
  {
    var response = await  supabase.from('eventos')
        .select('*')
        .eq("usuario", UserData.usuarioLog?.username)
        .gte("fechainicio", DateTime.now());
    List<Evento> eventos = [];
    for (var item in response) {
      //List<Filtro> filtros = [Filtro(1, item["filtro"]), Filtro(2, item["filtro2"])];
      var filtrosAux = item["filtros"];
      List<String> filtros = [];
      for (var item in filtrosAux) {
        filtros.add(item);
      }
      Type tipo = Type(1, item["tipo"]);
      eventos.add(Evento(item["id"], item["nombre"], tipo , item["descripcion"], filtros, item["fechainicio"],item["fechafin"], item["horainicio"], item["horafin"],item["lugar"],item["usuario"] ));
      //print(eventos[0].name + eventos[0].fechaHoraFin+"llamada");
    }
    response = await  supabase.from('eventos')
        .select('*').contains("amigos", [UserData.usuarioLog?.username]).gte("fechainicio", DateTime.now());;
    for (var item in response) {
      //List<Filtro> filtros = [Filtro(1, item["filtro"]), Filtro(2, item["filtro2"])];
      var filtrosAux = item["filtros"];
      List<String> filtros = [];
      for (var item in filtrosAux) {
        filtros.add(item);
      }
      Type tipo = Type(1, item["tipo"]);
      eventos.add(Evento(item["id"], item["nombre"], tipo , item["descripcion"], filtros, item["fechainicio"],item["fechafin"], item["horainicio"], item["horafin"],item["lugar"],item["usuario"] ));
      //print(eventos[0].name + eventos[0].fechaHoraFin+"llamada");
    }
    return eventos;

  }

  Future<List<Evento>> Recomendaciones() async
  {
    List<Evento> eventosRecomendados = await EventosRecomendados();
    List<Evento> eventosAmigos = await EventosAmigos();

    // Combinar las listas
    List<Evento> result = [...eventosRecomendados, ...eventosAmigos];

    // Eliminar elementos duplicados
    List<Evento> eventosSinDuplicados = Set.of(result).toList();

    return eventosSinDuplicados;
  }
  Future<int> generarNumeroAleatorioUnico(String tabla) async {
    final Random random = Random();
    final String columna;
    if(tabla=='usuarios'){
      columna = 'telefono';
    } else {
      columna = 'id';
    }
    int numeroAleatorio;
    do {
      // Genera un número aleatorio entre 0 y 9999999
      numeroAleatorio = random.nextInt(10000000);
      // Verifica si el número ya existe en la base de datos
      final response = await supabase.from(tabla).select().eq(columna, numeroAleatorio);
      if (response.toString() != '[]') {
        // Si el número ya existe, vuelve a intentarlo
        numeroAleatorio = -1; // Puedes establecer cualquier valor que no sea un número válido
      }
    } while (numeroAleatorio == -1);
    return numeroAleatorio;
  }

  Future<int> obtenerIdGrupo(String nombre) async {
    var response = await supabase.from("gruposamigos").select("*").eq("nombre", nombre);
    print(response);
    print(response[0]["id"]);
    return response[0]["id"];
  }

  Future<Evento> obtenerEventoNombre(String nombre, String descripcion) async {
    var response = await supabase.from("eventos").select("*").eq("nombre", nombre).eq("descripcion", descripcion);
    List<String> filtros = [];
    for (var item in response[0]["filtros"]) {
      filtros.add(item);
    }
    return Evento(response[0]["id"], response[0]["nombre"], Type(1, response[0]["tipo"]),
        response[0]["descripcion"], filtros,
        response[0]["fechainicio"], response[0]["fechafin"], response[0]["horainicio"], response[0]["horafin"],
        response[0]["lugar"], response[0]["usuario"]);
  }

  Future<List<String>> obtenerAmigosEvento(int id) async {
    var response = await supabase.from("eventos").select("*").eq("id", id);
    List<String> amigos = [];
    for (var item in response[0]["amigos"]) {
      amigos.add(item);
    }
    return amigos;
  }

  Future<Evento> obtenerEventoId(int id) async {
    var response = await supabase.from("eventos").select("*").eq("id", id);
    List<String> filtros = [];
    for (var item in response[0]["filtros"]) {
      filtros.add(item);
    }
    return Evento(response[0]["id"], response[0]["nombre"], Type(1, response[0]["tipo"]),
        response[0]["descripcion"], filtros,
        response[0]["fechainicio"], response[0]["fechafin"], response[0]["horainicio"], response[0]["horafin"],
        response[0]["lugar"], response[0]["usuario"]);
  }

  Future<List<String>> getParticipantesGrupo (int id) async{
    var response = await supabase.from("gruposamigos").select("*").eq("id", id);
    List<String> participantes = [];
    for(var participante in response[0]["participantes"]){
      participantes.add(participante);
    }
    return participantes;
  }

  Future<List<GrupoAmigos>> ObtenerGrupos() async {
    print("inicio");
    var response = await supabase.from("gruposamigos").select("*").contains("participantes", [UserData.usuarioLog?.username]);
    List<GrupoAmigos> grupos = [];

    if (response.isNotEmpty) {
      for (final group in response) {
        var responsecreador = await supabase.from("usuarios").select("*").eq("username", group["creador"].toString().replaceAll('"', ""));
        List<String> gustos = [];
        for(var gusto in responsecreador[0]["gustos"]){
          gustos.add(gusto);
        }
        user.User creador = user.User(
          responsecreador[0]["username"],
          responsecreador[0]["email"],
          responsecreador[0]["telefono"],
          responsecreador[0]["num_eventos"],
          gustos
        );

        GrupoAmigos grupo = GrupoAmigos(group["nombre"], creador, group["descripcion"]);
        grupo.amigos = [];

        // Utilizar group["participantes"] en lugar de response["participantes"]
        if (group["participantes"] != null) {
          for (var amigo in group["participantes"]) {
            var userresponse = await supabase.from("usuarios").select("*").eq("username", amigo.toString());

            if (userresponse.isNotEmpty) {
              List<String> gustosAux = [];
              for(var gusto in userresponse[0]["gustos"]){
                gustosAux.add(gusto);
              }
              grupo.amigos.add(user.User(
                userresponse[0]["username"],
                userresponse[0]["email"],
                userresponse[0]["telefono"],
                userresponse[0]["num_eventos"],
                gustosAux
              ));
            }
          }
        }
        grupos.add(grupo);
      }
      print(grupos);
      return grupos;
    } else {
      return grupos;
    }
  }


  Future<void> addGrupoAmigos(String nombre, String descripcion,user.User creador) async {
    int id2 = await generarNumeroAleatorioUnico("usuarios");
    print("crear");
    await supabase
        .from("gruposamigos")
        .upsert([
      {
        "id": id2,
        "nombre": nombre,
        "participantes": [],
        "creador": creador.username,
        "descripcion": descripcion,
      }
    ]);
    addAmigoAGrupoAmigos(id2,creador);

    await supabase
        .from("usuarios")
        .upsert([
      {
        "telefono": id2,
        "username": nombre+id2.toString(),
      }
    ]);
    //supabase.from("usuarios").insert(values)
  }

  Future<String> buscarPorCodigoAmigo (int codigo) async {
    String usuario = '';
    var response = await supabase.from("usuarios").select("*").eq("codigo_amigo", codigo);
    if(response.toString() != '[]'){
      usuario = response[0]["username"];
    }
    return usuario;
  }

  Future<int> getCodigoPropio () async {
    var response = await supabase.from("usuarios").select("*").eq("username", UserData.usuarioLog!.username);
    return response[0]["codigo_amigo"];
  }

  Future<bool> checkAmigo (String user) async {
    var response = await supabase.from("usuarios").select("*").eq("username", UserData.usuarioLog!.username);
    List<String> amigos = [];
    for(var item in response[0]["lista_amigos"]){
      amigos.add(item);
    }
    if(amigos.contains(user)){
      return true;
    } else {
      return false;
    }
  }

  Future<void> addAmigo (String user) async {
    var response = await supabase.from("usuarios").select("*").eq("username", UserData.usuarioLog!.username);
    List<String> amigos = [];
    for(var item in response[0]["lista_amigos"]){
      amigos.add(item);
    }
    amigos.add(user);
    await supabase
        .from('usuarios')
        .update({ 'lista_amigos': amigos })
        .match({ 'username': UserData.usuarioLog!.username });
  }

  Future<void> removeAmigo (String user) async {
    var response = await supabase.from("usuarios").select("*").eq("username", UserData.usuarioLog!.username);
    List<String> amigos = [];
    for(var item in response[0]["lista_amigos"]){
      amigos.add(item);
    }
    amigos.remove(user);
    await supabase
        .from('usuarios')
        .update({ 'lista_amigos': amigos })
        .match({ 'username': UserData.usuarioLog!.username });
  }

  Future<void> deleteGrupoAmigos (GrupoAmigos grupo) async {

    var response = await supabase
        .from('gruposamigos')
        .select("*")
        .eq('nombre', grupo.name)
        .eq('descripcion', grupo.descripcion)
        .eq('creador', grupo.creador.username);

    int id = response[0]["id"];
    String usuario = grupo.name + id.toString();
    print(usuario);

    await supabase
        .from('eventos')
        .delete()
        .match({ 'usuario': usuario });

    await supabase
        .from('usuarios')
        .delete()
        .match({ 'username': usuario });

    await supabase
        .from('gruposamigos')
        .delete()
        .match({ 'nombre': grupo.name })
        .match({ 'descripcion': grupo.descripcion })
        .match({ 'creador': grupo.creador.username });
  }

  Future<void> addAmigoAGrupoAmigos(int id, user.User nuevo) async {
    var group = await supabase.from("gruposamigos").select("*").eq("id", id);
    var participantes ;
    if (group.isNotEmpty) {
      var grupo = group[0];
      if (grupo != null) {
        participantes= grupo['participantes'];
        if (!participantes.contains(nuevo.username)) {
          participantes.add(nuevo.username);
        }

    }
      await supabase
          .from('gruposamigos')
          .update({ 'participantes': participantes })
          .match({ 'id': id });
      updateEventosGrupoAmigos(id,nuevo,'add');
      }
    }

  Future<void> updateEventosGrupoAmigos(int id, user.User nuevo, String operacion) async {
    var group = await supabase.from("gruposamigos").select("*").eq("id", id);
    var nombre ;
    if (group.isNotEmpty) {
      var grupo = group[0];
      if (grupo != null) {
        nombre= grupo['nombre']+id.toString();
        var response = await supabase
            .from('eventos')
            .select("*")
            .eq("usuario", nombre);
        for(var evento in response){
          List<String> amigosAux = [];
          for(var amigo in evento["amigos"]){
            amigosAux.add(amigo);
          }
          if(operacion == 'add'){
            if(!amigosAux.contains(nuevo.username)){
              amigosAux.add(nuevo.username);
            }
          } else {
            if(amigosAux.contains(nuevo.username)){
              amigosAux.remove(nuevo.username);
            }
          }
          await supabase
              .from('eventos')
              .update({ 'amigos': amigosAux })
              .match({ 'id': evento["id"] });
        }
      }
    }
  }
  Future<void> rmAmigoDeGrupoAmigos(int id, user.User eliminado) async {
    var group = await supabase.from("gruposamigos").select("*").eq("id", id);
    var participantes ;
    if (group.isNotEmpty) {
      var grupo = group[0];
      if (grupo != null) {
        participantes= grupo['participantes'];

        participantes ??= [];

        if (participantes.contains(eliminado.username)) {
          participantes.remove(eliminado.username);
        }

      }
      await supabase
          .from('gruposamigos')
          .update({ 'participantes': participantes })
          .match({ 'id': id });
      updateEventosGrupoAmigos(id,eliminado,'remove');
    }
  }

  Future<List<Evento>> EventosGrupo(String nombre, String descripcion, String creador) async {
    var getNombre = await supabase.from("gruposamigos").select("*").eq("nombre", nombre).eq("descripcion", descripcion).eq("creador", creador);
    String nombreGrupo = getNombre[0]["nombre"] + getNombre[0]["id"].toString();
    var response = await supabase.from("eventos").select("*").eq("usuario", nombreGrupo);
    List<Evento> eventos = [];
    for (var item in response) {
      //List<Filtro> filtros = [Filtro(1, item["filtro"]), Filtro(2, item["filtro2"])];
      var filtrosAux = item["filtros"];
      List<String> filtros = [];
      for (var item in filtrosAux) {
        filtros.add(item);
      }
      Type tipo = Type(1, item["tipo"]);
      eventos.add(Evento(item["id"], item["nombre"], tipo , item["descripcion"], filtros, item["fechainicio"],item["fechafin"], item["horainicio"], item["horafin"],item["lugar"],item["usuario"] ));
      //print(eventos[0].name + eventos[0].fechaHoraFin+"llamada");
    }
    return eventos;
  }

  Future<void> EditGrupo(int id, String descripcion)async{
    var group = await supabase.from("gruposamigos").select("*").eq("id", id);
    if(group.isNotEmpty){
      print("entro");
      await supabase.from("gruposamigos").update({'descripcion' : descripcion}).match({'id':id});

    }

  }

  Future<void> EditEvento(int id, String descripcion)async{
    var event = await supabase.from("eventos").select("*").eq("id", id);
    if(event.isNotEmpty){
      await supabase.from("eventos").update({'descripcion' : descripcion}).match({'id':id});

    }

  }

  Future<List<user.User>> ObtenerAmigos() async{
    List<user.User> amigos =[];
    print([UserData.usuarioLog?.username]);
    var response = await supabase.from("usuarios").select("*").eq("username", UserData.usuarioLog?.username);
    for (var amigo in response[0]["lista_amigos"]) {
      var userresponse = await supabase.from("usuarios").select("*").eq("username", amigo.toString());
      if (userresponse.isNotEmpty) {
        print("entro");
        List<String> gustosAux = [];
        for(var gusto in userresponse[0]["gustos"]){
          gustosAux.add(gusto);
        }

        amigos.add(user.User(
          userresponse[0]["username"],
          userresponse[0]["email"],
          userresponse[0]["telefono"],
          userresponse[0]["num_eventos"],
          gustosAux
        ));
      }
    }
    return amigos;

  }
}

