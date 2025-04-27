import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  final String? id;
  final String username;
  final String email;
  final String role;
  final String status;

  const UserModel({
    this.id,
    required this.username,
    required this.email,
    this.role = 'seller',
    this.status = 'active',
  });

  // Método de copia para crear una nueva instancia con cambios
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? role,
    String? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }

  // Métodos de serialización
  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  List<Object?> get props => [id, username, email, role, status];

  // Método para verificar permisos
  bool hasRole(String requiredRole) {
    final roleHierarchy = {
      'admin': 3,
      'manager': 2,
      'seller': 1
    };

    return (roleHierarchy[role] ?? 0) >= (roleHierarchy[requiredRole] ?? 0);
  }
}

// Modelo de autenticación
class AuthModel {
  final UserModel user;
  final String token;

  AuthModel({required this.user, required this.token});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      user: UserModel.fromJson(json['user']),
      token: json['token'],
    );
  }
}