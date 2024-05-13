
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Class/consultas.dart';
import '../Class/usernameAuxiliar.dart';
import 'editar_gustos.dart';
import 'login_page.dart';
import 'package:friendship/components/my_textfield.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final supabase = SupabaseClient(
    'https://peaoifidogwgoxzrpjft.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBlYW9pZmlkb2d3Z294enJwamZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTY2MDExNDcsImV4cCI6MjAxMjE3NzE0N30.xPOHo3wz93O9S0kWU9gbGofVWlFOZuA7JB9UMAMoBbA',
  );
  String avatar =
      'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/avatares/monigote.png?t=2023-12-10T18%3A51%3A09.428Z'
  ;
  bool notificationEnabled = true;
  String selectedLanguage = 'Español';
  final String trofeoImagen =
      "https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/avatares/trofeo.png?t=2023-12-10T18%3A29%3A10.900Z";
  final String noTrofeoImagen =
      "https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/avatares/noTrofeo.png?t=2023-11-26T18%3A17%3A57.454Z";

  final int eventosUsuario = UserData.usuarioLog!.eventosCreados;
  var trofeo1 = '';
  var trofeo2 = '';
  var trofeo3 = '';
  var telefono = '';

  int codigoAmigo = 0;

  int miCodigoAmigo = 0;

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Texto copiado al portapapeles'),
      ),
    );
  }

  void mostrarTrofeos(int eventosCreados) {
    if (eventosCreados >= 1) {
      trofeo1 = trofeoImagen;
    } else {
      trofeo1 = noTrofeoImagen;
    }
    if (eventosCreados >= 25) {
      trofeo2 = trofeoImagen;
    } else {
      trofeo2 = noTrofeoImagen;
    }
    if (eventosCreados >= 50) {
      trofeo3 = trofeoImagen;
    } else {
      trofeo3 = noTrofeoImagen;
    }
  }

  void mostrarOpcionesDeAvatar() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambiar Avatar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Astronauta'),
                onTap: () {
                  cambiarAvatar(
                    'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/avatares/monigote.png?t=2023-12-10T18%3A51%3A09.428Z',
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Astronauta con gorro'),
                onTap: () {
                  cambiarAvatar(
                      "https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/avatares/ASTRONAUTAGORRO%201.png");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void cambiarAvatar(String nuevaUrlAvatar) {
    setState(() {
      avatar = nuevaUrlAvatar;
    });
  }

  void _dialogoAmigo(BuildContext context, bool esCodigoPropio) {
    String text = '';
    if(esCodigoPropio){
      text = 'No puedes añadirte a ti mismo como amigo.';
    } else {
      text = 'No existe usuario con ese código de amigo.';
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aviso'),
          content: Text(text),
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

  void _dialogoAmigoExiste(BuildContext context, bool existeAmigo, String usuario) {
    String text = '';
    if(existeAmigo){
      text = 'Ya eres amigo de este usuario.';
    } else {
      text = 'Ahora eres amigo de $usuario.';
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aviso'),
          content: Text(text),
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

  void mostrarOpciones() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Configuraciones'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(
                  title: const Text('Cerrar sesión'),
                  onTap: () async {
                    try {
                      LoginPage loginPageInstance = LoginPage(supabase: supabase);
                      loginPageInstance.setCerrarSesion();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => loginPageInstance),
                      );
                    } on AuthException catch (error) {
                      context.showErrorSnackBar(message: error.message);
                    } catch (error) {
                      context.showErrorSnackBar(message: 'Unexpected error occurred');
                    }
                  }, // Cierra el diálogo
                  // },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  File? image;

  late Future<void> _fetchDataFuture;

  @override
  void initState() {
    super.initState();
    mostrarTrofeos(eventosUsuario);
    _fetchDataFuture = fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchDataFuture = fetchData(); // Llama a fetchData() nuevamente al cambiar de dependencias
  }

  Future<void> fetchData() async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempFileName = 'temp_image_$timestamp.png';

    final tempFile = File('${tempDir.path}/$tempFileName');
    final storageResponse = await supabase
        .storage
        .from('perfiles')
        .download(UserData.usuarioLog!.username);
    await tempFile.writeAsBytes(storageResponse);
    setState(() {
      image = tempFile;
    });
  }

  Future pickImage() async {
    try {
      final pickedImage  = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage  == null) return;
      final imageTemp = File(pickedImage.path);
      setState(() {
        image = imageTemp;
      });
      await uploadImage();
    } on PlatformException catch(e) {
      print('Failed to pick image: $e');
    }
  }

  Future<void> uploadImage() async {
    if (image == null) {
      print('No image selected');
      return;
    }

    await supabase
        .storage
        .from('perfiles')
    .update(UserData.usuarioLog!.username, image!);
    setState(() {});
  }

  bool verTrofeos = true;
  bool mostrarEnlace = false;
  bool miCodigo = false;
  bool isHovered = false;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        centerTitle: true,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              mostrarOpciones(); // Mostrar el diálogo de configuración
            },
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _fetchDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Container(
                color: const Color(0xFFECC8FD),
                child: Column(
                    children: [
                      Expanded(
                        // Mitad superior con el avatar centrado
                        child: Container(
                            color: const Color(0xFFECC8FD),
                            child: Stack(
                              children: [
                                Center(
                                  child: GestureDetector(
                                    onTap: () async {
                                      await pickImage();
                                    },
                                    child: Container(
                                      height: MediaQuery.of(context).size.height/3.2,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white, // Color de fondo gris claro
                                        image: image != null
                                            ? DecorationImage(
                                          image: FileImage(image!),
                                          fit: BoxFit.cover,
                                        )
                                            : null, // No hay imagen si image es null
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8.0,
                                  right: 8.0,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFECC8FD),
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(builder: (context) => Gustos_pag()),
                                        );
                                      },
                                      icon: const Icon(Icons.add_reaction_outlined),
                                      color: const Color.fromRGBO(83, 6, 119, 1),
                                    ),
                                  ),
                                )
                              ],
                            )
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 25),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Text(
                                      UserData.usuarioLog!.username,
                                      style: const TextStyle(
                                        color: Color.fromRGBO(98, 69, 108, 1),
                                        fontSize: 32,
                                        fontFamily: 'Google Sans',
                                        fontWeight: FontWeight.w700,
                                        height: 0.03,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          verTrofeos = true;
                                          mostrarEnlace = false;
                                          miCodigo = false;
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Icon(
                                              Icons.emoji_events,
                                              color: verTrofeos ? const Color.fromRGBO(215, 146, 240, 1) : const Color.fromRGBO(98, 69, 108, 1)
                                          ), // Cambia por el icono deseado
                                          const SizedBox(height: 8),
                                          Text(
                                            'Trofeos',
                                            style: TextStyle(
                                              color: verTrofeos ? const Color.fromRGBO(215, 146, 240, 1) : const Color.fromRGBO(98, 69, 108, 1),
                                            ),), // Texto para el botón
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          verTrofeos = false;
                                          mostrarEnlace = true;
                                          miCodigo = false;
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Icon(
                                              Icons.contact_mail_rounded,
                                              color: mostrarEnlace ? const Color.fromRGBO(215, 146, 240, 1) : const Color.fromRGBO(98, 69, 108, 1)
                                          ), // Cambia por el icono deseado
                                          const SizedBox(height: 8),
                                          Text(
                                            'Buscar amigo',
                                            style: TextStyle(
                                              color: mostrarEnlace ? const Color.fromRGBO(215, 146, 240, 1) : const Color.fromRGBO(98, 69, 108, 1),
                                            ),
                                          ), // Texto para el botón
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        miCodigoAmigo = await Consultas().getCodigoPropio();
                                        setState(() {
                                          verTrofeos = false;
                                          mostrarEnlace = false;
                                          miCodigo = true;
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Icon(
                                              Icons.contacts_rounded,
                                              color: miCodigo ? const Color.fromRGBO(215, 146, 240, 1) : const Color.fromRGBO(98, 69, 108, 1)
                                          ), // Cambia por el icono deseado
                                          const SizedBox(height: 8),
                                          Text(
                                            'Mi código',
                                            style: TextStyle(
                                              color: miCodigo ? const Color.fromRGBO(215, 146, 240, 1) : const Color.fromRGBO(98, 69, 108, 1),
                                            ),), // Texto para el botón
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                if (verTrofeos)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.network(
                                              trofeo1,
                                              height: 100,
                                              width: 100,
                                            ),
                                            const SizedBox(height: 20),
                                            const Text('1 evento', style: TextStyle(color: Color.fromRGBO(98, 69, 108, 1)),),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.network(
                                              trofeo2,
                                              height: 100,
                                              width: 100,
                                            ),
                                            const SizedBox(height: 20),
                                            const Text('25 eventos', style: TextStyle(color: Color.fromRGBO(98, 69, 108, 1)),),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.network(
                                              trofeo3,
                                              height: 100,
                                              width: 100,
                                            ),
                                            const SizedBox(height: 20),
                                            const Text('50 eventos', style: TextStyle(color: Color.fromRGBO(98, 69, 108, 1)),),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                if (miCodigo)
                                // Muestra el enlace de WhatsApp o cualquier otro enlace aquí
                                // Ejemplo:
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const SizedBox(height: 30,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            miCodigoAmigo.toString(),
                                            style: const TextStyle(
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(83, 6, 119, 1)
                                            ),
                                          ),
                                          const SizedBox(width: 10,),
                                          Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFECC8FD),
                                            ),
                                            child: IconButton(
                                              onPressed: () {
                                                _copyToClipboard(context, miCodigoAmigo.toString());
                                              },
                                              icon: const Icon(Icons.content_copy),
                                              color: const Color.fromRGBO(83, 6, 119, 1),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                if (mostrarEnlace)
                                // Muestra el enlace de WhatsApp o cualquier otro enlace aquí
                                // Ejemplo:
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const SizedBox(height: 10,),
                                      const Text('Buscar amigo por código',
                                          style: TextStyle(
                                            color: Color.fromRGBO(83, 6, 119, 1),
                                            fontSize: 20,
                                          )),
                                      const SizedBox(height: 10,),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 70.0),
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                                            counterText: '',
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLength: 15,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          onChanged: (text){
                                            codigoAmigo = int.parse(text);
                                          },
                                          onEditingComplete: (){
                                            FocusScope.of(context).unfocus();
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 20.0),
                                      ElevatedButton(
                                        onPressed: () async {
                                          String usuario = await Consultas().buscarPorCodigoAmigo(codigoAmigo);
                                          if(usuario == ''){
                                            _dialogoAmigo(context, false);
                                          }else if (usuario == UserData.usuarioLog!.username) {
                                            _dialogoAmigo(context, true);
                                          }else {
                                            bool existeAmigo = await Consultas().checkAmigo(usuario);
                                            if(existeAmigo){
                                              _dialogoAmigoExiste(context, true, usuario);
                                            } else {
                                              await Consultas().addAmigo(usuario);
                                              _dialogoAmigoExiste(context, false, usuario);
                                            }
                                          }
                                        },
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFECC8FD)), // Color de fondo del botón
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0), // Bordes redondeados del botón
                                            ),
                                          ),
                                          // Otros estilos que desees cambiar...
                                        ),
                                        child: const Text(
                                          "Añadir",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ), // Texto del botón
                                      ),
                                    ],
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),

                    ]
                )
            );
          }
        }
      )
    );
  }
}