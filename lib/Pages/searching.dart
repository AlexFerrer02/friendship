import 'package:flutter/material.dart';
import 'package:friendship/Pages/recomendacion.dart';
import 'package:friendship/Pages/searchresult.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _searchController = TextEditingController();
  String busqueda ="";

  Widget resultado = const Center(child: RecomendacionPage(),);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF530577)), // Color y ancho del borde
              borderRadius: BorderRadius.circular(50), // Radio de borde
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: onSearchSubmitted,
                      decoration: const InputDecoration(
                        border: InputBorder.none, // Sin borde para el TextField
                        labelText: 'Buscar plan',
                        hintText: 'Nombre del plan',
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(
                    Icons.search,
                    color: Color(0xFF530577),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: resultado,
        ),
      ],
    );
  }


  void onSearchSubmitted(String text) {
    if (text.isNotEmpty) {
    setState(() {
      busqueda= text;
      resultado = Center(child:SearchResultsPage(searchTerm: busqueda));
    });
    }
    else{
      setState(() {
        busqueda ="";
        resultado = const Center(child: RecomendacionPage(),);
      });
    }
  }
}

