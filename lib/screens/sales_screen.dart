import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zyae/cubits/sales/sales_cubit.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/models/sale.dart';
import 'package:zyae/theme/app_theme.dart';
import 'package:zyae/widgets/stat_card.dart';
import 'package:zyae/widgets/sale_list_item.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  DateTimeRange? _selectedDateRange;
  bool _sortAscending = false;

  List<Sale> _getFilteredSales(List<Sale> sales) {
    var filtered = List<Sale>.from(sales);

    if (_selectedDateRange != null) {
      filtered = filtered.where((s) {
        return s.date.isAfter(_selectedDateRange!.start.subtract(const Duration(seconds: 1))) &&
            s.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    filtered.sort((a, b) {
      return _sortAscending ? a.date.compareTo(b.date) : b.date.compareTo(a.date);
    });

    return filtered;
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final salesState = context.watch<SalesCubit>().state;
    final sales = salesState.sales;
    final filteredSales = _getFilteredSales(sales);
    final l10n = AppLocalizations.of(context)!;
    // final formatter = DateFormat('dd MMM, hh:mm a');

    // --- Analysis Calculations ---
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = now.subtract(const Duration(days: 7));

    double todayTotal = 0;
    double weekTotal = 0;
    double monthTotal = 0;
    int todayOrders = 0;

    final Map<String, int> productSales = {};
    final Map<String, Product> productMap = {};

    for (final sale in sales) {
      // Today
      if (sale.date.isAfter(todayStart) || sale.date.isAtSameMomentAs(todayStart)) {
        todayTotal += sale.total;
        todayOrders++;
      }
      // Week
      if (sale.date.isAfter(weekStart)) {
        weekTotal += sale.total;
      }
      // Month
      if (sale.date.year == now.year && sale.date.month == now.month) {
        monthTotal += sale.total;
      }

      for (final item in sale.items) {
        final pid = item.product.id;
        productSales[pid] = (productSales[pid] ?? 0) + item.quantity;
        productMap[pid] = item.product;
      }
    }

    final topProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = topProducts.take(5).toList();
    final maxProductSales = top5.isNotEmpty ? top5.first.value : 1;

    // Avg Order Value (Overall)
    final avgOrderValue = sales.isEmpty ? 0.0 : sales.fold(0.0, (sum, s) => sum + s.total) / sales.length;

    // --- Bar Chart Data ---
    final last7Days = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return DateTime(date.year, date.month, date.day);
    });

    final dailyTotals = List.generate(7, (index) {
      final date = last7Days[index];
      final dailySales = sales.where((s) {
        final sDate = s.date;
        return sDate.year == date.year &&
            sDate.month == date.month &&
            sDate.day == date.day;
      });
      return dailySales.fold(0.0, (sum, s) => sum + s.total);
    });

    final maxDailyTotal = dailyTotals.reduce((a, b) => a > b ? a : b);
    final maxY = maxDailyTotal > 0 ? maxDailyTotal * 1.2 : 100.0;

    return Scaffold(
      body: SafeArea(
        child: sales.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      '${l10n.noSalesYet}\n${l10n.startNewSale}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.sales,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Summary Grid
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  SizedBox(
                                    width: (constraints.maxWidth - 12) / 2,
                                    child: StatCard(
                                      title: l10n.today,
                                      value: '${NumberFormat("#,##0").format(todayTotal)} MMK',
                                      icon: Icons.today,
                                      iconColor: Colors.blue,
                                      iconBgColor: Colors.blue.withValues(alpha: 0.1),
                                      subtitle: '$todayOrders ${l10n.orders}',
                                    ),
                                  ),
                                  SizedBox(
                                    width: (constraints.maxWidth - 12) / 2,
                                    child: StatCard(
                                      title: l10n.thisWeek,
                                      value: '${NumberFormat("#,##0").format(weekTotal)} MMK',
                                      icon: Icons.calendar_view_week,
                                      iconColor: Colors.orange,
                                      iconBgColor: Colors.orange.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  SizedBox(
                                    width: (constraints.maxWidth - 12) / 2,
                                    child: StatCard(
                                      title: l10n.thisMonth,
                                      value: '${NumberFormat("#,##0").format(monthTotal)} MMK',
                                      icon: Icons.calendar_month,
                                      iconColor: Colors.purple,
                                      iconBgColor: Colors.purple.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  SizedBox(
                                    width: (constraints.maxWidth - 12) / 2,
                                    child: StatCard(
                                      title: 'Avg. Order', // Consider adding to l10n
                                      value: '${NumberFormat("#,##0").format(avgOrderValue)} MMK',
                                      icon: Icons.pie_chart_outline,
                                      iconColor: Colors.teal,
                                      iconBgColor: Colors.teal.withValues(alpha: 0.1),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Weekly Chart
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.weeklySales,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  height: 200,
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: maxY,
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        touchTooltipData: BarTouchTooltipData(
                                          getTooltipColor: (group) => AppTheme.primaryColor,
                                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                            return BarTooltipItem(
                                            '${NumberFormat("#,##0").format(rod.toY)} MMK',
                                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal,
                                            ) ?? const TextStyle(color: Colors.white),
                                          );
                                          },
                                        ),
                                      ),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              final index = value.toInt();
                                              if (index >= 0 && index < last7Days.length) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Text(
                                                    DateFormat.E().format(last7Days[index]),
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.normal,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const SizedBox();
                                            },
                                            reservedSize: 30,
                                          ),
                                        ),
                                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      ),
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: maxY / 5,
                                        getDrawingHorizontalLine: (value) => FlLine(
                                          color: Colors.grey[100],
                                          strokeWidth: 1,
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      barGroups: List.generate(7, (index) {
                                        return BarChartGroupData(
                                          x: index,
                                          barRods: [
                                            BarChartRodData(
                                              toY: dailyTotals[index],
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppTheme.primaryColor,
                                                  AppTheme.primaryColor.withValues(alpha: 0.7),
                                                ],
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                              ),
                                              width: 12,
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                              backDrawRodData: BackgroundBarChartRodData(
                                                show: true,
                                                toY: maxY,
                                                color: Colors.grey[50],
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Top Products
                          if (top5.isNotEmpty) ...[
                            Text(
                              l10n.topSellingProducts,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: top5.map((entry) {
                                  final product = productMap[entry.key]!;
                                  final count = entry.value;
                                  final percentage = count / maxProductSales;
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                            image: product.imagePath != null
                                                ? DecorationImage(
                                                    image: FileImage(File(product.imagePath!)),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          child: product.imagePath == null
                                              ? Center(
                                                  child: Text(
                                                    product.name.isNotEmpty ? product.name[0] : '?',
                                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      product.name,
                                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Text(
                                                    '$count ${l10n.sold}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: LinearProgressIndicator(
                                                  value: percentage,
                                                  backgroundColor: Colors.grey[100],
                                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                                  minHeight: 6,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Transaction History
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDateRange != null ? l10n.sales : l10n.recentSales,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _sortAscending = !_sortAscending;
                                      });
                                    },
                                    tooltip: _sortAscending ? l10n.oldestFirst : l10n.newestFirst,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.calendar_month_outlined,
                                      color: _selectedDateRange != null ? AppTheme.primaryColor : Colors.grey[600],
                                    ),
                                    onPressed: _pickDateRange,
                                    tooltip: l10n.filterByDate,
                                  ),
                                  if (_selectedDateRange != null)
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.grey),
                                      onPressed: () {
                                        setState(() {
                                          _selectedDateRange = null;
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          if (filteredSales.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32.0),
                              child: Center(
                                child: Text(
                                  l10n.noSalesFound,
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _selectedDateRange != null ? filteredSales.length : filteredSales.take(10).length,
                              itemBuilder: (context, index) {
                                final sale = filteredSales[index];
                                return SaleListItem(sale: sale);
                              },
                            ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
      ),
    );
  }


}
