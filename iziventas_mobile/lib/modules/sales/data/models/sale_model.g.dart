// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleModel _$SaleModelFromJson(Map<String, dynamic> json) => SaleModel(
      id: json['id'] as String?,
      totalAmount: SaleModel._stringToDouble(json['total_amount']),
      saleDate: DateTime.parse(json['sale_date'] as String),
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => SaleItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SaleModelToJson(SaleModel instance) => <String, dynamic>{
      'id': instance.id,
      'total_amount': instance.totalAmount,
      'sale_date': instance.saleDate.toIso8601String(),
      'status': instance.status,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

SaleItemModel _$SaleItemModelFromJson(Map<String, dynamic> json) =>
    SaleItemModel(
      productId: json['product_id'] as String,
      product: json['product'] == null
          ? null
          : ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
    );

Map<String, dynamic> _$SaleItemModelToJson(SaleItemModel instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'product': instance.product?.toJson(),
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
    };
