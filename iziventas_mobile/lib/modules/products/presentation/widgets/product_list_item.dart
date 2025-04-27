import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../../../core/utils/formatters.dart';

class ProductListItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onUpdateStock;

  const ProductListItem({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onUpdateStock,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: 10, 
        vertical: 6
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, 
          vertical: 10
        ),
        title: Text(
          product.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.titleColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.attach_money, 
                  size: 16, 
                  color: Colors.green
                ),
                const SizedBox(width: 4),
                Text(
                  Formatters.formatCurrency(product.price),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.inventory, 
                  size: 16, 
                  color: product.stock > 10 
                    ? Colors.green 
                    : Colors.orange
                ),
                const SizedBox(width: 4),
                Text(
                  'Stock: ${product.stock}',
                  style: TextStyle(
                    fontSize: 14,
                    color: product.stock > 10 
                      ? Colors.green 
                      : Colors.orange
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit?.call();
                break;
              case 'delete':
                onDelete?.call();
                break;
              case 'updateStock':
                onUpdateStock?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'updateStock',
              child: Row(
                children: [
                  Icon(Icons.add_box, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Actualizar Stock'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar'),
                ],
              ),
            ),
          ],
          child: const Icon(
            Icons.more_vert,
            color: AppColors.buttonColor,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}