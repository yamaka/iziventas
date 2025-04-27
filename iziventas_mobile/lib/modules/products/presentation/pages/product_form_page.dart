import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../data/models/product_model.dart';
import '../blocs/product_bloc.dart';

class ProductFormPage extends StatefulWidget {
  final ProductModel? product;

  const ProductFormPage({
    super.key, 
    this.product
  });

  @override
  _ProductFormPageState createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _skuController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores
    _nameController = TextEditingController(
      text: widget.product?.name ?? ''
    );
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? ''
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? ''
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? ''
    );
    _skuController = TextEditingController(
      text: widget.product?.sku ?? ''
    );

    // Verificar si es edición
    _isEditing = widget.product != null;
  }

  @override
  void dispose() {
    // Limpiar controladores
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final productModel = ProductModel(
        id: widget.product?.id, // Asegúrate de incluir el ID del producto
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        sku: _skuController.text.trim(),
      );

      if (_isEditing) {
        // Enviar evento de actualización
        context.read<ProductBloc>().add(UpdateProductEvent(productModel));
      } else {
        // Enviar evento de creación
        context.read<ProductBloc>().add(CreateProductEvent(productModel));
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Producto' : 'Nuevo Producto',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.buttonColor,
      ),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductError) {
            // Mostrar mensaje de error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              )
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo de Nombre
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Nombre del Producto',
                  prefixIcon: Icons.shopping_bag,
                  validator: (value) => Validators.validateName(value),
                ),
                const SizedBox(height: 16),

                // Campo de Descripción
                CustomTextField(
                  controller: _descriptionController,
                  labelText: 'Descripción (Opcional)',
                  prefixIcon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Campo de Precio
                CustomTextField(
                  controller: _priceController,
                  labelText: 'Precio',
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) => Validators.validatePrice(value),
                ),
                const SizedBox(height: 16),

                // Campo de Stock
                CustomTextField(
                  controller: _stockController,
                  labelText: 'Stock Inicial',
                  prefixIcon: Icons.inventory,
                  keyboardType: TextInputType.number,
                  validator: (value) => Validators.validateStock(value),
                ),
                const SizedBox(height: 16),

                // Campo de SKU
                CustomTextField(
                  controller: _skuController,
                  labelText: 'SKU',
                  prefixIcon: Icons.code,
                  validator: (value) => Validators.validateSku(value),
                ),
                const SizedBox(height: 24),

                // Botón de Guardar
                CustomButton(
                  onPressed: _submitForm,
                  child: Text(
                    _isEditing ? 'Actualizar Producto' : 'Crear Producto'
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}