import 'package:flutter/material.dart';
import 'package:friendship/Class/evento.dart';
import 'package:friendship/Class/grupo-amigos.dart';
import 'package:friendship/Widgets/eventoWidget.dart';
import 'package:friendship/Widgets/groupsWidget.dart';

class ListGroupsWidget extends StatelessWidget {
  final List<GrupoAmigos> groups;

  const ListGroupsWidget({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return GroupsWidget(grupo: groups[index]);
      },
    );
  }
}
