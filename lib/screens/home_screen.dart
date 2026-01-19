import 'package:flutter/material.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:zyae/models/app_state.dart';
import 'package:zyae/screens/inventory_screen.dart';
import 'package:zyae/screens/sales_screen.dart';
import 'package:zyae/screens/sell_screen.dart';
import 'package:zyae/theme/app_theme.dart';
import 'package:zyae/widgets/product_list_item.dart';
import 'package:zyae/widgets/quick_action_button.dart';
import 'package:zyae/widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatDate(DateTime date, String locale) {
    return DateFormat.yMMMMd(locale).format(date);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lowStockProducts = appState.lowStockProducts;
    final today = DateTime.now();

    double todaysSales = 0;
    var todaysTransactions = 0;
    for (final sale in appState.sales) {
      final sameDay = sale.date.year == today.year &&
          sale.date.month == today.month &&
          sale.date.day == today.day;
      if (sameDay) {
        todaysSales += sale.total;
        todaysTransactions += 1;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.appTitle),
            Text(
              _formatDate(today, appState.locale.languageCode),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle(l10n.todaysOverview),
              const SizedBox(height: 12),
              Row(
                children: [
                  StatCard(
                    title: l10n.todaysSales,
                    value: '\$${todaysSales.toStringAsFixed(0)}', // Use $ for generic currency or make it configurable
                    icon: Icons.attach_money,
                    iconColor: AppTheme.successColor,
                    iconBgColor: AppTheme.successBg,
                    backgroundColor:
                        AppTheme.successBg.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 16),
                  StatCard(
                    title: l10n.transactions,
                    value: todaysTransactions.toString(),
                    icon: Icons.shopping_bag_outlined,
                    iconColor: AppTheme.warningColor,
                    iconBgColor: AppTheme.warningBg,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(l10n.quickActions),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  QuickActionButton(
                    label: l10n.newSale,
                    icon: Icons.shopping_cart_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SellScreen(),
                        ),
                      );
                    },
                  ),
                  QuickActionButton(
                    label: l10n.addItem,
                    icon: Icons.add_circle_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InventoryScreen(),
                        ),
                      );
                    },
                  ),
                  QuickActionButton(
                    label: l10n.inventory,
                    icon: Icons.inventory_2_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InventoryScreen(),
                        ),
                      );
                    },
                  ),
                  QuickActionButton(
                    label: l10n.summary,
                    icon: Icons.bar_chart,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SalesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.warningColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${l10n.lowStockAlert} (${lowStockProducts.length})',
                        style: const TextStyle(
                          color: AppTheme.warningColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InventoryScreen(),
                        ),
                      );
                    },
                    child: Text(
                      l10n.viewAll,
                      style: const TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (lowStockProducts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: Text(l10n.inStock)),
                )
              else
                ...lowStockProducts
                    .map((product) => ProductListItem(product: product)),
              const SizedBox(height: 120),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SellScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add),
                    const SizedBox(width: 8),
                    Text(
                      l10n.startNewSale,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
