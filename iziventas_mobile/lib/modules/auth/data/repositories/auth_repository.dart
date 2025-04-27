import '../../../../core/error/failures.dart';
import '../datasources/local_auth_datasource.dart';
import '../datasources/remote_auth_datasource.dart';
import '../models/user_model.dart';
import 'package:dio/dio.dart';

final Dio _apiClient = Dio();

class AuthRepository {
  final RemoteAuthDataSource _remoteDataSource;
  final LocalAuthDataSource _localDataSource;

  AuthRepository({
    required RemoteAuthDataSource remoteDataSource,
    required LocalAuthDataSource localDataSource,
  }) : 
    _remoteDataSource = remoteDataSource,
    _localDataSource = localDataSource;

  // Iniciar sesión
  Future<AuthModel> login({
    required String username, 
    required String password
  }) async {
    try {
      final authModel = await _remoteDataSource.login(
        username: username, 
        password: password
      );

      // Guardar usuario y token localmente
      await _localDataSource.saveUser(authModel.user);
      await _localDataSource.saveAuthToken(authModel.token);
      await _localDataSource.saveLastLoginInfo(authModel.user);

      return authModel;
    } catch (e) {
      // Manejar errores de autenticación
      if (e is AuthFailure) {
        rethrow;
      }
      throw AuthFailure.invalidCredentials();
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
      final authModel = await _remoteDataSource.register(
        username: username,
        email: email,
        password: password,
        role: role,
      );

      // Guardar usuario y token localmente
      await _localDataSource.saveUser(authModel.user);
      await _localDataSource.saveAuthToken(authModel.token);

      return authModel;
    } catch (e) {
      // Manejar errores de registro
      if (e is ValidationFailure) {
        rethrow;
      }
      throw const ValidationFailure('Error durante el registro', {});
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      // Cerrar sesión en el backend
      await _remoteDataSource.logout();

      // Limpiar datos locales
      await _localDataSource.clearAuthData();
   
    } catch (e) {
      // Forzar limpieza de datos locales
      await _localDataSource.clearAuthData();
    }
  }

  // Obtener usuario actual
  Future<UserModel?> getCurrentUser() async {
    // Primero intenta obtener usuario local
    UserModel? localUser = _localDataSource.getCurrentUser();
    
    if (localUser != null) {
      // Verificar si el token está expirado
      if (!_localDataSource.isTokenExpired()) {
        return localUser;
      }
    }

    try {
      // Intentar obtener perfil actualizado del backend
      final profileUser = await _remoteDataSource.getUserProfile();
      
      // Actualizar usuario local
      await _localDataSource.saveUser(profileUser);
      
      return profileUser;
    } catch (e) {
      // Si falla la obtención del perfil, devolver usuario local o null
      return localUser;
    }
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final token = await _localDataSource.getAuthToken();
    return token != null && !_localDataSource.isTokenExpired();
  }

  // Actualizar perfil de usuario
  Future<UserModel> updateProfile({
    String? username,
    String? email,
  }) async {
    try {
      // Actualizar en el backend
      final updatedUser = await _remoteDataSource.updateProfile(
        username: username,
        email: email,
      );

      // Actualizar localmente
      await _localDataSource.saveUser(updatedUser);

      return updatedUser;
    } catch (e) {
      // Manejar errores de actualización
      if (e is ValidationFailure) {
        rethrow;
      }
      throw const ValidationFailure('Error durante el registro', {});
    }
  }

  // Cambiar contraseña
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      // Manejar errores de cambio de contraseña
      if (e is ValidationFailure) {
        rethrow;
      }
      throw const ValidationFailure('Error durante el registro', {});
    }
  }

  // Recuperar información de último inicio de sesión
  Map<String, String?> getLastLoginInfo() {
    return _localDataSource.getLastLoginInfo();
  }

  // Método para refrescar token
  Future<String?> refreshToken() async {
      try {
        // Implementar lógica de refresco de token con el backend
        final currentToken = await _localDataSource.getAuthToken();
        
        if (currentToken == null) {
          return null;
        }
  
        // Llamada al backend para refrescar token usando la función global
        final response = await _remoteDataSource.refreshToken(currentToken);
        
        // Guardar nuevo token
        await _localDataSource.saveAuthToken(response['token']);
        
        return response['token'];
      } catch (e) {
        // Si falla el refresco, cerrar sesión
        await logout();
        return null;
      }
    }
}

// Clase de extensión para manejar estados de autenticación
extension AuthStatusExtension on AuthRepository {
  Future<AuthStatus> getAuthStatus() async {
    if (await isAuthenticated()) {
      final user = await getCurrentUser();
      return user != null 
        ? AuthStatus.authenticated 
        : AuthStatus.unauthenticated;
    }
    return AuthStatus.unauthenticated;
  }
}

// Enum para estados de autenticación
enum AuthStatus {
  authenticated,
  unauthenticated,
  unknown
}


Future<Map<String, dynamic>> refreshToken(String currentToken) async {
  try {
    final response = await _apiClient.post(
      '/auth/refresh-token',
      data: {
        'token': currentToken,
      },
    );
    return response.data;
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      throw const AuthFailure.unauthorized();
    }
    rethrow;
  }
}