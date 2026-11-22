import 'package:flutter/material.dart';

class ColorsTheme {
  const ColorsTheme._();

  static const Color primaryColor = Colors.lightBlue;

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Colors.lightBlueAccent,
      Colors.white10,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get theme => ThemeData(
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: primaryColor,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: primaryColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
    ),
  );
}