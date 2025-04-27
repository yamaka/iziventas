// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailySalesReportModel _$DailySalesReportModelFromJson(
        Map<String, dynamic> json) =>
    DailySalesReportModel(
      date: DateTime.parse(json['date'] as String),
      totalSales: (json['total_sales'] as num).toInt(),
      totalRevenue: (json['total_revenue'] as num).toDouble(),
    );

Map<String, dynamic> _$DailySalesReportModelToJson(
        DailySalesReportModel instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'total_sales': instance.totalSales,
      'total_revenue': instance.totalRevenue,
    };

ProductSalesReportModel _$ProductSalesReportModelFromJson(
        Map<String, dynamic> json) =>
    ProductSalesReportModel(
      productName: json['product_name'] as String,
      productSku: json['product_sku'] as String,
      totalQuantitySold: (json['total_quantity_sold'] as num).toInt(),
      totalRevenue: (json['total_revenue'] as num).toDouble(),
    );

Map<String, dynamic> _$ProductSalesReportModelToJson(
        ProductSalesReportModel instance) =>
    <String, dynamic>{
      'product_name': instance.productName,
      'product_sku': instance.productSku,
      'total_quantity_sold': instance.totalQuantitySold,
      'total_revenue': instance.totalRevenue,
    };
