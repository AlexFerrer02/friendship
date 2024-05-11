import 'package:flutter/material.dart';
import 'package:friendship/Pages/register.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class Registro_ampl extends StatefulWidget {

  Registro_ampl({super.key, required this.supabase});
  final SupabaseClient supabase;

  @override
  Registro_amplState createState() => Registro_amplState();
}

class Registro_amplState extends State<Registro_ampl> {

  String deportes = 'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/filtros/deportes.png?t=2023-12-03T15%3A36%3A49.599Z';
  String estudio = 'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/filtros/estudio.png?t=2023-12-03T15%3A37%3A23.052Z';
  String musica = 'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/filtros/musica.png?t=2023-12-03T15%3A37%3A42.658Z';
  String ocio = 'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/filtros/ocio.png?t=2023-12-03T15%3A37%3A58.385Z';

  List<String> selectedImages = [];

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
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromRGBO(215, 146, 240, 1) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
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
    return Scaffold(
      backgroundColor: Colors.grey[310],
      appBar: AppBar(
        title: const Text("Registro"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Elije tus gustos",
                style: TextStyle(
                  fontSize: 25,
                  color: Color.fromRGBO(98, 69, 108, 1),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Google Sans',
                ),
              ),
              const SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      buildSelectableImage(
                          deportes, selectedImages.contains(deportes)),
                      const Text("Deportes", style: TextStyle(color: Color.fromRGBO(98, 69, 108, 1)),),
                      const SizedBox(height: 20),
                      buildSelectableImage(
                          estudio, selectedImages.contains(estudio)),
                      const Text("Estudio", style: TextStyle(color: Color.fromRGBO(98, 69, 108, 1))),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      buildSelectableImage(
                          musica, selectedImages.contains(musica)),
                      const Text("Música", style: TextStyle(color: Color.fromRGBO(98, 69, 108, 1))),
                      const SizedBox(height: 20),
                      buildSelectableImage(
                          ocio, selectedImages.contains(ocio)),
                      const Text("Ocio", style: TextStyle(color: Color.fromRGBO(98, 69, 108, 1))),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 100),
              ElevatedButton(
                onPressed: () async {
                  List<String> filtrosFinales = [];
                  for (var item in selectedImages) {
                    filtrosFinales.add(asignarFiltro(item));
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Register(
                        supabase: widget.supabase,
                        gustos: filtrosFinales,
                      ),
                    ),
                  );
                },
                child: const Text('Siguiente'),
              )
            ],
          ),
        ),
      ),
    );
  }
}