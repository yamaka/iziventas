import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class RemoteAuthDataSource {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  RemoteAuthDataSource({
    required ApiClient apiClient,
    required FlutterSecureStorage secureStorage,
  }) : _apiClient = apiClient,
       _secureStorage = secureStorage;

  // Iniciar sesión
  Future<AuthModel> login({
    required String username, 
    required String password
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      // Procesar respuesta del backend
      print('Respuesta del backend: ${response.data}');
      return AuthModel.fromJson(response.data);
    } else {
      throw Exception('Error al iniciar sesión');
    }
  }

  // Registrar usuario
  Future<AuthModel> register({
    required String username,
    required String email,
    required String password,
    String role = 'seller',
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      final authModel = AuthModel.fromJson(response.data);

      // Guardar token de forma segura
      await _secureStorage.write(
        key: 'auth_token', 
        value: authModel.token
      );

      return authModel;
    } on DioException catch (e) {
      // Manejar errores de registro
      if (e.response?.statusCode == 400) {
        throw ValidationFailure(
          'Error de registro', 
          e.response?.data ?? {}
        );
      }
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      // Llamada al backend para invalidar token
      await _apiClient.post('/auth/logout');

      // Limpiar token de almacenamiento seguro
      await _secureStorage.delete(key: 'auth_token');
    } catch (e) {
      // Manejar errores de cierre de sesión
      // Podría ser útil en caso de que falle la llamada al backend
      await _secureStorage.deleteAll();
    }
  }

  // Recuperar perfil de usuario
  Future<UserModel> getUserProfile() async {
    try {
      final response = await _apiClient.get('/auth/profile');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthFailure.unauthorized();
      }
      rethrow;
    }
  }

  // Actualizar perfil de usuario
  Future<UserModel> updateProfile({
    String? username,
    String? email,
  }) async {
    try {
      final response = await _apiClient.put(
        '/auth/profile',
        data: {
          if (username != null) 'username': username,
          if (email != null) 'email': email,
        },
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      // Manejar errores de actualización
      if (e.response?.statusCode == 400) {
        throw ValidationFailure(
          'Error de actualización', 
          e.response?.data ?? {}
        );
      }
      rethrow;
    }
  }

  // Cambiar contraseña
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ValidationFailure(
          'Error al cambiar contraseña', 
          e.response?.data ?? {}
        );
      }
      rethrow;
    }
  }

  refreshToken(String currentToken) {

    // Implementar lógica de refresco de token con el backend
    // Este es un ejemplo básico y puede variar según la API
    return _apiClient.post(
      '/auth/refresh-token',
      data: {
        'token': currentToken,
      },
    ).then((response) async {
      final newToken = response.data['token'];
      await _secureStorage.write(key: 'auth_token', value: newToken);
      return newToken;
    });
  }
}