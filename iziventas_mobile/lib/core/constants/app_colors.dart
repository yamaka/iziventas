import 'package:flutter/material.dart';

class AppColors {
  // Colores personalizados
  static const Color buttonColor = Color(0xFF1F1E3E);
  static const Color titleColor = Color(0xFF5754E3);
  static const Color backgroundColor = Color(0xFFFFFFFF);

  // Colores de texto
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textColor = Color(0xFF333333);

  // Colores de estado
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFC0392B);
  static const Color info = Color(0xFF3498DB);

  // Paleta de colores completa
  static final MaterialColor primarySwatch = MaterialColor(
    buttonColor.value,
    <int, Color>{
      50: buttonColor.withOpacity(0.1),
      100: buttonColor.withOpacity(0.2),
      200: buttonColor.withOpacity(0.3),
      300: buttonColor.withOpacity(0.4),
      400: buttonColor.withOpacity(0.5),
      500: buttonColor,
      600: buttonColor.withOpacity(0.7),
      700: buttonColor.withOpacity(0.8),
      800: buttonColor.withOpacity(0.9),
      900: buttonColor,
    },
  );

  // Tema de la aplicación
  static ThemeData get theme {
    return ThemeData(
      primarySwatch: primarySwatch,
      primaryColor: buttonColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        color: buttonColor,
        titleTextStyle: TextStyle(
          color: backgroundColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: backgroundColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: titleColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: titleColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}