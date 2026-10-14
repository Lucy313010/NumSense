import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDyslexiaFontEnabled = true;

  bool get isDyslexiaFontEnabled => _isDyslexiaFontEnabled;

  void toggleDyslexiaFont(bool value) {
    _isDyslexiaFontEnabled = value;
    notifyListeners();
  }
}