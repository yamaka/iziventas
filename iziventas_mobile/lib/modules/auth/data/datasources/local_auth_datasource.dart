import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class LocalAuthDataSource {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;

  LocalAuthDataSource({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences sharedPreferences,
  }) : 
    _secureStorage = secureStorage,
    _sharedPreferences = sharedPreferences;

  // Constantes de claves
  static const _userKey = 'current_user';
  static const _tokenKey = 'auth_token';
  static const _tokenExpirationKey = 'token_expiration';

  // Guardar usuario actual
  Future<void> saveUser(UserModel user) async {
    await _sharedPreferences.setString(
      _userKey, 
      json.encode(user.toJson())
    );
  }

  // Obtener usuario guardado
  UserModel? getCurrentUser() {
    final userJson = _sharedPreferences.getString(_userKey);
    if (userJson != null) {
      return UserModel.fromJson(
        json.decode(userJson)
      );
    }
    return null;
  }

  // Guardar token de autenticación
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    
    // Guardar fecha de expiración
    await _sharedPreferences.setString(
      _tokenExpirationKey, 
      DateTime.now().add(const Duration(hours: 1)).toIso8601String()
    );
  }

  // Obtener token de autenticación
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Verificar si el token está expirado
  bool isTokenExpired() {
    final expirationString = _sharedPreferences.getString(_tokenExpirationKey);
    if (expirationString == null) return true;

    final expirationDate = DateTime.parse(expirationString);
    return DateTime.now().isAfter(expirationDate);
  }

  // Eliminar datos de autenticación
  Future<void> clearAuthData() async {
    await _sharedPreferences.remove(_userKey);
    await _sharedPreferences.remove(_tokenExpirationKey);
    await _secureStorage.delete(key: _tokenKey);
  }

  // Guardar información de último inicio de sesión
  Future<void> saveLastLoginInfo(UserModel user) async {
    await _sharedPreferences.setString(
      'last_login_username', 
      user.username
    );
    await _sharedPreferences.setString(
      'last_login_email', 
      user.email
    );
    await _sharedPreferences.setString(
      'last_login_time', 
      DateTime.now().toIso8601String()
    );
  }

  // Obtener información de último inicio de sesión
  Map<String, String?> getLastLoginInfo() {
    return {
      'username': _sharedPreferences.getString('last_login_username'),
      'email': _sharedPreferences.getString('last_login_email'),
      'time': _sharedPreferences.getString('last_login_time'),
    };
  }
}