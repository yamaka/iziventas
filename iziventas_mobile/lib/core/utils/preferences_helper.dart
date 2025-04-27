import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  // Instancia singleton
  static final PreferencesHelper _instance = PreferencesHelper._internal();
  factory PreferencesHelper() => _instance;
  PreferencesHelper._internal();

  late SharedPreferences _prefs;

  // Inicializar SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Métodos para guardar diferentes tipos de datos
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  // Métodos para leer diferentes tipos de datos
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  // Eliminar una clave específica
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  // Limpiar todas las preferencias
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  // Verificar si existe una clave
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // Claves predefinidas
  static const String darkModeKey = 'dark_mode';
  static const String languageKey = 'app_language';
  static const String firstLaunchKey = 'first_launch';

  // Métodos de conveniencia
  bool isDarkMode() {
    return getBool(darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    await setBool(darkModeKey, value);
  }

  String? getSelectedLanguage() {
    return getString(languageKey);
  }

  Future<void> setSelectedLanguage(String languageCode) async {
    await setString(languageKey, languageCode);
  }

  bool isFirstLaunch() {
    return getBool(firstLaunchKey) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    await setBool(firstLaunchKey, false);
  }
}