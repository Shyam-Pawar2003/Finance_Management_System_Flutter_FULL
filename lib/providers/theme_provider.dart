import 'package:flutter/material.dart';

/// Provider for controlling light/dark mode throughout the app.
class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeData get themeData {
    final brightness = _isDark ? Brightness.dark : Brightness.light;
    const appFontFamily = 'Arial';
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.green,
        brightness: brightness,
      ),
      fontFamily: appFontFamily,
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
            fontFamily: appFontFamily,
          ),
      primaryTextTheme: ThemeData(
        brightness: brightness,
      ).primaryTextTheme.apply(fontFamily: appFontFamily),
    );
  }

  void toggleDark() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
