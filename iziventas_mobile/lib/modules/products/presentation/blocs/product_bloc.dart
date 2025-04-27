import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecases/create_product_usecase.dart';
// import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
// import '../../domain/usecases/delete_product_usecase.dart';
import '../../data/models/product_model.dart';

// Estados del BLoC
abstract class ProductState extends Equatable {
  const ProductState();
  
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<ProductModel> products;
  final bool hasReachedMax;

  const ProductsLoaded({
    required this.products, 
    this.hasReachedMax = false
  });

  ProductsLoaded copyWith({
    List<ProductModel>? products,
    bool? hasReachedMax,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [products, hasReachedMax];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

// Eventos del BLoC
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class FetchProductsEvent extends ProductEvent {
  final bool forceRefresh;
  final String? searchQuery;

  const FetchProductsEvent({
    this.forceRefresh = false,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [forceRefresh, searchQuery];
}

class CreateProductEvent extends ProductEvent {
  final ProductModel product;

  const CreateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProductEvent extends ProductEvent {
  final ProductModel product;

  const UpdateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProductEvent extends ProductEvent {
  final String productId;

  const DeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UpdateProductStockEvent extends ProductEvent {
  final String productId;
  final int stockAmount;

  const UpdateProductStockEvent(this.productId, this.stockAmount);

  @override
  List<Object?> get props => [productId, stockAmount];
}

// BLoC de Productos
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase _getProductsUseCase;
  final CreateProductUseCase _createProductUseCase;
  final UpdateProductUseCase _updateProductUseCase;
  final DeleteProductUseCase _deleteProductUseCase;

  // Paginación
  int _page = 1;
  final int _limit = 10;

  ProductBloc({
    required GetProductsUseCase getProductsUseCase,
    required CreateProductUseCase createProductUseCase,
    required UpdateProductUseCase updateProductUseCase,
    required DeleteProductUseCase deleteProductUseCase,
  }) : 
    _getProductsUseCase = getProductsUseCase,
    _createProductUseCase = createProductUseCase,
    _updateProductUseCase = updateProductUseCase,
    _deleteProductUseCase = deleteProductUseCase,
    super(ProductInitial()) {
    
    // Registrar manejadores de eventos
    on<FetchProductsEvent>(_onFetchProducts);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<UpdateProductStockEvent>(_onUpdateProductStock);
  }

  // Manejador de evento para obtener productos
  Future<void> _onFetchProducts(
    FetchProductsEvent event, 
    Emitter<ProductState> emit
  ) async {
    // Si es un refresco forzado, reiniciar página
    if (event.forceRefresh) {
      _page = 1;
      emit(ProductInitial());
    }

    // Si ya está cargando, evitar múltiples solicitudes
    if (state is ProductsLoaded && 
        (state as ProductsLoaded).hasReachedMax && 
        !event.forceRefresh) {
      return;
    }

    try {
      // Si es el estado inicial, mostrar carga
      if (state is ProductInitial) {
        emit(ProductLoading());
      }

      // Obtener productos
      final products = await _getProductsUseCase(
        page: _page,
        limit: _limit,
        search: event.searchQuery,
        forceRefresh: event.forceRefresh,
      );

      // Determinar si se alcanzó el máximo
      final hasReachedMax = products.length < _limit;

      // Si es un refresco, reemplazar lista
      if (event.forceRefresh) {
        emit(ProductsLoaded(
          products: products, 
          hasReachedMax: hasReachedMax
        ));
      } else {
        // Combinar con productos existentes si es paginación
        final currentState = state;
        List<ProductModel> updatedProducts = [];
        
        if (currentState is ProductsLoaded) {
          updatedProducts = List.of(currentState.products);
        }
        
        updatedProducts.addAll(products);

        emit(ProductsLoaded(
          products: updatedProducts, 
          hasReachedMax: hasReachedMax
        ));
      }

      // Incrementar página para próxima carga
      _page++;
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  // Manejador de evento para crear producto
  Future<void> _onCreateProduct(
    CreateProductEvent event, 
    Emitter<ProductState> emit
  ) async {
    try {
      final newProduct = await _createProductUseCase(event.product);
      
      // Actualizar lista de productos
      if (state is ProductsLoaded) {
        final currentState = state as ProductsLoaded;
        final updatedProducts = List.of(currentState.products)..insert(0, newProduct);
        
        emit(currentState.copyWith(products: updatedProducts));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  // Manejador de evento para actualizar producto
  Future<void> _onUpdateProduct(
    UpdateProductEvent event, 
    Emitter<ProductState> emit
  ) async {
    try {
      final updatedProduct = await _updateProductUseCase(event.product);
      
      if (state is ProductsLoaded) {
        final currentState = state as ProductsLoaded;
        final updatedProducts = currentState.products.map((product) {
          return product.id == updatedProduct.id ? updatedProduct : product;
        }).toList();
        
        emit(currentState.copyWith(products: updatedProducts));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  // Manejador de evento para eliminar producto
  Future<void> _onDeleteProduct(
    DeleteProductEvent event, 
    Emitter<ProductState> emit
  ) async {
    try {
      await _deleteProductUseCase(event.productId);
      
      if (state is ProductsLoaded) {
        final currentState = state as ProductsLoaded;
        final updatedProducts = currentState.products
          .where((product) => product.id != event.productId)
          .toList();
        
        emit(currentState.copyWith(products: updatedProducts));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  // Manejador de evento para actualizar stock
  Future<void> _onUpdateProductStock(
    UpdateProductStockEvent event, 
    Emitter<ProductState> emit
  ) async {
    try {
      if (state is ProductsLoaded) {
        final currentState = state as ProductsLoaded;
        final updatedProducts = currentState.products.map((product) {
          return product.id == event.productId 
            ? product.copyWith(stock: event.stockAmount) 
            : product;
        }).toList();
        
        emit(currentState.copyWith(products: updatedProducts));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}