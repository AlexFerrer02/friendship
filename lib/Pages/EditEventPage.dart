import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Class/consultas.dart';
import '../Class/evento.dart';
import '../Class/usernameAuxiliar.dart';
import '../Pages/home.dart';

class CreateEventPage extends StatefulWidget {
  final Evento event;
  final bool esCalendario;

  const CreateEventPage({Key? key, required this.event, required this.esCalendario}) : super(key: key);

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {

  late TextEditingController _descriptionController;
  bool isEditingDescription = false;
  Color backgroundColor = Color(0xFFFFB01A);
  Color circuloColor = Color(0xFF694704);
  String imagePath = '';

  String deportesImagen = 'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/filtros/deportes.png?t=2023-12-03T15%3A36%3A49.599Z';
  String estudioImagen = 'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/filtros/estudio.png?t=2023-12-03T15%3A37%3A23.052Z';
  String musicaImagen = 'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/filtros/musica.png?t=2023-12-03T15%3A37%3A42.658Z';
  String ocioImagen = 'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/filtros/ocio.png?t=2023-12-03T15%3A37%3A58.385Z';

  bool isExpanded = false;

  final supabase = SupabaseClient(
    'https://peaoifidogwgoxzrpjft.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBlYW9pZmlkb2d3Z294enJwamZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTY2MDExNDcsImV4cCI6MjAxMjE3NzE0N30.xPOHo3wz93O9S0kWU9gbGofVWlFOZuA7JB9UMAMoBbA',
  );

  void changeBackgroundColor(Color color) {
    setState(() {
      backgroundColor = color;  // Puedes cambiar esto a cualquier color que desees
    });
  }

  String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  void _showDialog(BuildContext context) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return FittedBox(
          child: AlertDialog(
            title: const Align(
              alignment: Alignment.center,
              child: Text('Filtros'),
            ),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.event.filtros.map((filtro) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      obtenerImagenFiltro(filtro),
                      width: 60,
                      height: 60,
                    ),
                    const SizedBox(height: 10),
                    Text(capitalize(filtro)),
                    const SizedBox(height: 5),
                  ],
                );
              }).toList(),
            )
          ),
        );
      },
    );
  }

  void changeCirculoColor(Color color) {
    setState(() {
      circuloColor = color;  // Puedes cambiar esto a cualquier color que desees
    });
  }

  double divider = 0.0;
  double globalHeight = 0.0;

  @override
  void initState() {
    super.initState();
    Random random = Random();
    int numRandom = random.nextInt(3) + 1;
    if(numRandom <= 2){
      changeBackgroundColor(const Color(0xFF89DAC1));
      changeCirculoColor(const Color(0xFF20BD8E));
      imagePath = "https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/avatares/urano.png";
    } else {
      changeBackgroundColor(const Color(0xFFFFB01A));
      changeCirculoColor(const Color(0xFF694704));
      imagePath = "https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/avatares/saturno.png";
    }
    _descriptionController = TextEditingController(
        text: widget.event.descripcion.replaceAll('"', ""));

    print(widget.event.filtros);

    if(widget.event.filtros.isEmpty){
      divider = 0.0;
      globalHeight = 0.0;
    } else if (widget.event.filtros.length == 1){
      divider = 4.8;
      globalHeight = 80.0;
    } else if (widget.event.filtros.length == 2){
      divider = 2.55;
      globalHeight = 80.0;
    } else if (widget.event.filtros.length == 3){
      divider = 1.75;
      globalHeight = 80.0;
    } else if (widget.event.filtros.length == 4){
      divider = 1.35;
      globalHeight = 80.0;
    }
  }

  Future<void> mostrarDialogo(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar'),
          content: const Text('¿Estás seguro de que quieres eliminar el evento?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await supabase
                    .from('eventos')
                    .delete()
                    .match({ 'id': widget.event.id });
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Home(indiceInicial: 0,isFriendGroup: false,)),
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
          content: const Text('No eres el creador de este evento, no puedes modificarlo'),
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

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  void _dialogoLugar(BuildContext context) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width/1.8,
                child: Text(
                    widget.event.lugar,
                  style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.black
                  ),
                ),
              ),
              const SizedBox(height: 15,),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                    border: Border.all(color: Colors.black)
                ),
                child: IconButton(
                  onPressed: () {
                    _copyToClipboard(context, widget.event.lugar);
                  },
                  icon: const Icon(Icons.content_copy),
                  color: Colors.black,
                ),
              )
            ],
          )
        );
      },
    );
  }

  void _dialogoParticipante(BuildContext context, bool participa) {
    String texto = '';
    if(participa){
      texto = 'Ya participas en este evento.';
    } else {
      texto = 'Te has apuntado al evento con éxito.';
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aviso'),
          content: Text(texto),
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

  Future<bool> _checkCondition() async {
    if(widget.event.userName == UserData.usuarioLog!.username){
      return false;
    } else {
      List<String> amigos = await Consultas().obtenerAmigosEvento(widget.event.id);
      if(amigos.contains(UserData.usuarioLog!.username)){
        return false;
      } else{
        return true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if(widget.esCalendario == true){
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => Home(indiceInicial: 0,isFriendGroup: false,)),
              );
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFC62828),),
            onPressed: () async {
              int idGrupo = await Consultas().getIdGrupoPorUser(widget.event.userName);
              if(idGrupo == 0){
                if(widget.event.userName == UserData.usuarioLog!.username){
                  mostrarDialogo(context);
                } else {
                  _dialogoEventoAjeno(context);
                }
              } else {
                var group = await supabase.from("gruposamigos").select("*").eq("id", idGrupo);
                String creador = group[0]['creador'];
                if(creador == UserData.usuarioLog!.username){
                  mostrarDialogo(context);
                } else {
                  _dialogoEventoAjeno(context);
                }
              }
            },
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: FutureBuilder<bool>(
        future: _checkCondition(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Muestra un indicador de carga mientras se espera la condición
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Maneja el error si ocurre alguno durante la espera
            return const Center(
              child: Text('Error'),
            );
          } else {
            // Si la condición se cumple, el botón se activa; de lo contrario, se desactiva
            bool isButtonEnabled = snapshot.data ?? false;

            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 4.4,
                    width: MediaQuery.of(context).size.width,
                    child:
                    Center(child:
                    Image.network(
                      imagePath,
                      width: 200,
                      height: 200,
                    ),
                    ),
                  ),
                  Stack(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height,
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
                                          widget.event.name,
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                    Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            if(widget.event.userName == UserData.usuarioLog!.username){
                                              _saveChanges();
                                            } else {
                                              _dialogoEventoAjeno(context);
                                            }
                                          },
                                          child: Icon(isEditingDescription
                                              ? Icons.save_alt
                                              : Icons.edit),
                                        ),
                                        const SizedBox(height: 5,),
                                        ElevatedButton(
                                          onPressed: isButtonEnabled
                                              ? () async {
                                            List<String> amigos = await Consultas().obtenerAmigosEvento(widget.event.id);
                                            if(amigos.contains(UserData.usuarioLog!.username)){
                                              _dialogoParticipante(context,true);
                                            } else {
                                              amigos.add(UserData.usuarioLog!.username);
                                              await supabase
                                                  .from('eventos')
                                                  .update({ 'amigos': amigos })
                                                  .match({ 'id': widget.event.id });
                                              _dialogoParticipante(context,false);
                                            }
                                          }
                                              : null, // Si el botón está desactivado, onPressed es null
                                          child: const Icon(Icons.group_add),
                                        )
                                      ],
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
                              const SizedBox(height: 20.0),
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                        decoration: ShapeDecoration(
                                          color: backgroundColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(31),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.calendar_month, size: 40, color: circuloColor,),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 30.0),
                                  Text(widget.event.fechaInicio,
                                      style: const TextStyle(fontSize: 20.0)
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20,),
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                        decoration: ShapeDecoration(
                                          color: backgroundColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(31),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.timer_sharp, size: 40, color: circuloColor,),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 30.0),
                                  Column(
                                    children: [
                                      Text(widget.event.horaInicio,
                                          style: const TextStyle(fontSize: 20.0)
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 25.0),
                                  const Text('-',
                                      style: TextStyle(fontSize: 20.0)
                                  ),
                                  const SizedBox(width: 22.0),
                                  Column(
                                    children: [
                                      Text(widget.event.horaFin,
                                          style: const TextStyle(fontSize: 20.0)
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                    decoration: ShapeDecoration(
                                      color: backgroundColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(31),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.location_on_outlined, size: 40, color: circuloColor,),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 30.0),
                                  GestureDetector(
                                    onTap: () async {
                                      _dialogoLugar(context);
                                    },
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width/1.6,
                                      child: Text(widget.event.lugar,
                                        style: const TextStyle(fontSize: 20.0),
                                        maxLines: 1,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 5,),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if(widget.event.filtros.isNotEmpty){
                                        _showDialog(context);
                                      }
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width/divider,
                                      height: globalHeight,
                                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                      decoration: ShapeDecoration(
                                        color: backgroundColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          side: BorderSide(
                                            color: circuloColor, // Color del borde
                                            width: 2.0, // Ancho del borde
                                          ),
                                        ),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: widget.event.filtros.map((filtro) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 5), // Ajusta el espacio entre las imágenes
                                              child: Image.network(
                                                obtenerImagenFiltro(filtro),
                                                width: 60,
                                                height: 60,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  String obtenerImagenFiltro(String filtro){
    if(filtro == 'ocio'){
      return ocioImagen;
    } else if(filtro == 'deportes'){
      return deportesImagen;
    } else if(filtro == 'musica'){
      return musicaImagen;
    } else {
      return estudioImagen;
    }
  }

  Future<void> _saveChanges() async {
    int id = widget.event.id;
    setState(() {
      if (isEditingDescription) {
        widget.event.descripcion = '"${_descriptionController.text}"';
        Consultas().EditEvento(id, widget.event.descripcion.replaceAll('"', ""));
      }
      isEditingDescription = !isEditingDescription;
    });
  }
}
