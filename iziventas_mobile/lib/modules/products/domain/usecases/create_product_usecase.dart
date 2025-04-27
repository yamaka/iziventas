import '../../../../core/error/failures.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository _repository;

  CreateProductUseCase(this._repository);

  Future<ProductModel> call(ProductModel product) async {
    // Validaciones antes de crear
    _validateProduct(product);

    try {
      return await _repository.createProduct(product);
    } catch (e) {
      if (e is ValidationFailure) {
        rethrow;
      }
      throw const ValidationFailure(
        'Error al crear producto', 
        {'general': 'No se pudo completar la creación'}
      );
    }
  }

  // Validaciones internas
  void _validateProduct(ProductModel product) {
    final errors = <String, String>{};

    // Validar nombre
    if (product.name.isEmpty) {
      errors['name'] = 'El nombre del producto es requerido';
    } else if (product.name.length < 3) {
      errors['name'] = 'El nombre debe tener al menos 3 caracteres';
    }

    // Validar precio
    if (product.price <= 0) {
      errors['price'] = 'El precio debe ser mayor a cero';
    }

    // Validar stock
    if (product.stock < 0) {
      errors['stock'] = 'El stock no puede ser negativo';
    }

    // Validar SKU
    if (product.sku.isEmpty) {
      errors['sku'] = 'El SKU es requerido';
    }

    // Lanzar error si hay validaciones
    if (errors.isNotEmpty) {
      throw ValidationFailure('Error de validación', errors);
    }
  }
}

class GetProductsUseCase {
  final ProductRepository _repository;

  GetProductsUseCase(this._repository);

  Future<List<ProductModel>> call({
    int page = 1,
    int limit = 10,
    String? search,
    bool forceRefresh = false,
  }) async {
    try {
      return await _repository.getAllProducts(
        page: page,
        limit: limit,
        search: search,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      throw const NetworkFailure('No se pudieron obtener los productos');
    }
  }
}



class DeleteProductUseCase {
  final ProductRepository _repository;

  DeleteProductUseCase(this._repository);

  Future<void> call(String productId) async {
    try {
      // Validar ID
      if (productId.isEmpty) {
        throw const ValidationFailure(
          'Error de validación', 
          {'productId': 'ID de producto es requerido'}
        );
      }

      await _repository.deleteProduct(productId);
    } catch (e) {
      if (e is BusinessFailure) {
        rethrow;
      }
      throw const BusinessFailure('No se pudo eliminar el producto');
    }
  }
}

class UpdateProductStockUseCase {
  final ProductRepository _repository;

  UpdateProductStockUseCase(this._repository);

  Future<ProductModel> call(
    String productId, 
    int stockAmount
  ) async {
    try {
      // Validaciones
      if (productId.isEmpty) {
        throw const ValidationFailure(
          'Error de validación', 
          {'productId': 'ID de producto es requerido'}
        );
      }

      if (stockAmount < 0) {
        throw const ValidationFailure(
          'Error de validación', 
          {'stockAmount': 'La cantidad de stock no puede ser negativa'}
        );
      }

      return await _repository.updateStock(productId, stockAmount);
    } catch (e) {
      if (e is BusinessFailure || e is ValidationFailure) {
        rethrow;
      }
      throw const BusinessFailure('Error al actualizar stock');
    }
  }
}