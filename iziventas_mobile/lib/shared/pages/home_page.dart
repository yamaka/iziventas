import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../modules/auth/presentation/blocs/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IziVentas'),
        backgroundColor: AppColors.buttonColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Cerrar sesión
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _buildDashboardItem(
            context,
            icon: Icons.inventory,
            label: 'Productos',
            route: AppRoutes.productList,
          ),
          _buildDashboardItem(
            context,
            icon: Icons.shopping_cart,
            label: 'Ventas',
            route: AppRoutes.saleList,
          ),
          _buildDashboardItem(
            context,
            icon: Icons.bar_chart,
            label: 'Reportes',
            route: AppRoutes.dailySalesReport,
          ),
        ],
      ),
    );
  }

  // Método para construir elementos del dashboard
  Widget _buildDashboardItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: AppColors.titleColor,
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                color: AppColors.titleColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}