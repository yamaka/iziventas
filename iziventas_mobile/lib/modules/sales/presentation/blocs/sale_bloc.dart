import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecases/create_sale_usecase.dart';

import '../../data/models/sale_model.dart';

// Estados del BLoC
abstract class SaleState extends Equatable {
  const SaleState();
  
  @override
  List<Object?> get props => [];
}

class SaleInitial extends SaleState {}

class SaleLoading extends SaleState {}

class SalesLoaded extends SaleState {
  final List<SaleModel> sales;
  final bool hasReachedMax;

  const SalesLoaded({
    required this.sales, 
    this.hasReachedMax = false
  });

  SalesLoaded copyWith({
    List<SaleModel>? sales,
    bool? hasReachedMax,
  }) {
    return SalesLoaded(
      sales: sales ?? this.sales,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [sales, hasReachedMax];
}

class SaleCreated extends SaleState {
  final SaleModel sale;

  const SaleCreated(this.sale);

  @override
  List<Object?> get props => [sale];
}

class SaleCancelled extends SaleState {
  final SaleModel sale;

  const SaleCancelled(this.sale);

  @override
  List<Object?> get props => [sale];
}

class SaleError extends SaleState {
  final String message;

  const SaleError(this.message);

  @override
  List<Object?> get props => [message];
}

// Eventos del BLoC
abstract class SaleEvent extends Equatable {
  const SaleEvent();

  @override
  List<Object?> get props => [];
}

class FetchSalesEvent extends SaleEvent {
  final int page;
  final int limit;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool forceRefresh;

  const FetchSalesEvent({
    required this.page,
    this.limit = 10,
    this.startDate,
    this.endDate,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [page, limit, startDate, endDate, forceRefresh];
}

class CreateSaleEvent extends SaleEvent {
  final SaleModel sale;

  const CreateSaleEvent(this.sale);

  @override
  List<Object?> get props => [sale];
}

class CancelSaleEvent extends SaleEvent {
  final String saleId;

  const CancelSaleEvent(this.saleId);

  @override
  List<Object?> get props => [saleId];
}

// BLoC de Ventas
class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final CreateSaleUseCase _createSaleUseCase;
  final GetSalesUseCase _getSalesUseCase;
  final CancelSaleUseCase _cancelSaleUseCase;

  // Paginación
  int _page = 1;
  final int _limit = 10;

  SaleBloc({
    required CreateSaleUseCase createSaleUseCase,
    required GetSalesUseCase getSalesUseCase,
    required CancelSaleUseCase cancelSaleUseCase,
  }) : 
    _createSaleUseCase = createSaleUseCase,
    _getSalesUseCase = getSalesUseCase,
    _cancelSaleUseCase = cancelSaleUseCase,
    super(SaleInitial()) {
    
    // Registrar manejadores de eventos
    on<FetchSalesEvent>(_onFetchSales);
    on<CreateSaleEvent>(_onCreateSale);
    on<CancelSaleEvent>(_onCancelSale);
  }

  // Manejador de evento para obtener ventas
  Future<void> _onFetchSales(
    FetchSalesEvent event,
    Emitter<SaleState> emit,
  ) async {
    try {
      if (state is SaleInitial) {
        emit(SaleLoading());
      }

      final sales = await _getSalesUseCase(
        page: event.page,
        limit: event.limit,
      );

      emit(SalesLoaded(sales: sales, hasReachedMax: sales.isEmpty));
    } catch (e) {
      emit(SaleError(e.toString()));
    }
  }

  // Manejador de evento para crear venta
  Future<void> _onCreateSale(
    CreateSaleEvent event, 
    Emitter<SaleState> emit
  ) async {
    try {
      emit(SaleLoading());
      
      final newSale = await _createSaleUseCase(event.sale);
      
      // Actualizar lista de ventas si está cargada
      if (state is SalesLoaded) {
        final currentState = state as SalesLoaded;
        final updatedSales = List.of(currentState.sales)..insert(0, newSale);
        
        emit(currentState.copyWith(sales: updatedSales));
      }

      emit(SaleCreated(newSale));
    } catch (e) {
      emit(SaleError(e.toString()));
    }
  }

  // Manejador de evento para cancelar venta
  Future<void> _onCancelSale(
    CancelSaleEvent event, 
    Emitter<SaleState> emit
  ) async {
    try {
      emit(SaleLoading());
      
      final cancelledSale = await _cancelSaleUseCase(event.saleId);
      
      // Actualizar lista de ventas si está cargada
      if (state is SalesLoaded) {
        final currentState = state as SalesLoaded;
        final updatedSales = currentState.sales.map((sale) {
          return sale.id == cancelledSale.id ? cancelledSale : sale;
        }).toList();
        
        emit(currentState.copyWith(sales: updatedSales));
      }

      emit(SaleCancelled(cancelledSale));
    } catch (e) {
      emit(SaleError(e.toString()));
    }
  }
}

