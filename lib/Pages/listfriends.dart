import 'package:flutter/material.dart';
import 'package:friendship/Class/grupo-amigos.dart';
import 'package:friendship/Class/consultas.dart';
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
                      for (Users.User user in users)
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
                              CircleAvatar(
                                maxRadius: 15,
                                backgroundColor: const Color(0xFF032A64),
                                child: Text(
                                  user.username.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  user.username,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Color(0xFFC62828)),
                                onPressed: () {
                                  showAlertDialog(context, user.username);
                                },
                              )
                            ],
                          ),
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
