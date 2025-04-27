import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../products/data/models/product_model.dart';

part 'sale_item_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SaleItemModel extends Equatable {
  final String id;

  final int quantity;

  @JsonKey(name: 'unit_price', fromJson: _stringToDouble)
  final double unitPrice;

  @JsonKey(name: 'product_id')
  final String productId;

  @JsonKey(name: 'Product')
  final ProductModel product;

  const SaleItemModel({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.productId,
    required this.product,
  });

  // Método para convertir String a double
  static double _stringToDouble(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else if (value is double) {
      return value;
    }
    throw Exception('Formato inválido para el campo unitPrice');
  }

  factory SaleItemModel.fromJson(Map<String, dynamic> json) =>
      _$SaleItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$SaleItemModelToJson(this);

  @override
  List<Object?> get props => [id, quantity, unitPrice, productId, product];
}