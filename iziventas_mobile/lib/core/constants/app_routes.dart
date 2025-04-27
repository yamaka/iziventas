import 'package:flutter/material.dart';

// Importaciones de páginas
import '../../modules/auth/presentation/pages/login_page.dart';
import '../../modules/auth/presentation/pages/register_page.dart';
import '../../modules/products/data/models/product_model.dart';
import '../../modules/products/presentation/pages/product_list_page.dart';
import '../../modules/products/presentation/pages/product_form_page.dart' as product_form;
import '../../modules/products/presentation/pages/product_detail_page.dart' as product_detail;
import '../../modules/sales/data/models/sale_model.dart';
import '../../modules/sales/presentation/pages/sale_list_page.dart';
import '../../modules/sales/presentation/pages/sale_form_page.dart';
import '../../modules/reports/presentation/pages/daily_sales_report_page.dart';
import '../../shared/pages/home_page.dart';
import '../../shared/pages/splash_page.dart';

// Definición de rutas
class AppRoutes {
  // Rutas generales
  static const String splash = '/';
  static const String home = '/home';
  
  // Rutas de autenticación
  static const String login = '/login';
  static const String register = '/register';
  
  // Rutas de productos
  static const String productList = '/products';
  static const String productCreate = '/products/create';
  static const String productDetail = '/products/detail';
  
  // Rutas de ventas
  static const String saleList = '/sales';
  static const String saleCreate = '/sales/create';
  static const String saleDetail = '/sales/detail'; // Add this line
  
  // Rutas de reportes
  static const String dailySalesReport = '/reports/daily-sales';
}

// Manejador de navegación
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Rutas generales
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      
      // Rutas de autenticación
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      
      // Rutas de productos
      case AppRoutes.productList:
        return MaterialPageRoute(builder: (_) => const ProductListPage());
      case AppRoutes.productCreate:
        return MaterialPageRoute(
          builder: (_) => product_form.ProductFormPage(
            product: settings.arguments as ProductModel?,
          )
        );
      case AppRoutes.productDetail:
        return MaterialPageRoute(
          builder: (_) => product_detail.ProductDetailPage(
            product: settings.arguments as ProductModel,
          )
        );
      
      // Rutas de ventas
      case AppRoutes.saleList:
        return MaterialPageRoute(builder: (_) => const SaleListPage());
      case AppRoutes.saleCreate:
        return MaterialPageRoute(
          builder: (_) => SaleFormPage(
            initialSale: settings.arguments as SaleModel?,
          )
        );
      
      // Rutas de reportes
      case AppRoutes.dailySalesReport:
        return MaterialPageRoute(builder: (_) => const DailySalesReportPage());
      
      // Ruta por defecto
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No se encontró la ruta: ${settings.name}'),
            ),
          ),
        );
    }
  }
}