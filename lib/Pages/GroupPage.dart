import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:friendship/Class/consultas.dart';
import 'package:friendship/Class/grupo-amigos.dart';
import 'package:friendship/Class/usernameAuxiliar.dart';
import 'package:friendship/Pages/crearEventoGrupo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Class/appbar.dart';
import '../Class/evento.dart';
import '../Class/user.dart' as Users;
import '../Widgets/listEventos.dart';
import 'home.dart';
import 'package:provider/provider.dart' as provider;

class GroupPage extends StatefulWidget {
  final GrupoAmigos group;

  GroupPage({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupPage> createState() => GroupPageState();
}

class GroupPageState extends State<GroupPage> {
  late TextEditingController _descriptionController;
  bool isEditingDescription = false;
  final supabase = Supabase.instance.client;
  List<Users.User> amigos = [];
  late Future<void> _fetchDataFuture;
  List<String> participantes = [];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
        text: widget.group.descripcion.replaceAll('"', ""));
    amigos = [];
    amigos.addAll(widget.group.amigos);
    _fetchDataFuture = getParticipantes();
  }

  Future<void> getParticipantes() async {
    int id = await widget.group.ObtenerId();
    participantes = await Consultas().getParticipantesGrupo(id);
  }

  List<Widget> _buildAvatars() {
    List<Widget> avatars = [];

    for (String participante in participantes) {
      String initials = participante.substring(0, 1).toUpperCase();
      avatars.add(
        Center(
          child: CircleAvatar(
            maxRadius: 15,
            backgroundColor: Color(0xFF032A64),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return avatars;
  }

  Future<void> mostrarDialogo(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar'),
          content: const Text('¿Estás seguro de que quieres eliminar el grupo?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await Consultas().deleteGrupoAmigos(widget.group);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Home(indiceInicial: 2,isFriendGroup: false,)),
                );
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _dialogoEventoAjeno(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aviso'),
          content: const Text('No eres el creador de este grupo, no puedes eliminarlo.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void rebuildWidget() {
    setState(() {
      // Aquí puedes realizar cualquier cambio de estado necesario
      // que quieras reflejar en la interfaz de usuario
    });
  }

  Future<void> _saveChanges() async {
    int id = await widget.group.ObtenerId();
    setState(() {
      if (isEditingDescription) {
        widget.group.descripcion = '"${_descriptionController.text}"';
        Consultas().EditGrupo(id, widget.group.descripcion);
      }
      isEditingDescription = !isEditingDescription;
    });
  }

  void _showListPopup(BuildContext context, List<Users.User> users) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (Users.User user in users)
                  Container(
                    margin: const EdgeInsets.only(bottom: 15.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          maxRadius: 15,
                          backgroundColor: const Color(0xFF032A64),
                          child: Text(
                            user.username.substring(0, 1),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(user.username),
                        const SizedBox(width: 65,),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.blue,),
                          onPressed: () async {
                            int id = await widget.group.ObtenerId();
                            await Consultas().addAmigoAGrupoAmigos(id, user);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => GroupPage(group: widget.group)),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Color(0xFFC62828),),
                          onPressed: () async {
                            int id = await widget.group.ObtenerId();
                            await Consultas().rmAmigoDeGrupoAmigos(id, user);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => GroupPage(group: widget.group)),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          )
        );
      },
    );
  }

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
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) =>
                          Home(indiceInicial: 2, isFriendGroup: false,)),
                    );
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFFC62828),),
                    onPressed: () {
                      print(widget.group.id);
                      if (widget.group.creador.username ==
                          UserData.usuarioLog!.username) {
                        mostrarDialogo(context);
                      } else {
                        _dialogoEventoAjeno(context);
                      }
                    },
                  ),
                ],
              ),
              backgroundColor: Color(0xFFE7DBF7),
              body: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height / 3.2,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child:
                      Center(
                          child: Image.asset("assets/SistemaSolarMorado.png")),
                    ),
                    Stack(
                      children: [
                        SizedBox(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                topRight: Radius.circular(25),
                              ),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            widget.group.name,
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )),
                                      ElevatedButton(
                                        onPressed: () {
                                          _saveChanges();
                                        },
                                        child: Icon(isEditingDescription
                                            ? Icons.save_alt
                                            : Icons.edit),
                                      )
                                    ]),
                                isEditingDescription
                                    ? TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    hintText: 'Ingrese la descripción',
                                  ),
                                )
                                    : TextFormField(
                                  enabled: false,
                                  controller: _descriptionController,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    hintText: 'Ingrese la descripción',
                                  ),
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Container(
                                          alignment: Alignment.centerLeft,
                                          child: const Text(
                                            "Participantes",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )),
                                      Container(
                                        alignment: Alignment.centerRight,
                                        margin: const EdgeInsets.only(top: 7),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            List<Users.User> users =
                                            await Consultas().ObtenerAmigos();
                                            _showListPopup(context, users);
                                          },
                                          child: const Icon(Icons.group_add),
                                        ),
                                      )
                                    ]),
                                Row(children: _buildAvatars()),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Container(
                                          alignment: Alignment.centerLeft,
                                          child: const Text(
                                            "Planes",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )),
                                      Container(
                                        alignment: Alignment.centerRight,
                                        margin: const EdgeInsets.only(top: 7),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            provider.Provider.of<
                                                AppBarProvider>(
                                                context, listen: false)
                                                .updateAppBar(
                                              AppBar(
                                                title: const Text("Crear Evento"),
                                                centerTitle: true,
                                                leading: IconButton(
                                                  icon: const Icon(
                                                      Icons.arrow_back),
                                                  onPressed: () {
                                                    UserData.idGrupoAmigos =
                                                    null;
                                                    Navigator.of(context)
                                                        .pushReplacement(
                                                      MaterialPageRoute(
                                                          builder: (
                                                              context) =>
                                                              Home(
                                                                indiceInicial: 2,
                                                                isFriendGroup: false,)),
                                                    );
                                                  },
                                                ),
                                                flexibleSpace: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color: Colors
                                                            .grey[300]!,
                                                        // Color del borde sombreado
                                                        width: 3.0, // Ancho del borde
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                            /*Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (context) => Home(indiceInicial: 3,isFriendGroup: true,grupoAmigos: widget.group,)),
                                      );*/
                                            var response = await supabase
                                                .from('gruposamigos')
                                                .select('id')
                                                .eq(
                                                "nombre", widget.group.name)
                                                .eq("descripcion",
                                                widget.group.descripcion);
                                            UserData.idGrupoAmigos =
                                            response[0]['id'];
                                            Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CrearEventoGrupo(
                                                        isFriendGroup: true,)),
                                            );
                                          },
                                          child: const Icon(Icons.add),
                                        ),
                                      )
                                    ]),
                                FutureBuilder<List<Evento>>(
                                  future: Consultas().EventosGrupo(
                                      widget.group.name,
                                      widget.group.descripcion,
                                      widget.group.creador.username),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      List<Evento> eventos = snapshot.data ??
                                          [];
                                      return Center(
                                        child: EventosWidget(
                                            eventos: eventos),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        }
    );
  }
}
