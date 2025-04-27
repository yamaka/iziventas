import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

import '../../../../core/error/failures.dart';

class RemoteProductDataSource {
  final ApiClient _apiClient;

  RemoteProductDataSource(this._apiClient);

  // Obtener todos los productos
  Future<List<ProductModel>> getAllProducts({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final response = await _apiClient.get('/products', 
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null) 'search': search,
        }
      );

      // Convertir respuesta a lista de productos
      final productList = (response.data['products'] as List)
        .map((productJson) => ProductModel.fromJson(productJson))
        .toList();

      return productList;
    } catch (e) {
      // Manejar errores de red o del servidor
      throw Exception('Error al obtener productos');
    }
  }

  // Obtener producto por ID
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _apiClient.get('/products/$id');
      return ProductModel.fromJson(response.data);
    } catch (e) {
      // Manejar producto no encontrado
      throw const BusinessFailure('Producto no encontrado');
    }
  }

  // Crear nuevo producto
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final response = await _apiClient.post(
        '/products', 
        data: product.toJson(excludeId: true)
      );
      return ProductModel.fromJson(response.data);
    } catch (e) {
      // Manejar errores de validación
      throw const ValidationFailure(
        'Error al crear producto', 
        {'general': 'No se pudo crear el producto'}
      );
    }
  }

  // Actualizar producto
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      // Verifica que el ID del producto no sea nulo
      if (product.id == null) {
        throw Exception('El ID del producto es requerido para actualizar');
      }

      // Realiza la solicitud PUT al endpoint correcto
      final response = await _apiClient.put(
        '/products/${product.id}', // Endpoint correcto
        data: product.toJson(excludeId: true), // Excluir el campo `id` del cuerpo
      );

      // Devuelve el producto actualizado
      return ProductModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al actualizar el producto: $e');
    }
  }

  // Eliminar producto
  Future<void> deleteProduct(String productId) async {
    try {
      await _apiClient.delete('/products/$productId');
    } catch (e) {
      throw const BusinessFailure('No se pudo eliminar el producto');
    }
  }

  // Actualizar stock de producto
  Future<ProductModel> updateStock(
    String productId, 
    int stockAmount
  ) async {
    try {
      final response = await _apiClient.patch(
        '/products/$productId/stock',
        data: {'amount': stockAmount}
      );
      return ProductModel.fromJson(response.data);
    } catch (e) {
      if (e is BusinessFailure) {
        rethrow; // Propagar error de stock insuficiente
      }
      throw const BusinessFailure('Error al actualizar stock');
    }
  }
}