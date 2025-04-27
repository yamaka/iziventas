import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/product_model.dart';
import '../blocs/product_bloc.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductModel product;

  const ProductDetailPage({
    super.key, 
    required this.product
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles del Producto',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.buttonColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navegar a formulario de edición
              Navigator.pushNamed(
                context, 
                AppRoutes.productCreate,
                arguments: product
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen de producto (placeholder)
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.image, 
                size: 100, 
                color: AppColors.titleColor
              ),
            ),
            const SizedBox(height: 20),

            // Información del producto
            _buildProductInfoCard(context),
            const SizedBox(height: 20),

            // Estadísticas de inventario
            _buildInventoryStatsCard(context),
            const SizedBox(height: 20),

            // Acciones
            _buildActionsCard(context),
          ],
        ),
      ),
    );
  }

  // Tarjeta de información del producto
  Widget _buildProductInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Producto',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.titleColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildDetailRow(
              icon: Icons.shopping_bag,
              label: 'Nombre',
              value: product.name,
            ),
            _buildDetailRow(
              icon: Icons.description,
              label: 'Descripción',
              value: product.description ?? 'Sin descripción',
            ),
            _buildDetailRow(
              icon: Icons.attach_money,
              label: 'Precio',
              value: Formatters.formatCurrency(product.price),
            ),
            _buildDetailRow(
              icon: Icons.code,
              label: 'SKU',
              value: product.sku,
            ),
            _buildDetailRow(
              icon: Icons.info,
              label: 'Estado',
              value: product.status == 'active' 
                ? 'Activo' 
                : 'Inactivo',
            ),
          ],
        ),
      ),
    );
  }

  // Tarjeta de estadísticas de inventario
  Widget _buildInventoryStatsCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventario',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.titleColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildDetailRow(
              icon: Icons.inventory,
              label: 'Stock Actual',
              value: product.stock.toString(),
              valueColor: product.stock > 10 
                ? Colors.green 
                : Colors.orange,
            ),
            _buildDetailRow(
              icon: Icons.monetization_on,
              label: 'Valor de Inventario',
              value: Formatters.formatCurrency(product.inventoryValue),
            ),
          ],
        ),
      ),
    );
  }

  // Tarjeta de acciones
  Widget _buildActionsCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Acciones',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.titleColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
            const Divider(),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_box),
              label: const Text('Agregar Stock'),
              onPressed: () {
                _showUpdateStockDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Editar Producto'),
              onPressed: () {
                Navigator.pushNamed(
                  context, 
                  AppRoutes.productCreate,
                  arguments: product
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fila de detalle reutilizable
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.titleColor),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Diálogo de confirmación de eliminación
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text(
          '¿Está seguro que desea eliminar "${product.name}"?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              // Eliminar producto
              context.read<ProductBloc>().add(
                DeleteProductEvent(product.id!)
              );
              // Cerrar diálogos y página
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // Diálogo de actualización de stock
  void _showUpdateStockDialog(BuildContext context) {
    final stockController = TextEditingController(
      text: product.stock.toString()
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actualizar Stock - ${product.name}'),
        content: TextField(
          controller: stockController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nuevo Stock',
            hintText: 'Ingrese la cantidad de stock',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(stockController.text);
              if (newStock != null && newStock >= 0) {
                // Actualizar stock
                context.read<ProductBloc>().add(
                  UpdateProductStockEvent(product.id!, newStock)
                );
                Navigator.pop(context);
              } else {
                // Mostrar error de validación
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingrese un stock válido'),
                    backgroundColor: AppColors.error,
                  )
                );
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}