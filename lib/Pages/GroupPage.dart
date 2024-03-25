import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:friendship/Class/consultas.dart';
import 'package:friendship/Class/grupo-amigos.dart';
import '../Class/appbar.dart';
import '../Class/evento.dart';
import '../Class/user.dart';
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
  List<User> amigos = [];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
        text: widget.group.descripcion.replaceAll('"', ""));
    amigos = [];
    amigos.addAll(widget.group.amigos);
  }

  List<Widget> _buildAvatars() {
    List<Widget> avatars = [];

    for (User participante in amigos) {
      String initials = participante.username.substring(0, 1).toUpperCase();
      avatars.add(
        Center(
          child: CircleAvatar(
            maxRadius: 15,
            backgroundColor: Color(0xFF032A64),
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return avatars;
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

  void _showListPopup(BuildContext context, List<User> users) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Lista de Amigos'),
          content: Column(
            children: [
              for (User user in users)
                GestureDetector(
                  onTap: () async {
                    int id = await widget.group.ObtenerId();
                    await Consultas().addAmigoAGrupoAmigos(id, user);
                    Navigator.of(context).pop();
                    build(context);
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        maxRadius: 15,
                        backgroundColor: Color(0xFF032A64),
                        child: Text(
                          user.username.substring(0, 1),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(user.username),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Home(indiceInicial: 2,isFriendGroup: false,)),
            );
          },
        ),
      ),
      backgroundColor: Color(0xFFE7DBF7),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 2.9,
              width: MediaQuery.of(context).size.width,
              child:
                  Center(child: Image.asset("assets/SistemaSolarMorado.png")),
            ),
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: Expanded(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      List<User> users =
                                          await Consultas().ObtenerAmigos();
                                      _showListPopup(context, users);
                                    },
                                    child: const Icon(Icons.group_add),
                                  ),
                                )
                              ]),
                          Row(children: _buildAvatars()),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  child: ElevatedButton(
                                    onPressed: () {
                                      provider.Provider.of<AppBarProvider>(context, listen: false).updateAppBar(
                                        AppBar(title: Text("Crear Evento"), centerTitle: true,
                                          flexibleSpace: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey[300]!, // Color del borde sombreado
                                                  width: 3.0, // Ancho del borde
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (context) => Home(indiceInicial: 3,isFriendGroup: true,grupoAmigos: widget.group.name,)),
                                      );
                                    },
                                    child: const Icon(Icons.add),
                                  ),
                                )
                              ]),
                          FutureBuilder<List<Evento>>(
                            future: Consultas().EventosGrupo(widget.group.name),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                List<Evento> eventos = snapshot.data ?? [];
                                return Center(
                                  child: EventosWidget(eventos: eventos),
                                );
                              }
                            },
                          ),
                        ],
                      ),
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
