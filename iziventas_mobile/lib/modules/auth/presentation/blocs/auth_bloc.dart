import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../data/models/user_model.dart';

// Estados de Autenticación
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Eventos de Autenticación
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  
  const LoginRequested({
    required this.username, 
    required this.password
  });

  @override
  List<Object?> get props => [username, password];
}

class LogoutRequested extends AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  
  const RegisterRequested({
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [username, email, password];
}

// Bloc de Autenticación
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RegisterUseCase _registerUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required RegisterUseCase registerUseCase,
  }) : 
    _loginUseCase = loginUseCase,
    _logoutUseCase = logoutUseCase,
    _registerUseCase = registerUseCase,
    super(AuthInitial()) {
    
    // Registrar manejadores de eventos
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterRequested>(_onRegisterRequested);
  }

  // Manejar inicio de aplicación
  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      // Lógica para verificar estado de autenticación
      // Por ejemplo, comprobar token almacenado
      final authModel = await _loginUseCase.getCurrentUser();
      
      if (authModel != null) {
        emit(AuthAuthenticated(authModel));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  // Manejar solicitud de inicio de sesión
  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      final authModel = await _loginUseCase(
        username: event.username, 
        password: event.password,
      );

      print('Usuario autenticado: ${authModel.user}'); // Depuración
      emit(AuthAuthenticated(authModel.user));
      print('Estado emitido: AuthAuthenticated');
    } catch (e) {
      print('Error de autenticación: $e'); // Depuración
      emit(AuthError(e.toString()));
    }
  }

  // Manejar solicitud de cierre de sesión
  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      await _logoutUseCase();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Manejar solicitud de registro
  void _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      final authModel = await _registerUseCase(
        username: event.username,
        email: event.email,
        password: event.password
      );
      
      emit(AuthAuthenticated(authModel.user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }
}