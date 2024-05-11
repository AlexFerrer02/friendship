import 'package:flutter/material.dart';
import 'package:friendship/Class/consultas.dart';
import 'package:friendship/Class/evento.dart';
import 'package:friendship/Class/filtro.dart';
import 'package:friendship/Widgets/listEventoBusqueda.dart';
import 'package:friendship/Class/type.dart';
class SearchResultsPage extends StatelessWidget {
  final String searchTerm;

  const SearchResultsPage({super.key, required this.searchTerm});

  // You can perform your search logic here based on the searchTerm

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Evento>>(
      future: Consultas().BuscarEventos(nombreEvento: searchTerm),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          TextEditingController _searchController = TextEditingController();
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Evento> eventos = snapshot.data ?? [];
          return Center(
            child: ListEventosBusqueda(eventos: eventos),
          );
        }
      },
    );
  }
}