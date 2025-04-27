import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_model.dart';

class LocalProductDataSource {
  final SharedPreferences _sharedPreferences;

  LocalProductDataSource(this._sharedPreferences);

  // Clave para almacenar productos
  static const _productsKey = 'local_products';

  // Guardar lista de productos
  Future<void> saveProducts(List<ProductModel> products) async {
    final productJsonList = products
      .map((product) => json.encode(product.toJson()))
      .toList();
    
    await _sharedPreferences.setStringList(
      _productsKey, 
      productJsonList
    );
  }

  // Obtener lista de productos guardados localmente
  List<ProductModel> getProducts() {
    final productJsonList = _sharedPreferences
      .getStringList(_productsKey) ?? [];
    
    return productJsonList
      .map((productJson) => 
        ProductModel.fromJson(
          json.decode(productJson)
        )
      )
      .toList();
  }

  // Guardar un producto individual
  Future<void> saveProduct(ProductModel product) async {
    final products = getProducts();
    
    // Buscar si el producto ya existe
    final index = products.indexWhere((p) => p.id == product.id);
    
    if (index != -1) {
      // Actualizar producto existente
      products[index] = product;
    } else {
      // Añadir nuevo producto
      products.add(product);
    }
    
    await saveProducts(products);
  }

  // Eliminar un producto
  Future<void> deleteProduct(String productId) async {
    final products = getProducts();
    
    products.removeWhere((product) => product.id == productId);
    
    await saveProducts(products);
  }

  // Buscar producto por ID
  ProductModel? getProductById(String productId) {
    final products = getProducts();
    
    try {
      return products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Actualizar stock de un producto
  Future<void> updateProductStock(
    String productId, 
    int stockAmount
  ) async {
    final products = getProducts();
    
    final index = products.indexWhere((p) => p.id == productId);
    
    if (index != -1) {
      final product = products[index];
      
      // Crear producto actualizado con nuevo stock
      final updatedProduct = product.copyWith(
        stock: stockAmount
      );
      
      products[index] = updatedProduct;
      
      await saveProducts(products);
    }
  }

  // Limpiar todos los productos locales
  Future<void> clearProducts() async {
    await _sharedPreferences.remove(_productsKey);
  }
}