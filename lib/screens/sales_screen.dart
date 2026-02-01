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
  final ScrollController _scrollController = ScrollController();
  int _visibleCount = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      setState(() {
        _visibleCount += 20;
      });
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

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
              onPrimary: AppTheme.surfaceColor,
              surface: AppTheme.surfaceColor,
              onSurface: AppTheme.textPrimary,
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
    
    // Only show visible count
    final displaySales = filteredSales.take(_visibleCount).toList();

    final stats = _SalesStatistics.calculate(sales);
    final chartData = _ChartData.calculate(sales, stats.maxY);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: sales.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.analytics_outlined, size: 64, color: AppTheme.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      '${l10n.noSalesYet}\n${l10n.startNewSale}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              )
            : CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Text(
                          l10n.sales,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Summary Grid
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final isWide = width > 600;
                            final cardWidth = isWide ? (width - 36) / 4 : (width - 12) / 2;
                            
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: cardWidth,
                                  child: StatCard(
                                    title: l10n.today,
                                    value: '${NumberFormat("#,##0").format(stats.todayTotal)} MMK',
                                    icon: Icons.today,
                                    iconColor: AppTheme.textPrimary,
                                    iconBgColor: AppTheme.textPrimary.withValues(alpha: 0.1),
                                    subtitle: '${stats.todayOrders} ${l10n.orders}',
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: StatCard(
                                    title: l10n.thisWeek,
                                    value: '${NumberFormat("#,##0").format(stats.weekTotal)} MMK',
                                    icon: Icons.calendar_view_week,
                                    iconColor: AppTheme.textPrimary,
                                    iconBgColor: AppTheme.textPrimary.withValues(alpha: 0.1),
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: StatCard(
                                    title: l10n.thisMonth,
                                    value: '${NumberFormat("#,##0").format(stats.monthTotal)} MMK',
                                    icon: Icons.calendar_month,
                                    iconColor: AppTheme.textPrimary,
                                    iconBgColor: AppTheme.textPrimary.withValues(alpha: 0.1),
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: StatCard(
                                    title: 'Avg. Order', // Consider adding to l10n
                                    value: '${NumberFormat("#,##0").format(stats.avgOrderValue)} MMK',
                                    icon: Icons.pie_chart_outline,
                                    iconColor: AppTheme.textPrimary,
                                    iconBgColor: AppTheme.textPrimary.withValues(alpha: 0.1),
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
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.weeklySales,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 200,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: stats.maxY,
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipColor: (group) => AppTheme.primaryColor,
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          return BarTooltipItem(
                                            '${NumberFormat("#,##0").format(rod.toY)} MMK',
                                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppTheme.surfaceColor,
                                              fontWeight: FontWeight.normal,
                                            ) ?? TextStyle(color: AppTheme.surfaceColor),
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
                                            if (index >= 0 && index < chartData.last7Days.length) {
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  DateFormat.E().format(chartData.last7Days[index]),
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: AppTheme.textSecondary,
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
                                      horizontalInterval: stats.maxY / 5,
                                      getDrawingHorizontalLine: (value) => FlLine(
                                        color: AppTheme.borderColor,
                                        strokeWidth: 1,
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barGroups: List.generate(7, (index) {
                                      return BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            toY: chartData.dailyTotals[index],
                                            color: AppTheme.primaryColor,
                                            width: 12,
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                            backDrawRodData: BackgroundBarChartRodData(
                                              show: true,
                                              toY: stats.maxY,
                                              color: AppTheme.accentColor,
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
                        if (stats.top5.isNotEmpty) ...[
                          Text(
                            l10n.topSellingProducts,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
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
                              children: stats.top5.map((entry) {
                                final product = stats.productMap[entry.key]!;
                                final count = entry.value;
                                final percentage = count / stats.maxProductSales;
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppTheme.backgroundColor,
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
                                                    color: AppTheme.textSecondary,
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
                                                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  '$count ${l10n.sold}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: AppTheme.textSecondary,
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
                                                backgroundColor: AppTheme.backgroundColor,
                                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
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

                        // Transaction History Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDateRange != null ? l10n.sales : l10n.recentSales,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                    color: AppTheme.textSecondary,
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
                                    color: _selectedDateRange != null ? AppTheme.primaryColor : AppTheme.textSecondary,
                                  ),
                                  onPressed: _pickDateRange,
                                  tooltip: l10n.filterByDate,
                                ),
                                if (_selectedDateRange != null)
                                  IconButton(
                                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
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
                      ]),
                    ),
                  ),

                  if (filteredSales.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: Text(
                            l10n.noSalesFound,
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= displaySales.length) {
                              return filteredSales.length > displaySales.length 
                                  ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())) 
                                  : const SizedBox();
                            }
                            final sale = displaySales[index];
                            return SaleListItem(sale: sale);
                          },
                          childCount: displaySales.length + (filteredSales.length > displaySales.length ? 1 : 0),
                        ),
                      ),
                    ),
                    
                  const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
                ],
              ),
      ),
    );
  }
}

class _SalesStatistics {
  final double todayTotal;
  final int todayOrders;
  final double weekTotal;
  final double monthTotal;
  final double avgOrderValue;
  final double maxY;
  final List<MapEntry<String, int>> top5;
  final Map<String, Product> productMap;
  final int maxProductSales;

  _SalesStatistics({
    required this.todayTotal,
    required this.todayOrders,
    required this.weekTotal,
    required this.monthTotal,
    required this.avgOrderValue,
    required this.maxY,
    required this.top5,
    required this.productMap,
    required this.maxProductSales,
  });

  factory _SalesStatistics.calculate(List<Sale> sales) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = now.subtract(const Duration(days: 7));

    double todayTotal = 0;
    double weekTotal = 0;
    double monthTotal = 0;
    int todayOrders = 0;

    final Map<String, int> productSales = {};
    final Map<String, Product> productMap = {};

    // First pass: Calculate totals
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

    // Avg Order Value
    final avgOrderValue = sales.isEmpty ? 0.0 : sales.fold(0.0, (sum, s) => sum + s.total) / sales.length;

    // Calculate maxY for chart (needed here or separately? let's keep it here for simplicity of stats)
    // Actually, maxY depends on daily totals which is chart data.
    // Let's do a quick daily total calc for maxY
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
    
    final maxDailyTotal = dailyTotals.isEmpty ? 0.0 : dailyTotals.reduce((a, b) => a > b ? a : b);
    final maxY = maxDailyTotal > 0 ? maxDailyTotal * 1.2 : 100.0;

    return _SalesStatistics(
      todayTotal: todayTotal,
      todayOrders: todayOrders,
      weekTotal: weekTotal,
      monthTotal: monthTotal,
      avgOrderValue: avgOrderValue,
      maxY: maxY,
      top5: top5,
      productMap: productMap,
      maxProductSales: maxProductSales,
    );
  }
}

class _ChartData {
  final List<DateTime> last7Days;
  final List<double> dailyTotals;

  _ChartData({required this.last7Days, required this.dailyTotals});

  factory _ChartData.calculate(List<Sale> sales, double maxY) {
    final now = DateTime.now();
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

    return _ChartData(last7Days: last7Days, dailyTotals: dailyTotals);
  }
}

