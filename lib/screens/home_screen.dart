import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zyae/cubits/inventory/inventory_cubit.dart';
import 'package:zyae/cubits/sales/sales_cubit.dart';
import 'package:zyae/cubits/settings/settings_cubit.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/models/sale.dart';
import 'package:zyae/theme/app_theme.dart';
import 'package:zyae/widgets/product_list_item.dart';
import 'package:zyae/widgets/sale_list_item.dart';
import 'package:zyae/widgets/stat_card.dart';
import 'package:zyae/widgets/top_selling_card.dart';
import 'package:zyae/widgets/touchable_opacity.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final inventoryState = context.watch<InventoryCubit>().state;
    final salesState = context.watch<SalesCubit>().state;
    final settingsState = context.watch<SettingsCubit>().state;

    final stats = _HomeStatistics.calculate(
      salesState.sales,
      inventoryState.lowStockProducts,
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, settingsState.locale),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: l10n.todaysOverview),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: l10n.todaysSales,
                          value: '${NumberFormat("#,##0").format(stats.todaysSales)} MMK',
                          icon: Icons.attach_money_rounded,
                          iconColor: AppTheme.textPrimary,
                          onTap: () => context.go('/sales'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: l10n.transactions,
                          value: NumberFormat.decimalPattern().format(stats.todaysTransactions),
                          icon: Icons.receipt_long_rounded,
                          iconColor: AppTheme.textPrimary,
                          onTap: () => context.go('/sales'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _SectionTitle(title: l10n.quickActions),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildListDelegate([
                _QuickActionItem(
                  label: l10n.newSale,
                  icon: Icons.add_shopping_cart_rounded,
                  color: AppTheme.primaryColor,
                  onTap: () => context.go('/sell'),
                ),
                _QuickActionItem(
                  label: l10n.addItem,
                  icon: Icons.add_box_rounded,
                  color: AppTheme.successColor,
                  onTap: () => context.push('/edit-product'),
                ),
                _QuickActionItem(
                  label: l10n.inventory,
                  icon: Icons.inventory_2_rounded,
                  color: AppTheme.warningColor,
                  onTap: () => context.go('/inventory'),
                ),
                _QuickActionItem(
                  label: l10n.summary,
                  icon: Icons.bar_chart_rounded,
                  color: AppTheme.secondaryColor,
                  onTap: () => context.go('/sales'),
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  if (stats.topSelling.isNotEmpty) ...[
                    _SectionTitle(title: l10n.topSelling),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 190,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: stats.topSelling.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final product = stats.topSelling[index];
                          return TopSellingCard(
                            product: product,
                            soldCount: stats.productSales[product.id] ?? 0,
                            soldLabel: l10n.sold,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionTitle(title: l10n.recentSales),
                      TextButton(
                        onPressed: () => context.go('/sales'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                        ),
                        child: Text(l10n.viewAll),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (stats.recentSales.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 48, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noSalesFound,
                        style: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SaleListItem(sale: stats.recentSales[index]),
                  ),
                  childCount: stats.recentSales.length,
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  if (stats.lowStockProducts.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.warning_rounded,
                                color: AppTheme.errorColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${l10n.lowStockAlert} (${stats.lowStockProducts.length})',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.errorColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => context.go('/inventory'),
                          child: Text(l10n.viewAll),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
          if (stats.lowStockProducts.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProductListItem(
                      product: stats.lowStockProducts[index],
                    ),
                  ),
                  childCount: stats.lowStockProducts.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: TouchableOpacity(
        onTap: () => context.go('/sell'),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Locale locale) {
    final l10n = AppLocalizations.of(context)!;
    
    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) return l10n.goodMorning;
      if (hour < 17) return l10n.goodAfternoon;
      return l10n.goodEvening;
    }

    String formatDate(DateTime date) {
      return DateFormat.yMMMMd(locale.languageCode).format(date);
    }

    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.surfaceColor,
      surfaceTintColor: AppTheme.surfaceColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        centerTitle: false,
        title: Text(
          getGreeting(),
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontFamily: AppTheme.getTheme(locale).textTheme.headlineMedium?.fontFamily,
          ),
        ),
        background: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDate(DateTime.now()),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TouchableOpacity(
          onTap: () => context.push('/settings'),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.settings_outlined, color: AppTheme.textPrimary, size: 24),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Icon(icon, color: AppTheme.textPrimary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.normal,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _HomeStatistics {
  final double todaysSales;
  final int todaysTransactions;
  final List<Product> topSelling;
  final Map<String, int> productSales;
  final List<Sale> recentSales;
  final List<Product> lowStockProducts;

  _HomeStatistics({
    required this.todaysSales,
    required this.todaysTransactions,
    required this.topSelling,
    required this.productSales,
    required this.recentSales,
    required this.lowStockProducts,
  });

  factory _HomeStatistics.calculate(
    List<Sale> sales,
    List<Product> lowStockProducts,
  ) {
    final today = DateTime.now();
    double todaysSales = 0;
    var todaysTransactions = 0;
    final Map<String, int> productSales = {};
    final Map<String, Product> productMap = {};

    for (final sale in sales) {
      final sameDay =
          sale.date.year == today.year &&
          sale.date.month == today.month &&
          sale.date.day == today.day;
      if (sameDay) {
        todaysSales += sale.total;
        todaysTransactions += 1;
      }

      for (final item in sale.items) {
        final pid = item.product.id;
        productSales[pid] = (productSales[pid] ?? 0) + item.quantity;
        productMap[pid] = item.product;
      }
    }

    final sortedProductIds = productSales.keys.toList()
      ..sort((a, b) => productSales[b]!.compareTo(productSales[a]!));
    
    final topSelling = sortedProductIds
        .take(5)
        .map((id) => productMap[id]!)
        .toList();

    final recentSales = List<Sale>.from(sales)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    return _HomeStatistics(
      todaysSales: todaysSales,
      todaysTransactions: todaysTransactions,
      topSelling: topSelling,
      productSales: productSales,
      recentSales: recentSales.take(5).toList(),
      lowStockProducts: lowStockProducts,
    );
  }
}
