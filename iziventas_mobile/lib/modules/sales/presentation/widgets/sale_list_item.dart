import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/sale_model.dart';
import '../../../../core/utils/formatters.dart';

class SaleListItem extends StatelessWidget {
  final SaleModel sale;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const SaleListItem({
    super.key,
    required this.sale,
    this.onTap,
    this.onCancel,
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Venta #${sale.id?.substring(0, 6) ?? 'N/A'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.titleColor,
              ),
            ),
            _buildStatusChip(),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today, 
                  size: 16, 
                  color: Colors.grey
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(sale.saleDate),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.shopping_basket, 
                  size: 16, 
                  color: Colors.green
                ),
                const SizedBox(width: 4),
                Text(
                  '${sale.items.length} producto(s)',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
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
                  Formatters.formatCurrency(sale.totalAmount),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case'details':
                // TODO: Implementar navegación a detalles
                break;
              case 'cancel':
                onCancel?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Ver Detalles'),
                ],
              ),
            ),
            if (sale.status == 'completed')
              const PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cancelar Venta'),
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

  // Método para construir chip de estado
  Widget _buildStatusChip() {
    Color chipColor;
    String statusText;

    switch (sale.status) {
      case 'completed':
        chipColor = Colors.green;
        statusText = 'Completada';
        break;
      case 'cancelled':
        chipColor = Colors.red;
        statusText = 'Cancelada';
        break;
      default:
        chipColor = Colors.orange;
        statusText = 'Pendiente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8, 
        vertical: 4
      ),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}