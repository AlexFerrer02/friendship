import 'package:flutter/material.dart';
import 'package:friendship/Class/grupo-amigos.dart';
import '../Class/user.dart';
import '../Pages/GroupPage.dart';

class GroupsWidget extends StatelessWidget {
  final GrupoAmigos grupo;

  const GroupsWidget({Key? key, required this.grupo}) : super(key: key);

  List<Widget> _buildAvatars() {
    List<Widget> avatars = [];

    for (User participante in grupo.amigos) {
      String initials = participante.username.substring(0, 1).toUpperCase();
      print(initials);
      avatars.add(
        Row(
          children: [
            SizedBox(width: 5,),
            Center(
                child: CircleAvatar(
                  maxRadius: 15,
                  backgroundColor: Color(0xFF032A64),
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )),
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
          color: Color(0xFF5094F9),
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
                  child: Row(
                    children: _buildAvatars(),
                  ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
