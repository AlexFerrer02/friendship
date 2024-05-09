import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:friendship/Class/GlobalData.dart';
import 'package:friendship/Pages/splash.dart';
import 'package:friendship/Widgets/qr.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Class/usernameAuxiliar.dart';
import 'editar_gustos.dart';
import 'login_page.dart';
import 'package:friendship/components/my_textfield.dart';
import 'package:friendship/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

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

  @override
  void initState() {
    super.initState();
    mostrarTrofeos(eventosUsuario);
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

  void launchWhatsApp({required String phone}) async {
    String nombreUsuario = UserData.usuarioLog!.username;
    String numeroSinPlus = phone.replaceAll('+', '');
    //print(nombreUsuario);
    //print(numeroSinPlus);

    final Uri whatsappUrl = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: numeroSinPlus,
      queryParameters: {
        'text': 'https://aplicacionpin.000webhostapp.com/redireccion.html?username=$nombreUsuario',
      },
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      throw 'Could not launch';
    }
  }

  String quitarEspaciosEnBlanco(String cadena) {
    return cadena.replaceAll(' ', ''); // Reemplaza los espacios en blanco por una cadena vacía.
  }

  void mostrarOpcionesDeAvatar() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cambiar Avatar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Astronauta'),
                onTap: () {
                  cambiarAvatar(
                    'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/avatares/monigote.png?t=2023-12-10T18%3A51%3A09.428Z',
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Astronauta con gorro'),
                onTap: () {
                  cambiarAvatar(
                      "https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/avatares/ASTRONAUTAGORRO%201.png");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Helicóptero'),
                onTap: () {
                  cambiarAvatar(
                      'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/avatares/helicoptero.png?t=2023-11-28T10%3A26%3A04.315Z');
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

  void _mostrarPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: 300.0, // Establecer un ancho específico para el AlertDialog
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QRImage(200),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Acción a realizar cuando se hace clic en el botón
                    Navigator.of(context).pop(); // Cierra el popup
                  },
                  child: Text('Cerrar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void mostrarOpciones() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Configuraciones'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                // Contenido de la ventana emergente (ajustes, idioma, notificaciones, etc.)

                ListTile(
                  title: Text('Notificaciones'),
                  subtitle: Text('Activar/desactivar notificaciones'),
                  trailing: Checkbox(
                    value: notificationEnabled,
                    onChanged: (bool? value) {
                      setState(() {
                        notificationEnabled = !notificationEnabled;
                        Navigator.pop(context);
                        // Aquí puedes incluir la lógica para activar o desactivar las notificaciones
                        // Por ejemplo, invocar métodos del plugin de notificaciones
                        // Para simplicidad, aquí solo se actualiza el estado de la casilla
                      });
                    },

                  ),
                ),
                ListTile(
                  title: Text('Cerrar sesión'),
                  onTap: () async {
                    try {
                      LoginPage loginPageInstance = new LoginPage(supabase: supabase);
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

  bool verTrofeos = true;
  bool mostrarQR = false;
  bool mostrarEnlace = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil"),
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
            icon: Icon(Icons.settings),
            onPressed: () {
              mostrarOpciones(); // Mostrar el diálogo de configuración
            },
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFECC8FD),
        child: Column(
          children: [
            Expanded(
              // Mitad superior con el avatar centrado
              child: Container(
                color: Color(0xFFECC8FD),
                child: Stack(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {

                        },
                        child: Image.network(
                          avatar,
                          height: 250,
                          width: 250,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8.0,
                      right: 8.0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFECC8FD),
                        ),
                        child: IconButton(
                          onPressed: () {
                            mostrarOpcionesDeAvatar();
                          },
                          icon: Icon(Icons.edit),
                          color: Color.fromRGBO(83, 6, 119, 1),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50.0,
                      right: 8.0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFECC8FD),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => Gustos_pag()),
                            );
                          },
                          icon: Icon(Icons.add_reaction_outlined),
                          color: Color.fromRGBO(83, 6, 119, 1),
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
                   child: Column(
                      children: [
                        SizedBox(height: 25),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              UserData.usuarioLog!.username,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 32,
                                fontFamily: 'Google Sans',
                                fontWeight: FontWeight.w700,
                                height: 0.03,
                              ),
                          ),
                        ),
                        ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      verTrofeos = true;
                      mostrarQR = false;
                      mostrarEnlace = false;
                    });
                  },
                  child: Column(
                    children: [
                      Icon(
                          Icons.emoji_events,
                          color: verTrofeos ? Color(0xFFECC8FD) : Colors.black
                      ), // Cambia por el icono deseado
                      SizedBox(height: 8),
                      Text(
                          'Trofeos',
                        style: TextStyle(
                          color: verTrofeos ? Color(0xFFECC8FD) : Colors.black,
                        ),), // Texto para el botón
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      verTrofeos = false;
                      mostrarQR = true;
                      mostrarEnlace = false;
                    });
                  },
                  child: Column(
                    children: [
                      Icon(
                          Icons.qr_code,
                          color: mostrarQR ? Color(0xFFECC8FD) : Colors.black
                      ), // Cambia por el icono deseado
                      SizedBox(height: 8),
                      Text(
                          'QR',
                        style: TextStyle(
                          color: mostrarQR ? Color(0xFFECC8FD) : Colors.black,
                        ),
                      ), // Texto para el botón
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      verTrofeos = false;
                      mostrarQR = false;
                      mostrarEnlace = true;
                    });
                  },
                  child: Column(
                    children: [
                      Icon(
                          Icons.link,
                          color: mostrarEnlace ? Color(0xFFECC8FD) : Colors.black
                      ), // Cambia por el icono deseado
                      SizedBox(height: 8),
                      Text(
                          'Enlace',
                          style: TextStyle(
                            color: mostrarEnlace ? Color(0xFFECC8FD) : Colors.black,
                          ),
                      ), // Texto para el botón
                    ],
                  ),
                ),

              ],
            ),
            SizedBox(height: 20),
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
                        SizedBox(height: 20),
                        Text('1 evento'),
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
                        SizedBox(height: 20),
                        Text('25 eventos'),
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
                        SizedBox(height: 20),
                        Text('50 eventos'),
                      ],
                    ),
                  ),
                ],
              ),
            if (mostrarQR)
            // Muestra el código QR aquí
            // Ejemplo:
              GestureDetector(
                onTap: () {
                  _mostrarPopup(context);
                },
                child: QRImage(50),
              ),
            if (mostrarEnlace)
            // Muestra el enlace de WhatsApp o cualquier otro enlace aquí
            // Ejemplo:
              GestureDetector(
                onTap: () async {
                  final granted =
                  await FlutterContactPicker.requestPermission();

                  final PhoneContact contact =
                  await FlutterContactPicker.pickPhoneContact();
                  telefono = contact!.phoneNumber!.number.toString();

                  telefono = quitarEspaciosEnBlanco(telefono);

                  launchWhatsApp(phone: telefono);
                },
                child: Image.network(
                  'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/avatares/wasa.png',
                  width: 100.0,
                  height: 100.0,
                ),
              ),
          ],
        ),
      ),
    ),

    ]
        )
    )
    );
  }
}