import 'package:friendship/Class/user.dart' as user;
import 'package:friendship/Class/consultas.dart';
class GrupoAmigos {
  late final int id;
  late String name;
  late String descripcion;
  late user.User creador;
  late List<user.User> amigos; // Corregido: la lista debe ser de tipo User, no de tipo User.User
  late Consultas consultor; // Corregido: se cambió a SupabaseClient

  GrupoAmigos(this.name, this.creador, this.descripcion)  {
    consultor = Consultas();
    id = -1;
  }
  Future<int> ObtenerId() async{
     return await consultor.obtenerIdGrupo(name);
  }
  Future<void> addAmigo(user.User nuevo) async {
    if(id == -1){
      id = await consultor.obtenerIdGrupo(name);
    }
    amigos.add(nuevo);
    consultor.addAmigoAGrupoAmigos(id, nuevo);

  }

  Future<void> removeAmigo(user.User eliminado) async {
    if(id == -1){
      id = await consultor.obtenerIdGrupo(name);
    }
    amigos.remove(eliminado);
    consultor.rmAmigoDeGrupoAmigos(id, eliminado);
  }
}
