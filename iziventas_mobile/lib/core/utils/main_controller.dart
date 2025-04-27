import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MainController {
  // Instancia singleton
  static final MainController _instance = MainController._internal();
  factory MainController() => _instance;
  MainController._internal();

  // Instancia de almacenamiento seguro
  final _secureStorage = const FlutterSecureStorage();

  // Modo de depuración
  bool get isDebugMode => kDebugMode;

  // Guardar dato en almacenamiento seguro
  Future<void> saveSecureData(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      debugPrint('Error guardando dato seguro: $e');
    }
  }

  // Leer dato de almacenamiento seguro
  Future<String?> readSecureData(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      debugPrint('Error leyendo dato seguro: $e');
      return null;
    }
  }

  // Eliminar dato de almacenamiento seguro
  Future<void> deleteSecureData(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      debugPrint('Error eliminando dato seguro: $e');
    }
  }

  // Limpiar todo el almacenamiento seguro
  Future<void> clearAllSecureData() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      debugPrint('Error limpiando almacenamiento: $e');
    }
  }

  // Manejar errores de manera centralizada
  void handleError(dynamic error, {StackTrace? stackTrace}) {
    // Implementar lógica de manejo de errores
    debugPrint('Error capturado: $error');
    if (stackTrace != null) {
      debugPrint('Stack Trace: $stackTrace');
    }
    
    // Aquí podrías agregar lógica adicional como:
    // - Logging
    // - Envío de errores a un servicio
    // - Mostrar notificaciones
  }

  // Método para imprimir logs de manera controlada
  void log(String message, {LogLevel level = LogLevel.info}) {
    if (isDebugMode) {
      switch (level) {
        case LogLevel.info:
          debugPrint('ℹ️ INFO: $message');
          break;
        case LogLevel.warning:
          debugPrint('⚠️ WARNING: $message');
          break;
        case LogLevel.error:
          debugPrint('❌ ERROR: $message');
          break;
        case LogLevel.debug:
          debugPrint('🐞 DEBUG: $message');
          break;
      }
    }
  }
}

// Enum para niveles de log
enum LogLevel {
  info,
  warning,
  error,
  debug
}