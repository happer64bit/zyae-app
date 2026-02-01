import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zyae/cubits/inventory/inventory_cubit.dart';
import 'package:zyae/cubits/sales/sales_cubit.dart';
import 'package:zyae/cubits/sales/sales_state.dart';
import 'package:zyae/cubits/settings/settings_cubit.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:zyae/theme/app_theme.dart';
import 'package:zyae/widgets/product_list_item.dart';
import 'package:zyae/widgets/sale_list_item.dart';
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

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
            context.read<SalesCubit>().loadMoreSales();
          }
          return false;
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context, settingsState.locale),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: l10n.todaysOverview),
                    const SizedBox(height: 16),
                    TouchableOpacity(
                      onTap: () => context.go('/sales'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              Color(0xFF0D47A1), // Deep Ocean Blue
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.todaysSales,
                              style: AppTheme.titleStyle.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${NumberFormat("#,##0").format(salesState.stats.todaysSales)} MMK',
                              style: AppTheme.priceStyle.copyWith(
                                color: Colors.white,
                                fontSize: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${l10n.transactions}: ${salesState.stats.todaysTransactions}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.05,
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
                  color: AppTheme.primaryColor,
                  onTap: () => context.push('/edit-product'),
                ),
                _QuickActionItem(
                  label: l10n.inventory,
                  icon: Icons.inventory_2_rounded,
                  color: AppTheme.primaryColor,
                  onTap: () => context.go('/inventory'),
                ),
                _QuickActionItem(
                  label: l10n.summary,
                  icon: Icons.bar_chart_rounded,
                  color: AppTheme.primaryColor,
                  onTap: () => context.go('/sales'),
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  if (salesState.topSellingProducts.isNotEmpty) ...[
                    _SectionTitle(title: l10n.topSelling),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 190,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: salesState.topSellingProducts.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final product = salesState.topSellingProducts[index];
                          return TopSellingCard(
                            product: product,
                            soldCount: salesState.stats.productSales[product.id] ?? 0,
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
          if (salesState.sales.isEmpty && salesState.status != SalesStatus.loading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
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
                  (context, index) {
                    if (index >= salesState.sales.length) {
                       return const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()));
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SaleListItem(sale: salesState.sales[index]),
                    );
                  },
                  childCount: salesState.sales.length + (salesState.hasReachedMax ? 0 : 1),
                ),
              ),
            ),
          if (inventoryState.lowStockProducts.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
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
                              '${l10n.lowStockAlert} (${inventoryState.lowStockProducts.length})',
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
                ),
              ),
            ),
          if (inventoryState.lowStockProducts.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ProductListItem(
                    product: inventoryState.lowStockProducts[index],
                  ),
                  childCount: inventoryState.lowStockProducts.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 64,
        width: 64,
        child: FloatingActionButton(
          onPressed: () => context.go('/sell'),
          backgroundColor: AppTheme.primaryColor,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: AppTheme.backgroundColor,
      surfaceTintColor: AppTheme.surfaceColor,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getGreeting(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Zyae POS',
            style: AppTheme.headerStyle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppTheme.textPrimary),
          onPressed: () => context.push('/settings'),
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
      style: AppTheme.headerStyle.copyWith(fontSize: 20),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: AppTheme.gapSmall),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.titleStyle.copyWith(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
