import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightCardBackground = Colors.white;
  static const Color lightCardTitle = Colors.black;
  static const Color lightCardContent = Colors.black54;
  static const Color lightCardDate = Colors.grey;
  static const Color lightAppBarBackground = Color(0xFF3498DB);
  static const Color lightAppBarText = Colors.white;

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkCardBackground = Color(0xFF1E293B);
  static const Color darkCardTitle = Colors.white;
  static const Color darkCardContent = Color(0xFF94A3B8);
  static const Color darkCardDate = Color(0xFF94A3B8);
  static const Color darkAppBarBackground = Color(0xFF3498DB);
  static const Color darkAppBarText = Colors.white;

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3498DB),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightAppBarBackground,
      foregroundColor: lightAppBarText,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: lightCardBackground,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    textTheme: const TextTheme(
      titleMedium: TextStyle(
        color: lightCardTitle,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(
        color: lightCardContent,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: lightCardDate,
        fontSize: 12,
      ),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3498DB),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkAppBarBackground,
      foregroundColor: darkAppBarText,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: darkCardBackground,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    textTheme: const TextTheme(
      titleMedium: TextStyle(
        color: darkCardTitle,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(
        color: darkCardContent,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: darkCardDate,
        fontSize: 12,
      ),
    ),
  );
}
