import '../../../../core/network/api_client.dart';
import '../../../../core/error/failures.dart';
import '../models/sale_model.dart';

class RemoteSaleDataSource {
  final ApiClient _apiClient;

  RemoteSaleDataSource(this._apiClient);

  // Crear nueva venta
  Future<SaleModel> createSale(SaleModel sale) async {
    try {
      final response = await _apiClient.post(
        '/sales', 
        data: sale.toJson()
      );
      return SaleModel.fromJson(response.data);
    } catch (e) {
      throw const BusinessFailure('No se pudo crear la venta');
    }
  }
  

  // Obtener ventas
  Future<List<SaleModel>> getSales({
    int page = 1,
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _apiClient.get(
        '/sales',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        },
      );

      final salesJson = response.data['sales'] as List;

      return salesJson
          .map((saleJson) => SaleModel.fromJson(saleJson))
          .toList();
    } catch (e) {
      print('Error en RemoteSaleDataSource: $e'); // Depuración
      throw Exception('Error al obtener ventas: $e');
    }
  }

  // Obtener venta por ID
  Future<SaleModel> getSaleById(String id) async {
    try {
      final response = await _apiClient.get('/sales/$id');
      return SaleModel.fromJson(response.data);
    } catch (e) {
      throw const BusinessFailure('Venta no encontrada');
    }
  }

  // Cancelar venta
  Future<SaleModel> cancelSale(String id) async {
    try {
      final response = await _apiClient.patch(
        '/sales/$id/cancel'
      );
      return SaleModel.fromJson(response.data);
    } catch (e) {
      throw const BusinessFailure('No se pudo cancelar la venta');
    }
  }

  // Obtener reporte de ventas
  Future<List<dynamic>> getSalesReport({
   DateTime? startDate,
  DateTime? endDate,
  String groupBy = 'day',
  }) async {
    try {
      final response = await _apiClient.get(
        '/reports/sales',
        queryParameters: {
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
          'groupBy': groupBy,
        }
      );

      return response.data['report'] ?? [];
    } catch (e) {
      throw const NetworkFailure('No se pudo obtener el reporte de ventas');
    }
  }
}