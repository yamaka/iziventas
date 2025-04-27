import '../../../../core/error/failures.dart';
import '../../../sales/data/datasources/remote_sale_datasource.dart';
import '../models/report_model.dart';

class ReportRepository {
  final RemoteSaleDataSource _remoteSaleDataSource;

  ReportRepository(this._remoteSaleDataSource);

  // Obtener reporte de ventas diarias
  Future<List<DailySalesReportModel>> getDailySalesReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final reportData = await _remoteSaleDataSource.getSalesReport(
        startDate: startDate,
        endDate: endDate,
        groupBy: 'day',
      );

      return reportData.map<DailySalesReportModel>((item) => 
        DailySalesReportModel.fromJson(item)
      ).toList();
    } catch (e) {
      throw NetworkFailure('No se pudo obtener el reporte de ventas diarias');
    }
  }

  // Obtener reporte de ventas por producto
  Future<List<ProductSalesReportModel>> getProductSalesReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final reportData = await _remoteSaleDataSource.getSalesReport(
        startDate: startDate,
        endDate: endDate,
        groupBy: 'product',
      );

      return reportData.map<ProductSalesReportModel>((item) => 
        ProductSalesReportModel.fromJson(item)
      ).toList();
    } catch (e) {
      throw NetworkFailure('No se pudo obtener el reporte de ventas por producto');
    }
  }
}