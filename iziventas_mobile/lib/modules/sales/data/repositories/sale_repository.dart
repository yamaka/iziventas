import '../../../../core/error/failures.dart';
import '../datasources/local_sale_datasource.dart';
import '../datasources/remote_sale_datasource.dart';
import '../models/sale_model.dart';

class SaleRepository {
  final RemoteSaleDataSource _remoteDataSource;
  final LocalSaleDataSource _localDataSource;

  SaleRepository({
    required RemoteSaleDataSource remoteDataSource,
    required LocalSaleDataSource localDataSource,
  }) : 
    _remoteDataSource = remoteDataSource,
    _localDataSource = localDataSource;

  // Crear nueva venta
  Future<SaleModel> createSale(SaleModel sale) async {
    try {
      // Validar stock antes de crear
      _validateSaleStock(sale);

      // Crear venta en backend
      final createdSale = await _remoteDataSource.createSale(sale);
      
      // Guardar en local
      await _localDataSource.saveSale(createdSale);

      return createdSale;
    } catch (e) {
      if (e is BusinessFailure) {
        rethrow;
      }
      throw BusinessFailure('No se pudo crear la venta');
    }
  }

  // Obtener ventas
  Future<List<SaleModel>> getSales({
    int page = 1,
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      // Si no se requiere forzar refresco, intentar obtener de local
      if (!forceRefresh) {
        final localSales = _localDataSource.getSales();
        if (localSales.isNotEmpty) {
          return localSales;
        }
      }

      // Obtener ventas del backend
      final sales = await _remoteDataSource.getSales(
        page: page,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );

      // Guardar en almacenamiento local
      await _localDataSource.saveSales(sales);

      return sales;
    } catch (e) {
      print('Error al obtener ventas: $e'); // Depuración
      throw NetworkFailure('No se pudieron obtener las ventas');
    }
  }

  // Obtener venta por ID
  Future<SaleModel> getSaleById(String id) async {
    try {
      // Primero buscar en local
      final localSale = _localDataSource.getSaleById(id);
      if (localSale != null) {
        return localSale;
      }

      // Obtener de backend si no está en local
      final sale = await _remoteDataSource.getSaleById(id);
      
      // Guardar en local
      await _localDataSource.saveSale(sale);

      return sale;
    } catch (e) {
      throw BusinessFailure('Venta no encontrada');
    }
  }

  // Cancelar venta
  Future<SaleModel> cancelSale(String id) async {
    try {
      // Cancelar en backend
      final canceledSale = await _remoteDataSource.cancelSale(id);
      
      // Actualizar en local
      await _localDataSource.saveSale(canceledSale);

      return canceledSale;
    } catch (e) {
      throw BusinessFailure('No se pudo cancelar la venta');
    }
  }

  // Obtener reporte de ventas
  Future<List<dynamic>> getSalesReport({
    DateTime? startDate,
    DateTime? endDate,
    String groupBy = 'day',
  }) async {
    try {
      return await _remoteDataSource.getSalesReport(
        startDate: startDate,
        endDate: endDate,
        groupBy: groupBy,
      );
    } catch (e) {
      throw NetworkFailure('No se pudo obtener el reporte de ventas');
    }
  }

  // Validación de stock
  void _validateSaleStock(SaleModel sale) {
    for (var item in sale.items) {
      if (item.product == null) {
        throw BusinessFailure('Producto no encontrado');
      }

      if (item.quantity > item.product!.stock) {
        throw BusinessFailure(
          'Stock insuficiente para el producto ${item.product!.name}'
        );
      }
    }
  }
}