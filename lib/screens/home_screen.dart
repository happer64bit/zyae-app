import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zyae/cubits/inventory/inventory_cubit.dart';
import 'package:zyae/cubits/sales/sales_cubit.dart';
import 'package:zyae/cubits/settings/settings_cubit.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final inventoryState = context.watch<InventoryCubit>().state;
    final salesState = context.watch<SalesCubit>().state;
    final settingsState = context.watch<SettingsCubit>().state;

    final lowStockProducts = inventoryState.lowStockProducts;
    final today = DateTime.now();

    double todaysSales = 0;
    var todaysTransactions = 0;
    for (final sale in salesState.sales) {
      final sameDay = sale.date.year == today.year &&
          sale.date.month == today.month &&
          sale.date.day == today.day;
      if (sameDay) {
        todaysSales += sale.total;
        todaysTransactions += 1;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appTitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(today, settingsState.locale.languageCode),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      _buildSectionTitle(l10n.todaysOverview),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: l10n.todaysSales,
                      value: '${todaysSales.toStringAsFixed(0)} MMK',
                      icon: Icons.attach_money,
                      iconColor: AppTheme.successColor,
                      iconBgColor: AppTheme.successBg,
                      backgroundColor:
                          AppTheme.successBg.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: l10n.transactions,
                      value: todaysTransactions.toString(),
                      icon: Icons.shopping_bag_outlined,
                      iconColor: AppTheme.warningColor,
                      iconBgColor: AppTheme.warningBg,
                    ),
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
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SizedBox(
          height: 56,
          width: MediaQuery.of(context).size.width - 32,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
