import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sale_model.dart';

class LocalSaleDataSource {
  final SharedPreferences _sharedPreferences;

  LocalSaleDataSource(this._sharedPreferences);

  // Clave para almacenar ventas
  static const _salesKey = 'local_sales';

  // Guardar lista de ventas
  Future<void> saveSales(List<SaleModel> sales) async {
    try {
      // Guardar ventas en almacenamiento local
      final salesJsonList = sales.map((sale) => json.encode(sale.toJson())).toList();
      await _sharedPreferences.setStringList(_salesKey, salesJsonList);
    } catch (e) {
      print('Error al guardar ventas en local: $e'); // Depuración
      throw Exception('Error al guardar ventas en local');
    }
  }

  // Obtener lista de ventas guardadas localmente
  List<SaleModel> getSales() {
    final salesJsonList = _sharedPreferences
      .getStringList(_salesKey) ?? [];
    
    return salesJsonList
      .map((saleJson) => 
        SaleModel.fromJson(
          json.decode(saleJson)
        )
      )
      .toList();
  }

  // Guardar una venta individual
  Future<void> saveSale(SaleModel sale) async {
    final sales = getSales();
    
    // Buscar si la venta ya existe
    final index = sales.indexWhere((s) => s.id == sale.id);
    
    if (index != -1) {
      // Actualizar venta existente
      sales[index] = sale;
    } else {
      // Añadir nueva venta
      sales.add(sale);
    }
    
    await saveSales(sales);
  }

  // Eliminar una venta
  Future<void> deleteSale(String saleId) async {
    final sales = getSales();
    
    sales.removeWhere((sale) => sale.id == saleId);
    
    await saveSales(sales);
  }

  // Buscar venta por ID
  SaleModel? getSaleById(String saleId) {
    final sales = getSales();
    
    try {
      return sales.firstWhere((sale) => sale.id == saleId);
    } catch (e) {
      return null;
    }
  }

  // Limpiar todas las ventas locales
  Future<void> clearSales() async {
    await _sharedPreferences.remove(_salesKey);
  }

  // Obtener ventas por rango de fechas
  List<SaleModel> getSalesByDateRange(
    DateTime startDate, 
    DateTime endDate
  ) {
    final sales = getSales();
    
    return sales.where((sale) {
      return sale.saleDate.isAfter(startDate) && 
             sale.saleDate.isBefore(endDate);
    }).toList();
  }
}