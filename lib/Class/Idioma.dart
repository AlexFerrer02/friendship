import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  Locale _selectedLocale = const Locale('en'); // Inglés como idioma predeterminado

  Locale get selectedLocale => _selectedLocale;

  void updateLocale(Locale newLocale) {
    _selectedLocale = newLocale;
    notifyListeners(); // Notificar a los widgets que el idioma ha cambiado
  }
}