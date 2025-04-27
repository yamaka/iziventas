import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// Errores de red
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);

  const factory NetworkFailure.connectionError() = _NetworkConnectionFailure;
  const factory NetworkFailure.serverError() = _NetworkServerFailure;
  const factory NetworkFailure.timeout() = _NetworkTimeoutFailure;
}

class _NetworkConnectionFailure extends NetworkFailure {
  const _NetworkConnectionFailure() : super('Sin conexión a internet');
}

class _NetworkServerFailure extends NetworkFailure {
  const _NetworkServerFailure() : super('Error en el servidor');
}

class _NetworkTimeoutFailure extends NetworkFailure {
  const _NetworkTimeoutFailure() : super('Tiempo de conexión agotado');
}

// Errores de autenticación
class AuthFailure extends Failure {
  const AuthFailure(super.message);

  const factory AuthFailure.invalidCredentials() = _InvalidCredentialsFailure;
  const factory AuthFailure.unauthorized() = _UnauthorizedFailure;
  const factory AuthFailure.tokenExpired() = _TokenExpiredFailure;
}

class _InvalidCredentialsFailure extends AuthFailure {
  const _InvalidCredentialsFailure() : super('Credenciales inválidas');
}

class _UnauthorizedFailure extends AuthFailure {
  const _UnauthorizedFailure() : super('No autorizado');
}

class _TokenExpiredFailure extends AuthFailure {
  const _TokenExpiredFailure() : super('Sesión expirada');
}

// Errores de validación
class ValidationFailure extends Failure {
  final Map<String, String> errors;
  const ValidationFailure(super.message, this.errors);

  @override
  List<Object?> get props => [message, errors];
}

// Errores de negocio
class BusinessFailure extends Failure {
  const BusinessFailure(super.message);

  const factory BusinessFailure.insufficientStock() = _InsufficientStockFailure;
  const factory BusinessFailure.productNotFound() = _ProductNotFoundFailure;
}

class _InsufficientStockFailure extends BusinessFailure {
  const _InsufficientStockFailure() : super('Stock insuficiente');
}

class _ProductNotFoundFailure extends BusinessFailure {
  const _ProductNotFoundFailure() : super('Producto no encontrado');
}