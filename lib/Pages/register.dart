import 'dart:async';
import 'package:friendship/Pages/login_page.dart';
import 'package:friendship/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:friendship/Pages/home.dart';
import 'package:friendship/components/my_textfield.dart';
import '../Class/usernameAuxiliar.dart';
import '../components/cuadrado.dart';
import '../components/phone_textfield.dart';

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

  Future<void> _signUp() async {
    try {
      await widget.supabase.auth.signUp(password: passwordController.text, email: usernameController.text);
      if (mounted) {
        await supabase.from('usuarios').upsert([
          {
            'telefono': int.parse(phoneController.text),
            'username': aliasController.text,
            'contraseña': passwordController.text,
            'email': usernameController.text,
            'gustos': widget.gustos
          },
        ]);
        UserData.emailActual=usernameController.text;
        UserData userData = UserData();
        await userData.construirUsuarioPorEmail(UserData.emailActual);
        usernameController.clear();
        passwordController.clear();

        _isredirecting = true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[310],
      appBar: AppBar(
        title: Text("Registro"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
                  const Icon(Icons.account_circle_outlined, size: 100 ),
                  const SizedBox(height: 10,),
                  //Registro de usuario
                  Text(
                    'REGISTRATE',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10,),
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
                  //sign up button
                  GestureDetector(
                    onTap: (){
                      if (_KeyForm.currentState!.validate()) {
                        _signUp();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      margin: const EdgeInsets.symmetric(horizontal: 40.0),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
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
                            'O registrate con',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
