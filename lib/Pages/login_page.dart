import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:friendship/Pages/pantalla_registro_ampliacion.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:friendship/main.dart';
import 'package:friendship/Pages/home.dart';
import 'package:friendship/Pages/register.dart';
import 'package:friendship/components/my_textfield.dart';
import 'perfil.dart';
import '../components/cuadrado.dart';
import 'package:friendship/Class/usernameAuxiliar.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key, required this.supabase});
  final SupabaseClient supabase;

  @override
  State<LoginPage> createState() => _LoginPageState();

  void setCerrarSesion() {
    _LoginPageState.cerrarSesion = true;
  }
}

class _LoginPageState extends State<LoginPage> {
  bool _isRedirecting = false;
  static bool cerrarSesion = false;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final _KeyForm = GlobalKey<FormState>();


  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    if(cerrarSesion){
      cerrarSesion=false;
      supabase.auth.signOut();
      sleep(Duration(seconds: 1));
    }
    widget.supabase.auth.onAuthStateChange.listen((data) async {
      if (_isRedirecting) return;
      final session = data.session;
      if (session != null) {
        _isRedirecting = true;
        UserData.emailActual= data.session!.user.email;

        UserData userData = UserData();
        userData.construirUsuarioPorEmail(UserData.emailActual);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Home(indiceInicial: 0,isFriendGroup: false,)),
        );
      }
    });
    super.initState();
  }

  Future<void> _signIn() async {
    try {
      await widget.supabase.auth.signInWithPassword(email: usernameController.text, password: passwordController.text);
      if (mounted) {
        UserData.emailActual=usernameController.text;
        UserData userData = UserData();
        userData.construirUsuarioPorEmail(UserData.emailActual);
        usernameController.clear();
        passwordController.clear();


        _isRedirecting = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Home(indiceInicial: 0,isFriendGroup: false,)),
        );
      }
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected error occurred');
    }
  }

  TextStyle commonTextStyle = TextStyle(
    color: Color(0xFF555555),
    fontSize: 12,
    fontFamily: 'Google Sans',
    fontWeight: FontWeight.w400,
    height: 0.09,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[310],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _KeyForm,
              child: Column(
                children: [
                Image.network(
                'https://peaoifidogwgoxzrpjft.supabase.co/storage/v1/object/public/avatares/monigote.png?t=2023-12-10T18%3A51%3A09.428Z',
                height: 230,
                width: 230,
                ),
                  SizedBox(
                    width: 255,
                    child: Text(
                      '¡Bienvenido a Friend.ship!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 36,
                        fontFamily: 'Google Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 35.0), // Ajusta el valor según sea necesario
                        child: Text(
                          'Correo electrónico',
                          textAlign: TextAlign.left,
                          style: commonTextStyle,
                        ),
                      ),
                      const SizedBox(height: 10,),
                      MyTextField(
                        controller: usernameController,
                        hintText: 'username@correo.es',
                        obscureText: false,
                      ),
                      const SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.only(left: 35.0), // Ajusta el valor según sea necesario
                        child: Text(
                          'Contraseña',
                          style: commonTextStyle,
                        ),
                      ),
                      const SizedBox(height: 10,),
                      MyTextField(
                        controller: passwordController,
                        hintText: '********',
                        obscureText: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 50,),
                  GestureDetector(
                    onTap: () async {
                      if(_KeyForm.currentState!.validate()) {
                        _signIn();
                      }
                    },
                    child: Container(
                      width: 170,
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 17),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Color(0xFFD287F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(71),
                        ),
                      ),
                      child: Center(
                        child:
                          Text(
                            'Iniciar Sesión',
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
                    )
                  ),
                  const SizedBox(height: 25,),
                  //O continuar con
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey[400],
                            )
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                              'O continua con',
                              style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey[400],
                            )
                        ),
                      ],
                    ),
                  ),
                  //Nuevo usuario? Hazte una cuenta en 2 minutos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Nuevo Usuario?'),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) =>  Registro_ampl(supabase: widget.supabase)));},
                        child: const Text(
                          'Hazte una cuenta en 2 minutos!',
                          style: TextStyle(
                            color: Color(0xFFD287F6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


