import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_model.g.dart';

@JsonSerializable()
class DailySalesReportModel extends Equatable {
  @JsonKey(name: 'date')
  final DateTime date;

  @JsonKey(name: 'total_sales')
  final int totalSales;

  @JsonKey(name: 'total_revenue')
  final double totalRevenue;

  const DailySalesReportModel({
    required this.date,
    required this.totalSales,
    required this.totalRevenue,
  });

  // Métodos de serialización
  factory DailySalesReportModel.fromJson(Map<String, dynamic> json) => 
      _$DailySalesReportModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$DailySalesReportModelToJson(this);

  @override
  List<Object?> get props => [date, totalSales, totalRevenue];
}

@JsonSerializable()
class ProductSalesReportModel extends Equatable {
  @JsonKey(name: 'product_name')
  final String productName;

  @JsonKey(name: 'product_sku')
  final String productSku;

  @JsonKey(name: 'total_quantity_sold')
  final int totalQuantitySold;

  @JsonKey(name: 'total_revenue')
  final double totalRevenue;

  const ProductSalesReportModel({
    required this.productName,
    required this.productSku,
    required this.totalQuantitySold,
    required this.totalRevenue,
  });

  // Métodos de serialización
  factory ProductSalesReportModel.fromJson(Map<String, dynamic> json) => 
      _$ProductSalesReportModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ProductSalesReportModelToJson(this);

  @override
  List<Object?> get props => [
    productName, 
    productSku, 
    totalQuantitySold, 
    totalRevenue
  ];
}