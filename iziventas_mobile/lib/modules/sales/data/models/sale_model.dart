import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../products/data/models/product_model.dart';
import 'sale_item_model.dart';

part 'sale_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SaleModel extends Equatable {
  final String? id; // Hacer que el campo id sea opcional

  @JsonKey(name: 'total_amount', fromJson: _stringToDouble)
  final double totalAmount;

  @JsonKey(name: 'sale_date')
  final DateTime saleDate;

  final String status;

  final List<SaleItemModel> items;

  const SaleModel({
    this.id, // Campo opcional
    required this.totalAmount,
    required this.saleDate,
    required this.status,
    required this.items,
  });

  static double _stringToDouble(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else if (value is double) {
      return value;
    }
    throw Exception('Formato inválido para el campo totalAmount');
  }

  factory SaleModel.fromJson(Map<String, dynamic> json) =>
      _$SaleModelFromJson(json);

  Map<String, dynamic> toJson() => _$SaleModelToJson(this);

  @override
  List<Object?> get props => [id, totalAmount, saleDate, status, items];
}

@JsonSerializable(explicitToJson: true)
class SaleItemModel extends Equatable {
  @JsonKey(name: 'product_id')
  final String productId;
  
  final ProductModel? product;
  
  final int quantity;
  
  @JsonKey(name: 'unit_price')
  final double unitPrice;

  const SaleItemModel({
    required this.productId,
    this.product,
    required this.quantity,
    required this.unitPrice,
  });

  // Calcular subtotal del ítem
  double get subtotal => quantity * unitPrice;

  // Métodos de serialización
  factory SaleItemModel.fromJson(Map<String, dynamic> json) => 
      _$SaleItemModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$SaleItemModelToJson(this);

  @override
  List<Object?> get props => [productId, product, quantity, unitPrice];
}