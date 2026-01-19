import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:zyae/models/app_state.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/theme/app_theme.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final sales = appState.sales;
    final l10n = AppLocalizations.of(context)!;
    final formatter = DateFormat('dd MMM, hh:mm a');

    // --- Analysis Calculations ---
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = now.subtract(const Duration(days: 7));

    double todayTotal = 0;
    double weekTotal = 0;
    double monthTotal = 0;

    final Map<String, int> productSales = {};
    final Map<String, Product> productMap = {};

    for (final sale in sales) {
      // Today
      if (sale.date.isAfter(todayStart) || sale.date.isAtSameMomentAs(todayStart)) {
        todayTotal += sale.total;
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
      appBar: AppBar(
        title: Text(l10n.sales),
      ),
      body: sales.isEmpty
          ? Center(
              child: Text(
                '${l10n.noSalesYet}\n${l10n.startNewSale}',
                textAlign: TextAlign.center,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          l10n.today,
                          todayTotal,
                          Colors.blue,
                          Icons.today,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          l10n.thisWeek,
                          weekTotal,
                          Colors.orange,
                          Icons.calendar_view_week,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          l10n.thisMonth,
                          monthTotal,
                          Colors.purple,
                          Icons.calendar_month,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Weekly Chart
                  Text(
                    l10n.weeklySales,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxY,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) => Colors.blueGrey,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                rod.toY.toStringAsFixed(0),
                                const TextStyle(
                                  color: Colors.white,
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
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < last7Days.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateFormat.E().format(last7Days[index]),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(7, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: dailyTotals[index],
                                color: AppTheme.primaryColor,
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: maxY,
                                  color: Colors.grey[100],
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Top Products
                  if (top5.isNotEmpty) ...[
                    Text(
                      l10n.topSellingProducts,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: top5.map((entry) {
                          final product = productMap[entry.key]!;
                          final count = entry.value;
                          final percentage = count / maxProductSales;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    product.name,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: percentage,
                                        child: Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    '$count ${l10n.sold}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.end,
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

                  // Recent Sales
                  Text(
                    l10n.recentSales,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      // Show newest first
                      final sale = sales[sales.length - 1 - index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFEEEEEE)),
                        ),
                        child: ListTile(
                          title: Text(
                            '₹${sale.total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          subtitle: Text(
                            '${sale.totalItems} ${l10n.items} • ${formatter.format(sale.date)}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
