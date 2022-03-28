import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  bool isDarkMode = false;

  get themeMode => _themeMode;

  get getDarkMode => isDarkMode;

  toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    isDarkMode = isDark;
    notifyListeners();
  }
}
