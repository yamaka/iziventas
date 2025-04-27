// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleItemModel _$SaleItemModelFromJson(Map<String, dynamic> json) =>
    SaleItemModel(
      id: json['id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: SaleItemModel._stringToDouble(json['unit_price']),
      productId: json['product_id'] as String,
      product: ProductModel.fromJson(json['Product'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SaleItemModelToJson(SaleItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'product_id': instance.productId,
      'Product': instance.product.toJson(),
    };
