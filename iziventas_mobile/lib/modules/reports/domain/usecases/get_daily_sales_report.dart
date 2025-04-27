import '../../../../core/error/failures.dart';
import '../../data/models/report_model.dart';
import '../../data/repositories/report_repository.dart';

class GetDailySalesReportUseCase {
  final ReportRepository _repository;

  GetDailySalesReportUseCase(this._repository);

  Future<List<DailySalesReportModel>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Validar rango de fechas
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      throw ValidationFailure(
        'Error de validación', 
        {'dates': 'La fecha de inicio debe ser anterior a la fecha de fin'}
      );
    }

    try {
      return await _repository.getDailySalesReport(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw NetworkFailure('No se pudo obtener el reporte de ventas diarias');
    }
  }
}

class GetProductSalesReportUseCase {
  final ReportRepository _repository;

  GetProductSalesReportUseCase(this._repository);

  Future<List<ProductSalesReportModel>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Validar rango de fechas
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      throw ValidationFailure(
        'Error de validación', 
        {'dates': 'La fecha de inicio debe ser anterior a la fecha de fin'}
      );
    }

    try {
      return await _repository.getProductSalesReport(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw NetworkFailure('No se pudo obtener el reporte de ventas por producto');
    }
  }
}