import '../../../../core/error/failures.dart';
import '../../data/models/sale_model.dart';
import '../../data/repositories/sale_repository.dart';

class CreateSaleUseCase {
  final SaleRepository _repository;

  CreateSaleUseCase(this._repository);

  Future<SaleModel> call(SaleModel sale) async {
    // Validaciones antes de crear
    _validateSale(sale);

    try {
      return await _repository.createSale(sale);
    } catch (e) {
      if (e is BusinessFailure) {
        rethrow;
      }
      throw BusinessFailure('No se pudo completar la venta');
    }
  }

  // Validaciones internas
  void _validateSale(SaleModel sale) {
    final errors = <String, String>{};

    // Validar que haya ítems
    if (sale.items.isEmpty) {
      errors['items'] = 'La venta debe tener al menos un producto';
    }

    // Validar cantidades de productos
    for (var item in sale.items) {
      if (item.quantity <= 0) {
        errors['quantity'] = 'La cantidad de productos debe ser mayor a cero';
      }
    }

    // Validar total
    if (sale.totalAmount <= 0) {
      errors['totalAmount'] = 'El total de la venta debe ser mayor a cero';
    }

    // Lanzar error si hay validaciones
    if (errors.isNotEmpty) {
      throw ValidationFailure('Error de validación', errors);
    }
  }
}

class GetSalesUseCase {
  final SaleRepository _repository;

  GetSalesUseCase(this._repository);

  Future<List<SaleModel>> call({
    int page = 1,
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      return await _repository.getSales(
        page: page,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      throw NetworkFailure('No se pudieron obtener las ventas');
    }
  }
}

class CancelSaleUseCase {
  final SaleRepository _repository;

  CancelSaleUseCase(this._repository);

  Future<SaleModel> call(String saleId) async {
    try {
      // Validar ID
      if (saleId.isEmpty) {
        throw ValidationFailure(
          'Error de validación', 
          {'saleId': 'ID de venta es requerido'}
        );
      }

      return await _repository.cancelSale(saleId);
    } catch (e) {
      if (e is BusinessFailure) {
        rethrow;
      }
      throw BusinessFailure('No se pudo cancelar la venta');
    }
  }
}

class GetSalesReportUseCase {
  final SaleRepository _repository;

  GetSalesReportUseCase(this._repository);

  Future<List<dynamic>> call({
    DateTime? startDate,
    DateTime? endDate,
    String groupBy = 'day',
  }) async {
    try {
      // Validaciones
      if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
        throw ValidationFailure(
          'Error de validación', 
          {'dates': 'La fecha de inicio debe ser anterior a la fecha de fin'}
        );
      }

      return await _repository.getSalesReport(
        startDate: startDate,
        endDate: endDate,
        groupBy: groupBy,
      );
    } catch (e) {
      throw NetworkFailure('No se pudo obtener el reporte de ventas');
    }
  }
}