import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:zyae/cubits/inventory/inventory_cubit.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/theme/app_theme.dart';
import 'package:zyae/widgets/product_grid_item.dart';
import 'package:zyae/widgets/product_list_item.dart';
import 'package:zyae/widgets/touchable_opacity.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<InventoryCubit>().loadMoreProducts();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<InventoryCubit>().loadInventory(searchQuery: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = context.watch<InventoryCubit>().state;
    final l10n = AppLocalizations.of(context)!;
    final products = inventoryState.products;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.inventory,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  '${products.length} ${l10n.items}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.normal,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            TouchableOpacity(
                              onTap: () {
                                context.push('/edit-product');
                              },
                              child: const Icon(LucideIcons.circlePlus, color: AppTheme.primaryColor, size: 32),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: l10n.searchProducts,
                            hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.7)),
                            prefixIcon: const Icon(LucideIcons.search, color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.surfaceColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.primaryColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _buildFilterChip(context, 'All', l10n.all),
                            const SizedBox(width: 8),
                            _buildFilterChip(context, 'Low Stock', l10n.lowStock),
                            const SizedBox(width: 8),
                            _buildFilterChip(context, 'Out of Stock', l10n.outOfStock),
                            const SizedBox(width: 8),
                            _buildFilterChip(context, 'In Stock', l10n.inStock),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                if (constraints.maxWidth < 600)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= products.length) return const SizedBox(height: 80);
                        final product = products[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ProductListItem(
                            product: product,
                            onTap: () {
                              context.push('/edit-product', extra: product);
                            },
                          ),
                        );
                      },
                      childCount: products.length + 1, // +1 for padding/loader
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= products.length) return const SizedBox(height: 80);
                          final product = products[index];
                          return ProductGridItem(
                            product: product,
                            onTap: () {
                              context.push('/edit-product', extra: product);
                            },
                          );
                        },
                        childCount: products.length + 1,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String key, String label) {
    final selectedFilter = context.select((InventoryCubit cubit) => cubit.state.filterType);
    final isSelected = selectedFilter == key;
    return TouchableOpacity(
      onTap: () {
        context.read<InventoryCubit>().loadInventory(filterType: key);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.surfaceColor : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
