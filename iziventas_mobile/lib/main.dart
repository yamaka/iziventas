import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importaciones de configuración
import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'core/network/api_client.dart';

// Importaciones de módulos
import 'modules/auth/data/datasources/local_auth_datasource.dart';
import 'modules/auth/data/datasources/remote_auth_datasource.dart';
import 'modules/auth/data/repositories/auth_repository.dart';
import 'modules/auth/domain/usecases/login_usecase.dart';
import 'modules/auth/presentation/blocs/auth_bloc.dart';

import 'modules/auth/presentation/pages/login_page.dart';
import 'modules/products/data/datasources/local_product_datasource.dart';
import 'modules/products/data/datasources/remote_product_datasource.dart';
import 'modules/products/data/repositories/product_repository.dart';
import 'modules/products/domain/usecases/create_product_usecase.dart';
import 'modules/products/domain/usecases/update_product_usecase.dart';

import 'modules/products/presentation/blocs/product_bloc.dart';

import 'modules/sales/data/datasources/local_sale_datasource.dart';
import 'modules/sales/data/datasources/remote_sale_datasource.dart';
import 'modules/sales/data/models/sale_model.dart';
import 'modules/sales/data/repositories/sale_repository.dart';
import 'modules/sales/domain/usecases/create_sale_usecase.dart';
import 'modules/sales/presentation/blocs/sale_bloc.dart';

import 'modules/reports/data/repositories/report_repository.dart';
import 'modules/reports/domain/usecases/get_daily_sales_report.dart';
import 'modules/reports/presentation/blocs/report_bloc.dart';
import 'modules/sales/presentation/pages/sale_detail_page.dart';
import 'modules/sales/presentation/pages/sale_form_page.dart';
import 'modules/sales/presentation/pages/sale_list_page.dart';
import 'shared/pages/home_page.dart';

void main() async {
  // Asegurar inicialización de widgets
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar servicios
  final secureStorage = const FlutterSecureStorage();
  final sharedPreferences = await SharedPreferences.getInstance();
  final apiClient = ApiClient();

  // Inicializar repositorios y casos de uso
  final authRepository = AuthRepository(
    remoteDataSource: RemoteAuthDataSource(
      apiClient: apiClient,
      secureStorage: secureStorage,
    ),
    localDataSource: LocalAuthDataSource(
      secureStorage: secureStorage,
      sharedPreferences: sharedPreferences,
    ),
  );

  final productRepository = ProductRepository(
    remoteDataSource: RemoteProductDataSource(apiClient),
    localDataSource: LocalProductDataSource(sharedPreferences),
  );

  final saleRepository = SaleRepository(
    remoteDataSource: RemoteSaleDataSource(apiClient),
    localDataSource: LocalSaleDataSource(sharedPreferences),
  );

  final reportRepository = ReportRepository(
    RemoteSaleDataSource(apiClient)
  );

  // Inicializar casos de uso
  final loginUseCase = LoginUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);

  final createProductUseCase = CreateProductUseCase(productRepository);
  final getProductsUseCase = GetProductsUseCase(productRepository);
  final updateProductUseCase = UpdateProductUseCase(productRepository);
  final deleteProductUseCase = DeleteProductUseCase(productRepository);

  final createSaleUseCase = CreateSaleUseCase(saleRepository);
  final getSalesUseCase = GetSalesUseCase(saleRepository);
  final cancelSaleUseCase = CancelSaleUseCase(saleRepository);

  final getDailySalesReportUseCase = GetDailySalesReportUseCase(reportRepository);
  final getProductSalesReportUseCase = GetProductSalesReportUseCase(reportRepository);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: productRepository),
        RepositoryProvider.value(value: saleRepository),
        RepositoryProvider.value(value: reportRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          // Blocs
          BlocProvider(
            create: (context) => AuthBloc(
              loginUseCase: loginUseCase,
              logoutUseCase: logoutUseCase,
              registerUseCase: registerUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => ProductBloc(
              getProductsUseCase: getProductsUseCase,
              createProductUseCase: createProductUseCase,
              updateProductUseCase: updateProductUseCase,
              deleteProductUseCase: deleteProductUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => SaleBloc(
              createSaleUseCase: createSaleUseCase,
              getSalesUseCase: getSalesUseCase,
              cancelSaleUseCase: cancelSaleUseCase,
            ),
          ),
          BlocProvider(
            create: (context) => ReportBloc(
              getDailySalesReportUseCase: getDailySalesReportUseCase,
              getProductSalesReportUseCase: getProductSalesReportUseCase,
            ),
          ),
        ],
        child: const IziVentasApp(),
      ),
    ),
  );
}

class IziVentasApp extends StatelessWidget {
  const IziVentasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IziVentas',
      debugShowCheckedModeBanner: false,
      
      // Tema de la aplicación
      theme: AppColors.theme,
      
      // Localización
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español
        Locale('en', 'US'), // Inglés
      ],
      
      // Navegación
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
      routes: {
        AppRoutes.saleList: (context) => const SaleListPage(),
        AppRoutes.saleCreate: (context) => const SaleFormPage(),
        AppRoutes.saleDetail: (context) {
          final SaleModel sale = ModalRoute.of(context)!.settings.arguments as SaleModel;
          return SaleDetailPage(sale: sale);
        },
      },
      
      // Manejo de estado de autenticación
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (state is AuthAuthenticated) {
            return const HomePage();
          }
          
          return const LoginPage();
        },
      ),
    );
  }
}