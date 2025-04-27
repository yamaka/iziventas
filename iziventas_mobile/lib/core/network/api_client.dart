import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import '../error/failures.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  ApiClient() 
    : _dio = Dio(BaseOptions(
        baseUrl: 'http://localhost:3000/api', // URL base de tu API
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      )),
      _secureStorage = const FlutterSecureStorage() {
    
    // Añadir interceptores
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Añadir token de autenticación si existe
          final token = await _secureStorage.read(
            key: AppConstants.tokenStorageKey
          );
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Manejar errores de autorización
          if (e.response?.statusCode == 401) {
            // Limpiar token y redirigir a login
            await _secureStorage.delete(
              key: AppConstants.tokenStorageKey
            );
            // Posible implementación de navegación
          }
          
          return handler.next(e);
        },
      ),
    );

    // Añadir logging en modo desarrollo
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  // Método GET genérico
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Método POST genérico
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Método PUT genérico
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Método PATCH genérico
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Método DELETE genérico
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Manejo de errores
  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        throw const NetworkFailure.timeout();
      
      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case 400:
            throw ValidationFailure(
              'Error de validación', 
              error.response?.data ?? {}
            );
          case 401:
            throw const AuthFailure.unauthorized();
          case 403:
            throw const AuthFailure.tokenExpired();
          case 404:
            throw const BusinessFailure('Recurso no encontrado');
          case 500:
            throw const NetworkFailure.serverError();
          default:
            throw NetworkFailure('Error desconocido: ${error.message}');
        }
      
      case DioExceptionType.cancel:
        throw const NetworkFailure('Solicitud cancelada');
      
      case DioExceptionType.unknown:
        throw const NetworkFailure.connectionError();
      case DioExceptionType.badCertificate:
        // TODO: Handle this case.
        throw UnimplementedError();
      case DioExceptionType.connectionError:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}

