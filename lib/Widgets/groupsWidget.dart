import 'dart:io';

import 'package:flutter/material.dart';
import 'package:friendship/Class/grupo-amigos.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Class/user.dart' as Users;
import '../Pages/GroupPage.dart';

class GroupsWidget extends StatelessWidget {
  final GrupoAmigos grupo;

  GroupsWidget({Key? key, required this.grupo}) : super(key: key);

  final supabase = SupabaseClient(
    'https://peaoifidogwgoxzrpjft.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBlYW9pZmlkb2d3Z294enJwamZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTY2MDExNDcsImV4cCI6MjAxMjE3NzE0N30.xPOHo3wz93O9S0kWU9gbGofVWlFOZuA7JB9UMAMoBbA',
  );

  Future<List<Widget>> _buildAvatars() async {
    List<Widget> avatars = [];

    for (Users.User participante in grupo.amigos) {
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
    }

    return avatars;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350,
        height: 403,
        decoration: BoxDecoration(
          color: const Color(0xFF5094F9),
          borderRadius: BorderRadius.circular(25),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => GroupPage(group: grupo)),
            );
          },
          child: Stack(
            children: [
              Positioned(
                left: 20,
                top: 40,
                child: Text(
                  grupo.name,
                  style: const TextStyle(
                    color: Color(0xFF032A64),
                    fontSize: 30,
                    fontFamily: 'Google Sans',
                    fontWeight: FontWeight.w500,
                    height: 0.04,
                  ),
                ),
              ),
              Positioned.fill(
                right: -28,
                child: Image.asset("assets/SistemaSolarAzul.png"),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: 350,
                  height: 53,
                  alignment: Alignment.bottomCenter,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                    child: FutureBuilder<List<Widget>>(
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
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
