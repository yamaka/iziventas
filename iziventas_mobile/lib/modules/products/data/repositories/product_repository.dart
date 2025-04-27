import '../../../../core/error/failures.dart';
import '../datasources/local_product_datasource.dart';
import '../datasources/remote_product_datasource.dart';
import '../models/product_model.dart';

class ProductRepository {
  final RemoteProductDataSource _remoteDataSource;
  final LocalProductDataSource _localDataSource;

  ProductRepository({
    required RemoteProductDataSource remoteDataSource,
    required LocalProductDataSource localDataSource,
  }) : 
    _remoteDataSource = remoteDataSource,
    _localDataSource = localDataSource;

  // Obtener todos los productos
  Future<List<ProductModel>> getAllProducts({
    int page = 1,
    int limit = 10,
    String? search,
    bool forceRefresh = false,
  }) async {
    try {
      // Si no se requiere forzar refresco, intentar obtener de local
      if (!forceRefresh) {
        final localProducts = _localDataSource.getProducts();
        if (localProducts.isNotEmpty) {
          return localProducts;
        }
      }

      // Obtener productos del backend
      final products = await _remoteDataSource.getAllProducts(
        page: page,
        limit: limit,
        search: search,
      );

      // Guardar en almacenamiento local
      await _localDataSource.saveProducts(products);

      return products;
    } catch (e) {
      // Manejar errores de red
      throw const NetworkFailure('No se pudieron obtener los productos');
    }
  }

  // Obtener producto por ID
  Future<ProductModel> getProductById(String id) async {
    try {
      // Primero buscar en local
      final localProduct = _localDataSource.getProductById(id);
      if (localProduct != null) {
        return localProduct;
      }

      // Obtener de backend si no está en local
      final product = await _remoteDataSource.getProductById(id);
      
      // Guardar en local
      await _localDataSource.saveProduct(product);

      return product;
    } catch (e) {
      throw const BusinessFailure('Producto no encontrado');
    }
  }

  // Crear nuevo producto
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      // Crear en backend
      final createdProduct = await _remoteDataSource.createProduct(product);
      
      // Guardar en local
      await _localDataSource.saveProduct(createdProduct);

      return createdProduct;
    } catch (e) {
      if (e is ValidationFailure) {
        rethrow;
      }
      throw const ValidationFailure(
        'Error al crear producto', 
        {'general': 'No se pudo crear el producto'}
      );
    }
  }

  // Actualizar producto
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      // Actualizar en backend
      final updatedProduct = await _remoteDataSource.updateProduct(product);

      // Actualizar en local
      await _localDataSource.saveProduct(updatedProduct);

      return updatedProduct;
    } catch (e) {
      throw const ValidationFailure(
        'Error al actualizar producto',
        {'general': 'No se pudo actualizar el producto'},
      );
    }
  }

  // Eliminar producto
  Future<void> deleteProduct(String productId) async {
    try {
      // Eliminar en backend
      await _remoteDataSource.deleteProduct(productId);
      
      // Eliminar de local
      await _localDataSource.deleteProduct(productId);
    } catch (e) {
      throw const BusinessFailure('No se pudo eliminar el producto');
    }
  }

  // Actualizar stock
  Future<ProductModel> updateStock(
    String productId, 
    int stockAmount
  ) async {
    try {
      // Actualizar stock en backend
      final updatedProduct = await _remoteDataSource.updateStock(
        productId, 
        stockAmount
      );
      
      // Actualizar stock en local
      await _localDataSource.updateProductStock(
        productId, 
        updatedProduct.stock
      );

      return updatedProduct;
    } catch (e) {
      if (e is BusinessFailure) {
        rethrow; // Propagar errores de negocio como stock insuficiente
      }
      throw const BusinessFailure('Error al actualizar stock');
    }
  }

  // Buscar productos
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final products = await _remoteDataSource.getAllProducts(
        search: query
      );

      // Actualizar local
      await _localDataSource.saveProducts(products);

      return products;
    } catch (e) {
      throw const NetworkFailure('No se pudieron buscar productos');
    }
  }
}