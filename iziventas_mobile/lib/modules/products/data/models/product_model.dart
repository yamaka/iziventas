import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends Equatable {
  final String? id;
  final String name;
  final String? description;
  @JsonKey(fromJson: _stringToDouble) // Usa _stringToDouble para deserializar
  final double price;
  final int stock;
  final String sku;
  final String status;

  const ProductModel({
    this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    required this.sku,
    this.status = 'active',
  });

  // Método para convertir String o double a double
  static double _stringToDouble(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else if (value is double) {
      return value;
    }
    throw Exception('Formato inválido para el campo price');
  }

  // Método para crear una copia con modificaciones
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? sku,
    String? status,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      sku: sku ?? this.sku,
      status: status ?? this.status,
    );
  }

  // Métodos de serialización
  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson({bool excludeId = false}) {
    final data = {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'sku': sku,
    };

    // Excluir el campo `id` si `excludeId` es verdadero
    if (!excludeId && id != null) {
      data['id'] = id;
    }

    return data;
  }

  // Implementación de propiedades de Equatable
  @override
  List<Object?> get props => [id, name, description, price, stock, sku, status];

  // Método para calcular valor total de inventario
  double get inventoryValue => price * stock;

  // Método para verificar si hay stock disponible
  bool isStockAvailable(int quantity) => stock >= quantity;
}