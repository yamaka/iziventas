class AppConstants {
  // Información de la aplicación
  static const String appName = 'IziVentas';
  static const String appVersion = '1.0.0';

  // Configuraciones de red
  static const int connectTimeout = 10000; // 10 segundos
  static const int receiveTimeout = 10000; // 10 segundos

  // Configuraciones de paginación
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Claves de almacenamiento
  static const String tokenStorageKey = 'auth_token';
  static const String userStorageKey = 'user_data';

  // Formatos
  static const String dateFormat = 'dd/MM/yyyy';
  static const String currencyFormat = '#,##0.00';

  // Validaciones
  static const int minPasswordLength = 6;
  static const int maxProductNameLength = 100;
  static const int maxDescriptionLength = 500;

  // Otros
  static const double defaultElevation = 4.0;
  static const double defaultBorderRadius = 8.0;
}