import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/presentation/blocs/product_bloc.dart';
import '../../data/models/sale_model.dart';
import '../blocs/sale_bloc.dart';

class SaleFormPage extends StatefulWidget {
  final SaleModel? initialSale;

  const SaleFormPage({
    super.key, 
    this.initialSale
  });

  @override
  _SaleFormPageState createState() => _SaleFormPageState();
}

class _SaleFormPageState extends State<SaleFormPage> {
  final List<SaleItemModel> _saleItems = [];
  ProductModel? _selectedProduct;
  final _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar productos iniciales
    context.read<ProductBloc>().add(
      const FetchProductsEvent(forceRefresh: true)
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  // Método para añadir producto a la venta
  void _addProductToSale() {
    if (_selectedProduct == null) {
      _showErrorSnackBar('Seleccione un producto');
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      _showErrorSnackBar('Ingrese una cantidad válida');
      return;
    }

    // Verificar stock disponible
    if (quantity > _selectedProduct!.stock) {
      _showErrorSnackBar('Stock insuficiente');
      return;
    }

    // Crear ítem de venta
    final saleItem = SaleItemModel(
      productId: _selectedProduct!.id!,
      product: _selectedProduct,
      quantity: quantity,
      unitPrice: _selectedProduct!.price,
    );

    setState(() {
      // Verificar si el producto ya está en la lista
      final existingIndex = _saleItems.indexWhere(
        (item) => item.productId == saleItem.productId
      );

      if (existingIndex != -1) {
        // Actualizar cantidad si ya existe
        _saleItems[existingIndex] = SaleItemModel(
          productId: saleItem.productId,
          product: saleItem.product,
          quantity: _saleItems[existingIndex].quantity + quantity,
          unitPrice: saleItem.unitPrice,
        );
      } else {
        // Añadir nuevo ítem
        _saleItems.add(saleItem);
      }

      // Limpiar selección
      _selectedProduct = null;
      _quantityController.clear();
    });
  }

  // Método para eliminar producto de la venta
  void _removeProductFromSale(SaleItemModel item) {
    setState(() {
      _saleItems.remove(item);
    });
  }

  // Método para procesar venta
  void _processSale() {
    if (_saleItems.isEmpty) {
      _showErrorSnackBar('Agregue al menos un producto');
      return;
    }

    // Calcular total de la venta (el cálculo ya se realiza en _calculateTotalAmount)

    // Crear modelo de venta
    final sale = SaleModel(
      id: widget.initialSale?.id, // Proporciona el id solo si existe
      totalAmount: _calculateTotalAmount(),
      saleDate: DateTime.now(),
      status: 'pending',
      items: _saleItems,
    );

    // Enviar evento de crear venta
    context.read<SaleBloc>().add(CreateSaleEvent(sale));

    // Regresar a la lista de ventas
    Navigator.pop(context);
  }

  // Método para calcular el monto total de la venta
  double _calculateTotalAmount() {
    return _saleItems.fold(
      0.0,
      (total, item) => total + (item.quantity * item.unitPrice),
    );
  }

  // Mostrar mensaje de error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialSale != null 
            ? 'Editar Venta' 
            : 'Nueva Venta',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.buttonColor,
      ),
      body: BlocListener<SaleBloc, SaleState>(
        listener: (context, state) {
          if (state is SaleError) {
            _showErrorSnackBar(state.message);
          }
        },
        child: Column(
          children: [
            // Selector de Productos
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Selector de Producto
                  Expanded(
                    flex: 2,
                    child: BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, state) {
                        if (state is ProductsLoaded) {
                          return DropdownButtonFormField<ProductModel>(
                            value: _selectedProduct,
                            hint: const Text('Seleccionar Producto'),
                            items: state.products.map((product) {
                              return DropdownMenuItem(
                                value: product,
                                child: Text(
                                  '${product.name} (Stock: ${product.stock})',
                                ),
                              );
                            }).toList(),
                            onChanged: (product) {
                              setState(() {
                                _selectedProduct = product;
                              });
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          );
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Cantidad
                  Expanded(
                    child: CustomTextField(
                      controller: _quantityController,
                      labelText: 'Cantidad',
                      keyboardType: TextInputType.number,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: _addProductToSale,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de Productos Añadidos
            Expanded(
              child: _saleItems.isEmpty
                ? const Center(
                    child: Text(
                      'Agregue productos a la venta',
                      style: TextStyle(
                        color: AppColors.titleColor,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _saleItems.length,
                    itemBuilder: (context, index) {
                      final item = _saleItems[index];
                      return ListTile(
                        title: Text(item.product?.name ?? 'Producto'),
                        subtitle: Text(
                          'Cantidad: ${item.quantity} - Precio: ${item.unitPrice}'
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeProductFromSale(item),
                        ),
                      );
                    },
                  ),
            ),

            // Total de la Venta
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total de la Venta:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${_saleItems.fold(0.0, (total, item) => total + (item.quantity * item.unitPrice)).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.titleColor,
                    ),
                  ),
                ],
              ),
            ),

            // Botón de Procesar Venta
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomButton(
                onPressed: _processSale,
                child: const Text('Procesar Venta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}