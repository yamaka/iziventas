import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class Formatters {
  // Formateador de moneda
  static String formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'es_ES', 
      symbol: '\$', 
      decimalDigits: 2
    );
    return formatter.format(value);
  }

  // Formateador de fecha corta
  static String formatShortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Formateador de fecha larga
  static String formatLongDate(DateTime date) {
    return DateFormat('EEEE, dd \'de\' MMMM \'de\' yyyy', 'es_ES').format(date);
  }

  // Formateador de fecha y hora
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  // Formatear número con 2 decimales
  static String formatDecimal(double value) {
    return NumberFormat('#,##0.00', 'es_ES').format(value);
  }

  // InputFormatter para solo números
  static TextInputFormatter get numbersOnly {
    return FilteringTextInputFormatter.digitsOnly;
  }

  // InputFormatter para números decimales
  static TextInputFormatter get decimalInput {
    return TextInputFormatter.withFunction(
      (TextEditingValue oldValue, TextEditingValue newValue) {
        if (newValue.text.isEmpty) {
          return newValue;
        }
        if (newValue.text.contains(',')) {
          return oldValue;
        }
        final value = double.tryParse(newValue.text);
        if (value == null) {
          return oldValue;
        }
        return newValue;
      },
    );
  }

  // Truncar texto largo
  static String truncateText(String text, {int maxLength = 50}) {
    return text.length > maxLength 
      ? '${text.substring(0, maxLength)}...' 
      : text;
  }

  // Capitalizar primera letra
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Formatear teléfono
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length < 10) return phoneNumber;
    return '(${phoneNumber.substring(0, 3)}) ${phoneNumber.substring(3, 6)}-${phoneNumber.substring(6)}';
  }

  // Convertir primera letra de cada palabra a mayúscula
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.replaceAllMapped(
      RegExp(r'\w\S*'), 
      (match) => match.group(0)!.capitalizeFirstLetter()
    );
  }
}

// Extensión para capitalizar primera letra
extension StringExtension on String {
  String capitalizeFirstLetter() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}