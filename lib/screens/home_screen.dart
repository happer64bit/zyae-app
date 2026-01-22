import 'dart:io';
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
import 'package:zyae/widgets/product_grid_item.dart';
import 'package:zyae/widgets/product_list_item.dart';
import 'package:zyae/widgets/quick_action_button.dart';
import 'package:zyae/widgets/sale_list_item.dart';
import 'package:zyae/widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatDate(DateTime date, String locale) {
    return DateFormat.yMMMMd(locale).format(date);
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: Colors.grey, letterSpacing: 1.0),
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

    final Map<String, int> productSales = {};
    final Map<String, Product> productMap = {};

    for (final sale in salesState.sales) {
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

    final recentSales = List<Sale>.from(salesState.sales)
      ..sort((a, b) => b.date.compareTo(a.date));
    final last3Sales = recentSales.take(3).toList();

    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) return l10n.goodMorning;
      if (hour < 17) return l10n.goodAfternoon;
      return l10n.goodEvening;
    }

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLargeScreen = constraints.maxWidth > 600;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getGreeting(),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.normal,
                              ),
                        ),
                        Text(
                          _formatDate(today, settingsState.locale.languageCode),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                        _buildSectionTitle(context, l10n.todaysOverview),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: l10n.todaysSales,
                                value:
                                    '${NumberFormat("#,##0").format(todaysSales)} MMK',
                                icon: Icons.attach_money,
                                iconColor: AppTheme.successColor,
                                iconBgColor: AppTheme.successBg,
                                onTap: () => context.go('/sales'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: StatCard(
                                title: l10n.transactions,
                                value: NumberFormat.decimalPattern().format(
                                  todaysTransactions,
                                ),
                                icon: Icons.shopping_bag_outlined,
                                iconColor: AppTheme.warningColor,
                                iconBgColor: AppTheme.warningBg,
                                onTap: () => context.go('/sales'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle(context, l10n.quickActions),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 250,
                          mainAxisExtent: 120,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                    delegate: SliverChildListDelegate([
                      QuickActionButton(
                        label: l10n.newSale,
                        icon: Icons.shopping_cart_outlined,
                        onTap: () => context.go('/sell'),
                      ),
                      QuickActionButton(
                        label: l10n.addItem,
                        icon: Icons.add_circle_outline,
                        onTap: () => context.push('/edit-product'),
                      ),
                      QuickActionButton(
                        label: l10n.inventory,
                        icon: Icons.inventory_2_outlined,
                        onTap: () => context.go('/inventory'),
                      ),
                      QuickActionButton(
                        label: l10n.summary,
                        icon: Icons.bar_chart,
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
                        const SizedBox(height: 12),
                        _buildSectionTitle(context, l10n.topSelling),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 160,
                          child: topSelling.isEmpty
                              ? Center(
                                  child: Text(
                                    l10n.noSalesFound,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey[400]),
                                  ),
                                )
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: topSelling.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final product = topSelling[index];
                                    return Container(
                                      width: 120,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.grey.withValues(
                                            alpha: 0.2,
                                          ),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.03,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                image: product.imagePath != null
                                                    ? DecorationImage(
                                                        image: FileImage(
                                                          File(
                                                            product.imagePath!,
                                                          ),
                                                        ),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : null,
                                              ),
                                              child: product.imagePath == null
                                                  ? const Center(
                                                      child: Icon(
                                                        Icons.image,
                                                        color: Colors.grey,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            product.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.normal,
                                                ),
                                          ),
                                          Text(
                                            '${productSales[product.id]} ${l10n.sold}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionTitle(context, l10n.recentSales),
                            TextButton(
                              onPressed: () => context.go('/sales'),
                              child: Text(
                                l10n.viewAll,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: AppTheme.primaryColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                if (last3Sales.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          l10n.noSalesFound,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: isLargeScreen
                        ? SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 400,
                                  mainAxisExtent:
                                      100, // Approximate height of SaleListItem
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return SaleListItem(sale: last3Sales[index]);
                            }, childCount: last3Sales.length),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return SaleListItem(sale: last3Sales[index]);
                            }, childCount: last3Sales.length),
                          ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
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
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppTheme.warningColor,
                                        fontWeight: FontWeight.normal,
                                      ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => context.go('/inventory'),
                              child: Text(
                                l10n.viewAll,
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                if (lowStockProducts.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(child: Text(l10n.inStock)),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: isLargeScreen
                        ? SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => ProductGridItem(
                                product: lowStockProducts[index],
                                onTap: () => context.push(
                                  '/edit-product',
                                  extra: lowStockProducts[index],
                                ),
                              ),
                              childCount: lowStockProducts.length,
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => ProductListItem(
                                product: lowStockProducts[index],
                              ),
                              childCount: lowStockProducts.length,
                            ),
                          ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SizedBox(
          height: 56,
          width: MediaQuery.of(context).size.width - 32,
          child: ElevatedButton(
            onPressed: () => context.go('/sell'),
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
                const Icon(Icons.add_shopping_cart),
                const SizedBox(width: 8),
                Text(
                  l10n.startNewSale,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
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
