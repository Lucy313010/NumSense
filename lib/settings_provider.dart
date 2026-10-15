import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDyslexiaFontEnabled = false;
  String _selectedFont = 'OpenDyslexic';

  bool get isDyslexiaFontEnabled => _isDyslexiaFontEnabled;
  String get selectedFont => _selectedFont;

  final List<String> availableFonts = ['OpenDyslexic', 'Lexend', 'ComicNeue'];

  void toggleDyslexiaFont(bool value) {
    _isDyslexiaFontEnabled = value;
    notifyListeners();
  }

  void setSelectedFont(String font) {
    _selectedFont = font;
    notifyListeners();
  }
}