import 'dart:io';

import 'package:flutter/material.dart';
import 'package:friendship/Class/grupo-amigos.dart';
import 'package:friendship/Class/consultas.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Class/user.dart' as Users;
import '../Class/usernameAuxiliar.dart';
import '../Widgets/listGroupsWidget.dart';
import 'package:friendship/Pages/home.dart';

class FriendList extends StatefulWidget {
  const FriendList({super.key});

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _fetchDataFuture = fetchData();
  }

  Future<void> fetchData() async {
    eventos = await Consultas().ObtenerGrupos();
    users = await Consultas().ObtenerAmigos();
  }

  Future<List<Widget>> _buildAvatars() async {
    List<Widget> avatars = [];

    for (Users.User amigo in users) {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFileName = 'temp_image_$timestamp.png';

      final tempFile = File('${tempDir.path}/$tempFileName');
      final storageResponse = await supabase
          .storage
          .from('perfiles')
          .download(amigo.username);
      await tempFile.writeAsBytes(storageResponse);
      avatars.add(
          Container(
            margin: const EdgeInsets.only(left: 20, right: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    await showAvatar(context, amigo);
                  } ,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // Color de fondo gris claro
                      image: DecorationImage(
                        image: FileImage(tempFile),
                        fit: BoxFit.cover,
                      )
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    amigo.username,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFC62828)),
                  onPressed: () {
                    showAlertDialog(context, amigo.username);
                  },
                )
              ],
            ),
          )
      );
    }

    return avatars;
  }

  Future<Container> getAvatar(Users.User user) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempFileName = 'temp_image_$timestamp.png';

    final tempFile = File('${tempDir.path}/$tempFileName');
    final storageResponse = await supabase
        .storage
        .from('perfiles')
        .download(user.username);
    await tempFile.writeAsBytes(storageResponse);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white, // Color de fondo gris claro
        image: DecorationImage(
          image: FileImage(tempFile),
          fit: BoxFit.cover,
        ) // No hay imagen si image es null
      ),
    );
  }

  void showAlertDialog(BuildContext context, String usuario) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Aviso"),
            content: const Text(
                "¿Estás seguro de que quieres eliminar a este usuario de tus amigos?"),
            actions: [
              // Acción No
              TextButton(
                onPressed: () {
                  // Cerrar el AlertDialog
                  Navigator.of(context).pop();
                },
                child: const Text("Cancelar"),
              ),
              // Acción Sí
              TextButton(
                onPressed: () async {
                  await Consultas().removeAmigo(usuario);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) =>
                        Home(indiceInicial: 2, isFriendGroup: false,)),
                  );
                },
                child: const Text("Eliminar"),
              ),
            ],
          );
      }
    );
  }

  Future<void> showAvatar(BuildContext context, Users.User user) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempFileName = 'temp_image_$timestamp.png';

    final tempFile = File('${tempDir.path}/$tempFileName');
    final storageResponse = await supabase
        .storage
        .from('perfiles')
        .download(user.username);
    await tempFile.writeAsBytes(storageResponse);
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Ajusta el radio según lo necesites
          ),
          elevation: 0.0, // Sin sombra
          backgroundColor: Colors.transparent,
          child: Container(
            height: MediaQuery.of(context).size.height / 2.6,
            width: MediaQuery.of(context).size.width / 1.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(240.0),
              color: Colors.white,
              image: DecorationImage(
                image: FileImage(tempFile),
                fit: BoxFit.cover,
              ), // No hay imagen si image es null
            ),
          ),
        );
      },
    );
  }

  bool grupos = true;
  bool amigos = false;
  late List<Users.User> users;
  late List<GrupoAmigos> eventos;
  late Future<void> _fetchDataFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        grupos = true;
                        amigos = false;
                      });
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.groups,
                          color: grupos ? const Color.fromRGBO(215, 146, 240, 1) : const Color.fromRGBO(98, 69, 108, 1),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        grupos = false;
                        amigos = true;
                      });
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.group,
                          color: amigos ? const Color.fromRGBO(215, 146, 240, 1) : const Color.fromRGBO(98, 69, 108, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: grupos
                    ? SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      ListGroupsWidget(groups: eventos),
                      const SizedBox(height: 20,),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Crear Grupo'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        maxLength: 20,
                                        controller: _titleController,
                                        decoration: const InputDecoration(
                                          labelText: 'Título del Grupo',
                                        ),
                                      ),
                                      TextFormField(
                                        maxLines: 5,
                                        controller: _descriptionController,
                                        decoration: const InputDecoration(
                                          labelText: 'Descripción del Grupo',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      print(UserData.usuarioLog!.username);
                                      await Consultas().addGrupoAmigos(
                                        _titleController.text,
                                        _descriptionController.text,
                                        UserData.usuarioLog!);
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => Home(
                                            indiceInicial: 2,
                                            isFriendGroup: false,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Crear Grupo'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cerrar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text("Crear Grupo"),
                      ),
                      const SizedBox(height: 10,),
                    ],
                  ),
                )
                    : amigos
                    ? SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if(users.isNotEmpty)
                        FutureBuilder<List<Widget>>(
                          future: _buildAvatars(), // Llama a la función asincrónica que devuelve una lista de widgets
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              // Mientras se está cargando la data, muestra un indicador de carga.
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              // Si hay un error al cargar los datos, muestra un mensaje de error.
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else {
                              // Si la data ha sido cargada exitosamente, muestra la lista de widgets.
                              return Column(
                                children: snapshot.data!,
                              );
                            }
                          },
                        ),
                    ],
                  ),
                )
                    : Container(), // Otra opción en caso de que no estés en ninguna categoría
              ),
            ],
          );
        }
      },
    );
  }
}
