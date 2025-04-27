// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: ProductModel._stringToDouble(json['price']),
      stock: (json['stock'] as num).toInt(),
      sku: json['sku'] as String,
      status: json['status'] as String? ?? 'active',
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'stock': instance.stock,
      'sku': instance.sku,
      'status': instance.status,
    };
