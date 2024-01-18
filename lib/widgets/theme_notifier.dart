import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _currentThemeData;

  ThemeNotifier(this._currentThemeData);

  getTheme() => _currentThemeData;

  setTheme(ThemeData themeData) {
    _currentThemeData = themeData;
    notifyListeners();
  }
}
