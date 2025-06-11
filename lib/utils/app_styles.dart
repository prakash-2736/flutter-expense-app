import 'package:flutter/material.dart';

const Color primaryColor = Color.fromARGB(255, 90, 113, 247); // Deep Indigo
const Color secondaryColor = Color.fromARGB(255, 140, 99, 254); // Soft Purple Accent
const Color backgroundColor = Color(0xFFF6F7FB); // Soft Off-White
const Color cardColor = Colors.white;
const Color errorColor = Color(0xFFB00020);

final ColorScheme kColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: primaryColor,
  onPrimary: Colors.white,
  secondary: secondaryColor,
  onSecondary: Colors.white,
  surface: cardColor,
  onSurface: Colors.black87,

  error: errorColor,
  onError: Colors.white,
);

class AppStyles {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: kColorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
      elevation: 3,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(255, 149, 112, 253),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color.fromARGB(255, 209, 214, 247),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color.fromARGB(255, 169, 181, 248), width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      labelStyle: const TextStyle(color: Colors.black87),
      hintStyle: TextStyle(color: Colors.grey.shade500),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        elevation: 2,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color.fromARGB(255, 178, 151, 251),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: errorColor,
      contentTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: primaryColor,
      textColor: Colors.black87,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color.fromARGB(255, 113, 134, 254),
      circularTrackColor: Color.fromARGB(255, 171, 140, 254),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade300,
      thickness: 1,
      space: 1,
    ),
    fontFamily: 'Roboto',
  );
}
