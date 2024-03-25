import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:friendship/Class/filtro.dart';
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
      context: context,
      builder: (BuildContext context) {
        return FittedBox(
          child: AlertDialog(
            title: Text('Filtros'),
            content: IntrinsicHeight(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.event.filtros.map((filtro) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        Image.network(
                          obtenerImagenFiltro(filtro),
                          width: 60,
                          height: 60,
                        ),
                        SizedBox(height: 10),
                        Text(capitalize(filtro)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Ok'),
              ),
            ],
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

  @override
  void initState() {
    super.initState();
    Random random = Random();
    int numRandom = random.nextInt(3) + 1;
    if(numRandom <= 2){
      changeBackgroundColor(Color(0xFF89DAC1));
      changeCirculoColor(Color(0xFF20BD8E));
      imagePath = "https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/avatares/urano.png";
    } else {
      changeBackgroundColor(Color(0xFFFFB01A));
      changeCirculoColor(Color(0xFF694704));
      imagePath = "https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/avatares/saturno.png";
    }
    _descriptionController = TextEditingController(
        text: widget.event.descripcion.replaceAll('"', ""));

    print(widget.event.filtros);
  }

  Future<void> mostrarDialogo(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar'),
          content: Text('¿Estás seguro de que quieres eliminar el evento?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('No'),
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
              child: Text('Sí'),
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
          title: Text('Aviso'),
          content: Text('No eres el creador de este evento, no puedes modificarlo'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text('OK'),
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
            icon: Icon(Icons.delete, color: Color(0xFFC62828),),
            onPressed: () {
              if(widget.event.userName == UserData.usuarioLog!.username){
                mostrarDialogo(context);
              } else {
                _dialogoEventoAjeno(context);
              }
            },
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 3.2,
              width: MediaQuery.of(context).size.width,
              child:
              Center(child:
                Image.network(
                  imagePath,
                  width: 300,
                  height: 300,
                ),
              ),
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
                                      widget.event.name,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
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
                                )
                              ]),
                          isEditingDescription
                              ? TextFormField(
                            controller: _descriptionController,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: 'Ingrese la descripción',
                            ),
                          )
                              : TextFormField(
                            enabled: false,
                            controller: _descriptionController,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: 'Ingrese la descripción',
                            ),
                          ),
                          SizedBox(height: 20.0),
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
                                  SizedBox(width: 20.0),
                                  Row(
                                    children: [
                                      Text(widget.event.fechaInicio,
                                          style: TextStyle(fontSize: 20.0)
                                      ),
                                      SizedBox(width: 10.0),
                                      Text('-',
                                          style: TextStyle(fontSize: 20.0)
                                      ),
                                      SizedBox(width: 10.0),
                                      Text(widget.event.fechaFin,
                                          style: TextStyle(fontSize: 20.0)
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          SizedBox(height: 20,),
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
                                  SizedBox(width: 30.0),
                                  Column(
                                    children: [
                                      Text(widget.event.horaInicio,
                                          style: TextStyle(fontSize: 20.0)
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 25.0),
                                  Text('-',
                                      style: TextStyle(fontSize: 20.0)
                                  ),
                                  SizedBox(width: 22.0),
                                  Column(
                                    children: [
                                      Text(widget.event.horaFin,
                                          style: TextStyle(fontSize: 20.0)
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          SizedBox(height: 10,),
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
                              SizedBox(width: 26.0),
                              Text(widget.event.lugar,
                                  style: TextStyle(fontSize: 20.0)
                              ),
                              SizedBox(width: 37,),
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _showDialog(context);
                                    },
                                    child: Container(
                                      width: 150,
                                      height: 80,
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
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal, // Para hacer que la lista sea deslizable horizontalmente
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: widget.event.filtros.map((filtro) {
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 10), // Ajusta el espacio entre las imágenes
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
