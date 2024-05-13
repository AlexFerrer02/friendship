import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:friendship/Pages/login_page.dart';
import 'package:friendship/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:friendship/Pages/home.dart';
import 'package:friendship/components/my_textfield.dart';
import '../Class/consultas.dart';
import '../Class/usernameAuxiliar.dart';
import '../components/phone_textfield.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class Register extends StatefulWidget {
  Register ({super.key, required this.supabase, required this.gustos});
  final SupabaseClient supabase;
  final List<String> gustos;

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final aliasController = TextEditingController();
  final phoneController = TextEditingController();


  final _KeyForm = GlobalKey<FormState>();


  bool _isredirecting = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    /*widget.supabase.auth.onAuthStateChange.listen((data) {
      if (_isredirecting) return;
      final session = data.session;
      if (session != null) {
        _isredirecting = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Home(indiceInicial: 0,isFriendGroup: false,)),
        );
      }
    });*/
    super.initState();
  }

  void _dialogoUsuarioExiste(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Aviso'),
          content: Text('Ya existe un usuario con este nombre de usuario'),
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

  Future<int> generarNumeroAleatorioUnico() async {
    final Random random = Random();
    int numeroAleatorio = 0;
    do {
      // Genera un número aleatorio entre 0 y 9999999
      numeroAleatorio = random.nextInt(10000000);
      // Verifica si el número ya existe en la base de datos
      final response = await supabase.from('usuarios').select().eq('codigo_amigo', numeroAleatorio);
      if (response.toString() != '[]') {
        // Si el número ya existe, vuelve a intentarlo
        numeroAleatorio = -1; // Puedes establecer cualquier valor que no sea un número válido
      }
    } while (numeroAleatorio == -1);
    return numeroAleatorio;
  }

  Future<void> _signUp() async {
    try {
      await widget.supabase.auth.signUp(password: passwordController.text, email: usernameController.text);
      if (mounted) {

        int codigoAmigo = await generarNumeroAleatorioUnico();

        await supabase.from('usuarios').upsert([
          {
            'telefono': int.parse(phoneController.text),
            'username': aliasController.text,
            'contraseña': passwordController.text,
            'email': usernameController.text,
            'gustos': widget.gustos,
            'codigo_amigo': codigoAmigo,
            'lista_amigos': [],
            'id_grupo': 0
          },
        ]);
        UserData.emailActual=usernameController.text;
        UserData userData = UserData();
        await userData.construirUsuarioPorEmail(UserData.emailActual);

        File? _imageFile;
        final response = await http.get(Uri.parse(
            'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/avatares/emptyprofile.png?t=2024-05-12T18%3A31%3A41.385Z'));
        final documentDirectory = await getTemporaryDirectory();
        final file = File('${documentDirectory.path}/avatar.png');
        await file.writeAsBytes(response.bodyBytes);
        _imageFile = file;
        await supabase
            .storage
            .from('perfiles')
            .upload(UserData.usuarioLog!.username, _imageFile);
        usernameController.clear();
        passwordController.clear();

        _isredirecting = true;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => Home(indiceInicial: 0,isFriendGroup: false,)),
        );
      }
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected error occurred');
    }
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
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginPage(supabase: supabase)),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _KeyForm,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //logo
                  const SizedBox(height: 10,),
                  Image.network(
                    "https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/avatares/ASTRONAUTAGORRO%201.png",
                    height: 230,
                    width: 230,
                  ),
                  const SizedBox(height: 20,),
                  //Nombre/Alias textfield
                  MyTextField(
                    controller: aliasController,
                    hintText: 'Nombre o Alias',
                    obscureText: false,
                  ),
                  //Numero de telefono textfield
                  PhoneTextField(
                    controller: phoneController,
                    hintText: 'Phone number ej. 666 666 666',
                    obscureText: false,
                    maxLength: 9,
                  ),
                  //username textfield
                  MyTextField(
                    controller: usernameController,
                    hintText: 'username@correo.es',
                    obscureText: false,
                  ),
                  const SizedBox(height: 10,),
                  //password textfield
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Contraseña',
                    obscureText: true,
                  ),
                  const SizedBox(height: 15,),
                  GestureDetector(
                    onTap: () async {
                      if (_KeyForm.currentState!.validate()) {
                        bool existeUsername = await Consultas().checkUsername(aliasController.text);

                        if(existeUsername){
                          _dialogoUsuarioExiste(context);
                        } else {
                          _signUp();
                        }
                      }
                    },
                    child: Container(
                      width: 170,
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 17),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFD287F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(71),
                        ),
                      ),
                      child: const Center(
                        child:
                        Text(
                          'Registrarse',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF530577),
                            fontSize: 14,
                            fontFamily: 'Google Sans',
                            fontWeight: FontWeight.w500,
                            height: 0.08,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
