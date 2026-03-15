import 'package:flutter/material.dart';

/// Provider for controlling light/dark mode throughout the app.
class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeData get themeData {
    final brightness = _isDark ? Brightness.dark : Brightness.light;
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.green,
        brightness: brightness,
      ),
    );
  }

  void toggleDark() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
