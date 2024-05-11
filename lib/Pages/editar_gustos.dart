import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:friendship/Class/usernameAuxiliar.dart';

import '../Class/consultas.dart';
import 'home.dart';


class Gustos_pag extends StatefulWidget {

  Gustos_pag({super.key});

  @override
  Gustos_pagState createState() => Gustos_pagState();
}

class Gustos_pagState extends State<Gustos_pag> {

  String deportes = 'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/filtros/deportes.png?t=2023-12-03T15%3A36%3A49.599Z';
  String estudio = 'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/filtros/estudio.png?t=2023-12-03T15%3A37%3A23.052Z';
  String musica = 'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/filtros/musica.png?t=2023-12-03T15%3A37%3A42.658Z';
  String ocio = 'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/filtros/ocio.png?t=2023-12-03T15%3A37%3A58.385Z';

  final supabase = SupabaseClient(
    'https://peaoifidogwgoxzrpjft.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBlYW9pZmlkb2d3Z294enJwamZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTY2MDExNDcsImV4cCI6MjAxMjE3NzE0N30.xPOHo3wz93O9S0kWU9gbGofVWlFOZuA7JB9UMAMoBbA',
  );

  late Future<void> _fetchDataFuture;

  List<String> selectedImages = [];

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchData();
  }

  Future<void> fetchData() async {
    List<String> gustos = await Consultas().getGustosUsuario(UserData.usuarioLog!.username);
    if(gustos.contains('deportes')){ selectedImages.add(deportes);}
    if(gustos.contains('ocio')){ selectedImages.add(ocio);}
    if(gustos.contains('musica')){ selectedImages.add(musica);}
    if(gustos.contains('estudio')){ selectedImages.add(estudio);}
  }

  void toggleImageSelection(String imagePath) {
    setState(() {
      if (selectedImages.contains(imagePath)) {
        selectedImages.remove(imagePath);
      } else {
        selectedImages.add(imagePath);
      }
    });
  }

  String asignarFiltro(String filtro){
    if(filtro == musica){
      return 'musica';
    } else if(filtro == deportes){
      return 'deportes';
    } else if(filtro == ocio){
      return 'ocio';
    } else {
      return 'estudio';
    }
  }

  Widget buildSelectableImage(String imagePath, bool isSelected) {
    return GestureDetector(
      onTap: () {
        toggleImageSelection(imagePath);
      },
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.network(
          imagePath,
          width: 100,
          height: 100,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Scaffold(
            backgroundColor: Colors.grey[310],
            appBar: AppBar(
              title: Text("Gustos"),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => Home(indiceInicial: 5,isFriendGroup: false,)),
                  );
                },
              ),
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Elije tus gustos"),
                    SizedBox(height: 100),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            buildSelectableImage(
                                deportes, selectedImages.contains(deportes)),
                            Text("Deportes"),
                            SizedBox(height: 20),
                            buildSelectableImage(
                                estudio, selectedImages.contains(estudio)),
                            Text("Estudio"),
                          ],
                        ),
                        SizedBox(width: 20),
                        Column(
                          children: [
                            buildSelectableImage(
                                musica, selectedImages.contains(musica)),
                            Text("Música"),
                            SizedBox(height: 20),
                            buildSelectableImage(
                                ocio, selectedImages.contains(ocio)),
                            Text("Ocio"),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 100),
                    ElevatedButton(
                      onPressed: () async {
                        List<String> filtrosFinales = [];
                        for (var item in selectedImages) {
                          filtrosFinales.add(asignarFiltro(item));
                        }
                        await supabase
                            .from('usuarios')
                            .update({ 'gustos': filtrosFinales })
                            .match({ 'username': UserData.usuarioLog!.username });
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => Home(indiceInicial: 5,isFriendGroup: false,)),
                        );
                      },
                      child: Text('Ok'),
                    )
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}