import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../blocs/sale_bloc.dart';
import '../../data/models/sale_model.dart';
import '../widgets/sale_list_item.dart';

class SaleListPage extends StatefulWidget {
  const SaleListPage({super.key});

  @override
  SaleListPageState createState() => SaleListPageState();
}

class SaleListPageState extends State<SaleListPage> {
  final _scrollController = ScrollController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Configurar scroll infinito
    _scrollController.addListener(_onScroll);
    
    // Cargar ventas iniciales
    context.read<SaleBloc>().add(const FetchSalesEvent(page: 1));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == 
        _scrollController.position.maxScrollExtent) {
      // Cargar más ventas cuando se llega al final
      context.read<SaleBloc>().add(
    FetchSalesEvent(
      page: 1, // Ensure the required 'page' parameter is provided
      startDate: _startDate,
      endDate: _endDate,
    )
      );
    }
  }

  // Mostrar selector de rango de fechas
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
        ? DateTimeRange(start: _startDate!, end: _endDate!)
        : null,
    );

    if (picked != null) {
      if (!mounted) return;
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });

      // Recargar ventas con el nuevo rango de fechas
      context.read<SaleBloc>().add(
        FetchSalesEvent(
          page: 1,
          forceRefresh: true,
          startDate: _startDate,
          endDate: _endDate,
        )
      );
    }
  }

  // Limpiar filtro de fechas
  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });

    // Recargar ventas sin filtro
    context.read<SaleBloc>().add(
      const FetchSalesEvent(page: 1,forceRefresh: true)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
        backgroundColor: AppColors.buttonColor,
        actions: [
          // Filtro de fechas
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _selectDateRange,
          ),
          // Limpiar filtro
          if (_startDate != null || _endDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearDateFilter,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<SaleBloc>().add(
            FetchSalesEvent(
              page: 1, // Proporciona el número de página
              limit: 10, // Opcional, ajusta según sea necesario
              forceRefresh: true, // Si es necesario
              startDate: _startDate, // Si estás usando filtros de fecha
              endDate: _endDate, // Si estás usando filtros de fecha
            )
          );
        },
        child: Column(
          children: [
            // Mostrar rango de fechas seleccionado
            if (_startDate != null && _endDate != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ventas del ${DateFormat('dd/MM/yyyy').format(_startDate!)} al ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                      style: const TextStyle(
                        color: AppColors.titleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: BlocBuilder<SaleBloc, SaleState>(
                builder: (context, state) {
                  if (state is SaleLoading && state is! SalesLoaded) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is SaleError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error al cargar ventas',
                            style: Theme.of(context).textTheme.titleLarge, // Updated headline6
                          ),
                          const SizedBox(height: 16),
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<SaleBloc>().add(
                              FetchSalesEvent(
                                page: 1,
                                forceRefresh: true,
                                startDate: _startDate,
                                endDate: _endDate,
                              )
                            ),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is SalesLoaded) {
                    if (state.sales.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: AppColors.titleColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay ventas registradas',
                              
                              style: Theme.of(context).textTheme.titleLarge, // Updated headline6
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Realiza tu primera venta',
                              style: Theme.of(context).textTheme.bodyMedium, // Updated bodyText2
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: state.hasReachedMax 
                        ? state.sales.length 
                        : state.sales.length + 1,
                      itemBuilder: (context, index) {
                        // Mostrar indicador de carga al final si no se ha alcanzado el máximo
                        if (index >= state.sales.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final sale = state.sales[index];
                        return SaleListItem(
                          sale: sale,
                          onTap: () {
                            Navigator.pushNamed( // Implemented navigation to sale details
                              context,
                              AppRoutes.saleDetail,
                              arguments: sale,
                            );
                          },
                          onCancel: () {
                            // Mostrar diálogo de confirmación de cancelación
                            _showCancelSaleDialog(context, sale);
                          },
                        );
                      },
                    );
                  }

                  // Estado inicial
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a crear venta
          Navigator.pushNamed(context, AppRoutes.saleCreate);
        },
        backgroundColor: AppColors.buttonColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Diálogo de confirmación de cancelación de venta
  void _showCancelSaleDialog(BuildContext context, SaleModel sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Venta'),
        content: Text(
          '¿Está seguro que desea cancelar la venta de ${sale.items.length} producto(s)?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              // Cancelar venta
              context.read<SaleBloc>().add(
                CancelSaleEvent(sale.id!)
              );
              Navigator.pop(context);
            },
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }
}