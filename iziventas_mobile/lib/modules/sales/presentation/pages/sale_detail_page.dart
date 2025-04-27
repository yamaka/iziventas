import 'package:flutter/material.dart';
import '../../data/models/sale_model.dart';

class SaleDetailPage extends StatelessWidget {
  final SaleModel sale;

  const SaleDetailPage({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Venta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Venta ID: ${sale.id}'),
            Text('Fecha: ${sale.saleDate}'),
            Text('Total: ${sale.totalAmount}'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}