import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecases/get_daily_sales_report.dart';
import '../../data/models/report_model.dart';

// Estados del BLoC
abstract class ReportState extends Equatable {
  const ReportState();
  
  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class DailySalesReportLoaded extends ReportState {
  final List<DailySalesReportModel> reports;

  const DailySalesReportLoaded(this.reports);

  @override
  List<Object?> get props => [reports];
}

class ProductSalesReportLoaded extends ReportState {
  final List<ProductSalesReportModel> reports;

  const ProductSalesReportLoaded(this.reports);

  @override
  List<Object?> get props => [reports];
}

class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);

  @override
  List<Object?> get props => [message];
}

// Eventos del BLoC
abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class FetchDailySalesReportEvent extends ReportEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const FetchDailySalesReportEvent({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class FetchProductSalesReportEvent extends ReportEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const FetchProductSalesReportEvent({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

// BLoC de Reportes
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetDailySalesReportUseCase _getDailySalesReportUseCase;
  final GetProductSalesReportUseCase _getProductSalesReportUseCase;

  ReportBloc({
    required GetDailySalesReportUseCase getDailySalesReportUseCase,
    required GetProductSalesReportUseCase getProductSalesReportUseCase,
  }) : 
    _getDailySalesReportUseCase = getDailySalesReportUseCase,
    _getProductSalesReportUseCase = getProductSalesReportUseCase,
    super(ReportInitial()) {
    
    // Registrar manejadores de eventos
    on<FetchDailySalesReportEvent>(_onFetchDailySalesReport);
    on<FetchProductSalesReportEvent>(_onFetchProductSalesReport);
  }

  // Manejador de evento para obtener reporte de ventas diarias
  Future<void> _onFetchDailySalesReport(
    FetchDailySalesReportEvent event, 
    Emitter<ReportState> emit
  ) async {
    try {
      emit(ReportLoading());

      final reports = await _getDailySalesReportUseCase(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(DailySalesReportLoaded(reports));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  // Manejador de evento para obtener reporte de ventas por producto
  Future<void> _onFetchProductSalesReport(
    FetchProductSalesReportEvent event, 
    Emitter<ReportState> emit
  ) async {
    try {
      emit(ReportLoading());

      final reports = await _getProductSalesReportUseCase(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(ProductSalesReportLoaded(reports));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}