import '../../../../core/error/failures.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<AuthModel> call({
    required String username, 
    required String password
  }) async {
    // Validaciones básicas
    if (username.isEmpty) {
      throw const ValidationFailure(
        'Error de validación', 
        {'username': 'El nombre de usuario es requerido'}
      );
    }

    if (password.isEmpty) {
      throw const ValidationFailure(
        'Error de validación', 
        {'password': 'La contraseña es requerida'}
      );
    }

    // Validación de longitud mínima
    if (username.length < 3) {
      throw const ValidationFailure(
        'Error de validación', 
        {'username': 'El nombre de usuario debe tener al menos 3 caracteres'}
      );
    }

    if (password.length < 6) {
      throw const ValidationFailure(
        'Error de validación', 
        {'password': 'La contraseña debe tener al menos 6 caracteres'}
      );
    }

    // Intentar iniciar sesión
    try {
      return await _repository.login(
        username: username, 
        password: password
      );
    } catch (e) {
      // Manejar errores específicos
      if (e is AuthFailure) {
        rethrow;
      }
      throw AuthFailure.invalidCredentials();
    }
  }

  getCurrentUser() {
    return _repository.getCurrentUser();
  }
}

// Caso de uso para cierre de sesión
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<void> call() async {
    await _repository.logout();
  }
}

// Caso de uso para registro
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<AuthModel> call({
    required String username,
    required String email,
    required String password,
    String role = 'seller',
  }) async {
    // Validaciones de registro
    _validateRegistrationData(
      username: username, 
      email: email, 
      password: password
    );

    try {
      return await _repository.register(
        username: username,
        email: email,
        password: password,
        role: role,
      );
    } catch (e) {
      if (e is ValidationFailure) {
        rethrow;
      }
      throw const ValidationFailure(
        'Error de registro', 
        {'general': 'No se pudo completar el registro'}
      );
    }
  }

  // Validaciones internas
  void _validateRegistrationData({
    required String username,
    required String email,
    required String password,
  }) {
    final validations = <String, String>{};

    // Validar nombre de usuario
    if (username.isEmpty) {
      validations['username'] = 'El nombre de usuario es requerido';
    } else if (username.length < 3) {
      validations['username'] = 'El nombre de usuario debe tener al menos 3 caracteres';
    }

    // Validar email
    if (email.isEmpty) {
      validations['email'] = 'El correo electrónico es requerido';
    } else if (!_isValidEmail(email)) {
      validations['email'] = 'Ingrese un correo electrónico válido';
    }

    // Validar contraseña
    if (password.isEmpty) {
      validations['password'] = 'La contraseña es requerida';
    } else if (password.length < 6) {
      validations['password'] = 'La contraseña debe tener al menos 6 caracteres';
    } else if (!_isStrongPassword(password)) {
      validations['password'] = 'La contraseña debe contener mayúsculas, minúsculas y números';
    }

    // Lanzar error si hay validaciones
    if (validations.isNotEmpty) {
      throw ValidationFailure('Error de validación', validations);
    }
  }

  // Validador de email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validador de contraseña segura
  bool _isStrongPassword(String password) {
    return RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$')
        .hasMatch(password);
  }
}