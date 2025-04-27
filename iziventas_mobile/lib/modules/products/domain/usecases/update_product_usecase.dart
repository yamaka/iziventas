import '../../data/repositories/product_repository.dart';
import '../../data/models/product_model.dart';
import '../../../../core/error/failures.dart';

class UpdateProductUseCase {
  final ProductRepository _repository;

  UpdateProductUseCase(this._repository);

  Future<ProductModel> call(ProductModel product) async {
    // Validaciones antes de actualizar
    _validateProduct(product);

    try {
      return await _repository.updateProduct(product);
    } catch (e) {
      if (e is ValidationFailure) {
        rethrow;
      }
      throw const ValidationFailure(
        'Error al actualizar producto', 
        {'general': 'No se pudo completar la actualización'}
      );
    }
  }

  // Validaciones internas (similar a CreateProductUseCase)
  void _validateProduct(ProductModel product) {
    final errors = <String, String>{};

    if (product.id == null) {
      errors['id'] = 'ID de producto es requerido para actualizar';
    }

    // Validaciones similares a crear producto
    if (product.name.isEmpty) {
      errors['name'] = 'El nombre del producto es requerido';
    }

    if (product.price <= 0) {
      errors['price'] = 'El precio debe ser mayor a cero';
    }

    if (product.stock < 0) {
      errors['stock'] = 'El stock no puede ser negativo';
    }

    if (errors.isNotEmpty) {
      throw ValidationFailure('Error de validación', errors);
    }
  }
}