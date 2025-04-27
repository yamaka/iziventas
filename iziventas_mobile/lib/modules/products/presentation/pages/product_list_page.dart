import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../blocs/product_bloc.dart';
import '../../data/models/product_model.dart';
import '../widgets/product_list_item.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Configurar scroll infinito
    _scrollController.addListener(_onScroll);
    
    // Cargar productos iniciales
    context.read<ProductBloc>().add(const FetchProductsEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == 
        _scrollController.position.maxScrollExtent) {
      // Cargar más productos cuando se llega al final
      context.read<ProductBloc>().add(const FetchProductsEvent());
    }
  }

  void _navigateToCreateProduct() {
    Navigator.pushNamed(context, AppRoutes.productCreate);
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    context.read<ProductBloc>().add(
      FetchProductsEvent(
        forceRefresh: true, 
        searchQuery: query
      )
    );
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<ProductBloc>().add(
      const FetchProductsEvent(forceRefresh: true)
    );
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            )
          : const Text('Productos'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.done : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _clearSearch();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreateProduct,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProductBloc>().add(
            const FetchProductsEvent(forceRefresh: true)
          );
        },
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading && state is! ProductsLoaded) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ProductError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error al cargar productos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ProductBloc>().add(
                        const FetchProductsEvent(forceRefresh: true)
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is ProductsLoaded) {
              if (state.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 80,
                        color: AppColors.titleColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay productos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agrega tu primer producto',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _navigateToCreateProduct,
                        child: const Text('Agregar Producto'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                itemCount: state.hasReachedMax 
                  ? state.products.length 
                  : state.products.length + 1,
                itemBuilder: (context, index) {
                  // Mostrar indicador de carga al final si no se ha alcanzado el máximo
                  if (index >= state.products.length) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor, // Correct usage
                      ),
                    );
                  }

                  final product = state.products[index];
                  return ProductListItem(
                    product: product,
                    onTap: () {
                      // Navegar a detalle de producto
                      Navigator.pushNamed(
                        context, 
                        AppRoutes.productDetail,
                        arguments: product
                      );
                    },
                    onEdit: () {
                      // Navegar a formulario de edición
                      Navigator.pushNamed(
                        context, 
                        AppRoutes.productCreate,
                        arguments: product
                      );
                    },
                    onDelete: () {
                      // Mostrar diálogo de confirmación
                      _showDeleteConfirmationDialog(context, product);
                    },
                    onUpdateStock: () {
                      // Mostrar diálogo de actualización de stock
                      _showUpdateStockDialog(context, product);
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateProduct,
        backgroundColor: AppColors.buttonColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Diálogo de confirmación de eliminación
  void _showDeleteConfirmationDialog(
    BuildContext context, 
    ProductModel product
  ) {
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
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // Diálogo de actualización de stock
  void _showUpdateStockDialog(
    BuildContext context, 
    ProductModel product
  ) {
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