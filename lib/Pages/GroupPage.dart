import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:friendship/Class/consultas.dart';
import 'package:friendship/Class/grupo-amigos.dart';
import 'package:friendship/Class/usernameAuxiliar.dart';
import 'package:friendship/Pages/crearEventoGrupo.dart';
import 'package:path_provider/path_provider.dart';
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

  Future<List<Widget>> _buildAvatars() async {
    List<Widget> avatars = [];
    int contador = 1;

    for (Users.User participante in widget.group.amigos) {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFileName = 'temp_image_$timestamp.png';

      final tempFile = File('${tempDir.path}/$tempFileName');
      final storageResponse = await supabase
          .storage
          .from('perfiles')
          .download(participante.username);
      await tempFile.writeAsBytes(storageResponse);
      avatars.add(
          Row(
            children: [
              const SizedBox(width: 5,),
              Center(
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white, // Color de fondo gris claro
                    image: tempFile != null
                        ? DecorationImage(
                      image: FileImage(tempFile!),
                      fit: BoxFit.cover,
                    )
                        : null, // No hay imagen si image es null
                  ),
                ),
              ),
            ],
          )
      );

      if(contador==3){break;}
      contador++;
    }

    if(widget.group.amigos.length>3){
      avatars.add(
        const Text(
          '...',
          style: TextStyle(
              color: Colors.grey,
              fontSize: 20,
              fontFamily: 'Google Sans',
              fontWeight: FontWeight.w500
          ),
        ),
      );
    }

    return avatars;
  }

  Future<List<Widget>> getParticipantesGrupo(BuildContext contexto) async {
    List<Widget> avatars = [];

    for (Users.User amigo in widget.group.amigos) {
      if(amigo.username != UserData.usuarioLog!.username){
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
                    } ,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white, // Color de fondo gris claro
                        image: tempFile != null
                            ? DecorationImage(
                          image: FileImage(tempFile!),
                          fit: BoxFit.cover,
                        )
                            : null, // No hay imagen si image es null
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
                    icon: const Icon(Icons.delete, color: Color(0xFFC62828),),
                    onPressed: () async {
                      int id = await widget.group.ObtenerId();
                      await Consultas().rmAmigoDeGrupoAmigos(id, amigo);
                      Navigator.of(contexto).pushReplacement(
                        MaterialPageRoute(builder: (context) => GroupPage(group: widget.group)),
                      );
                    },
                  ),
                ],
              ),
            )
        );
      }
    }

    return avatars;
  }

  Future<List<Widget>> getAmigosGrupo(BuildContext contexto, List<Users.User> users) async {
    List<Widget> avatars = [];

    for (Users.User amigo in users) {
      if(!participantes.contains(amigo.username)){
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
                    } ,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white, // Color de fondo gris claro
                        image: tempFile != null
                            ? DecorationImage(
                          image: FileImage(tempFile!),
                          fit: BoxFit.cover,
                        )
                            : null, // No hay imagen si image es null
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
                    icon: const Icon(Icons.add, color: Colors.blue,),
                    onPressed: () async {
                      int id = await widget.group.ObtenerId();
                      await Consultas().addAmigoAGrupoAmigos(id, amigo);
                      Navigator.of(contexto).pushReplacement(
                        MaterialPageRoute(builder: (context) => GroupPage(group: widget.group)),
                      );
                    },
                  ),
                ],
              ),
            )
        );
      }
    }

    return avatars;
  }

  Future<void> mostrarParticipantes(BuildContext context) async {
    return showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: FutureBuilder<List<Widget>>(
            future: getParticipantesGrupo(context), // Llama a la función asincrónica que devuelve una lista de widgets
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
                  mainAxisSize: MainAxisSize.min,
                  children: snapshot.data!,
                );
              }
            },
          ),
        );
      },
    );
  }

  Future<void> mostrarAmigos(BuildContext context, List<Users.User> users) async {
    return showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: FutureBuilder<List<Widget>>(
            future: getAmigosGrupo(context, users), // Llama a la función asincrónica que devuelve una lista de widgets
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
                  mainAxisSize: MainAxisSize.min,
                  children: snapshot.data!,
                );
              }
            },
          ),
        );
      },
    );
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

  void _dialogoEliminarAjeno(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aviso'),
          content: const Text('Solo el creador del grupo puede eliminar participantes.'),
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
                                        child: Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                List<Users.User> users =
                                                await Consultas().ObtenerAmigos();
                                                mostrarAmigos(context, users);
                                              },
                                              child: const Icon(Icons.group_add),
                                            ),
                                            const SizedBox(width: 5,),
                                            ElevatedButton(
                                              onPressed: () async {
                                                if(UserData.usuarioLog!.username == widget.group.creador.username){
                                                  await mostrarParticipantes(context);
                                                } else {
                                                  _dialogoEliminarAjeno(context);
                                                }
                                              },
                                              child: const Icon(Icons.group_remove),
                                            ),
                                          ],
                                        )
                                      )
                                    ]),
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
                                      return Row(
                                        children: snapshot.data!,
                                      );
                                    }
                                  },
                                ),
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
