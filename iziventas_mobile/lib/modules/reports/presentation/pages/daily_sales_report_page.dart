import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/constants/app_colors.dart';
import '../blocs/report_bloc.dart';
import '../../data/models/report_model.dart';

class DailySalesReportPage extends StatefulWidget {
  const DailySalesReportPage({super.key});

  @override
  _DailySalesReportPageState createState() => _DailySalesReportPageState();
}

class _DailySalesReportPageState extends State<DailySalesReportPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Cargar reporte inicial
    context.read<ReportBloc>().add(
      const FetchDailySalesReportEvent()
    );
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
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });

      // Recargar reporte con el nuevo rango de fechas
      context.read<ReportBloc>().add(
        FetchDailySalesReportEvent(
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

    // Recargar reporte sin filtro
    context.read<ReportBloc>().add(
      const FetchDailySalesReportEvent()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Ventas Diarias'),
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
      body: Column(
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
            child: BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) {
                if (state is ReportLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is ReportError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error al cargar reporte',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<ReportBloc>().add(
                            FetchDailySalesReportEvent(
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

                if (state is DailySalesReportLoaded) {
                  if (state.reports.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay datos de ventas para mostrar',
                        style: TextStyle(
                          color: AppColors.titleColor,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Gráfico de ventas
                      _buildSalesChart(state.reports),

                      // Resumen de ventas
                      _buildSalesSummary(state.reports),

                      // Lista de ventas diarias
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.reports.length,
                          itemBuilder: (context, index) {
                            final report = state.reports[index];
                            return _buildDailySalesListItem(report);
                          },
                        ),
                      ),
                    ],
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Construir gráfico de ventas
  Widget _buildSalesChart(List<DailySalesReportModel> reports) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: reports.map((r) => r.totalRevenue).reduce((a, b) => a > b ? a : b) * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.transparent,
              tooltipPadding: EdgeInsets.zero,
              tooltipMargin: 8,
              getTooltipItem: (
                BarChartGroupData group,
                int groupIndex,
                BarChartRodData rod,
                int rodIndex,
              ) {
                return BarTooltipItem(
                  '\$${rod.toY.toStringAsFixed(2)}',
                  const TextStyle(
                    color: AppColors.titleColor,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('dd/MM').format(reports[index].date),
                      style: const TextStyle(
                        color: AppColors.textColor,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    '\$${value.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.textColor,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(),
            topTitles: AxisTitles(),
          ),
          gridData: FlGridData(show: false),
          barGroups: reports.asMap().entries.map((entry) {
            final index = entry.key;
            final report = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: report.totalRevenue,
                  color: AppColors.titleColor,
                  width: 15,
                )
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Construir resumen de ventas
  Widget _buildSalesSummary(List<DailySalesReportModel> reports) {
    final totalRevenue = reports.fold(
      0.0, 
      (prev, report) => prev + report.totalRevenue
    );
    final totalSales = reports.fold(
      0, 
      (prev, report) => prev + report.totalSales
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryCard(
            icon: Icons.attach_money,
            label: 'Ingresos Totales',
            value: '\$${totalRevenue.toStringAsFixed(2)}',
          ),
          _buildSummaryCard(
            icon: Icons.shopping_cart,
            label: 'Total de Ventas',
            value: totalSales.toString(),
          ),
        ],
      ),
    );
  }

  // Tarjeta de resumen
  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.titleColor,
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.titleColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Elemento de lista de ventas diarias
  Widget _buildDailySalesListItem(DailySalesReportModel report) {
    return ListTile(
      title: Text(
        DateFormat('EEEE, dd \'de\' MMMM').format(report.date),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.titleColor,
        ),
      ),
      subtitle: Text(
        '${report.totalSales} ventas',
        style: const TextStyle(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Text(
        '\$${report.totalRevenue.toStringAsFixed(2)}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }
}