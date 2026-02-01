import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zyae/cubits/cart/cart_cubit.dart';
import 'package:zyae/cubits/inventory/inventory_cubit.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/screens/barcode_scanner_screen.dart';
import 'package:zyae/theme/app_theme.dart';
import 'package:zyae/widgets/cart_bottom_sheet.dart';
import 'package:zyae/widgets/product_grid_item.dart';
import 'package:zyae/widgets/product_list_item.dart';
import 'package:zyae/widgets/touchable_opacity.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    if (!mounted) return;
    
    final l10n = AppLocalizations.of(context)!;

    if (result is String) {
      final products = context.read<InventoryCubit>().state.products;
      final product = products.cast<Product?>().firstWhere(
        (p) => p?.barcode == result,
        orElse: () => null,
      );
      
      if (product != null) {
        context.read<CartCubit>().addToCart(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} ${l10n.addedToCart}'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.productNotFound),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<Product> _filteredProducts(List<Product> allProducts) {
    if (_searchController.text.isEmpty) {
      return allProducts;
    }
    return allProducts
        .where(
          (p) => p.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()),
        )
        .toList();
  }

  double _totalAmount(Map<String, int> cartItems, List<Product> allProducts) {
    var total = 0.0;
    cartItems.forEach((productId, quantity) {
      final product =
          allProducts.firstWhere((p) => p.id == productId, orElse: () => allProducts.first);
      total += product.price * quantity;
    });
    return total;
  }

  int _totalItems(Map<String, int> cartItems) {
    var total = 0;
    cartItems.forEach((_, quantity) {
      total += quantity;
    });
    return total;
  }

  void _showCartSheet(BuildContext context, List<Product> allProducts) {
    final cartCubit = context.read<CartCubit>();
    if (cartCubit.state.items.isEmpty) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return CartBottomSheet(allProducts: allProducts);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final inventoryState = context.watch<InventoryCubit>().state;
    final cartState = context.watch<CartCubit>().state;
    final allProducts = inventoryState.products;
    final products = _filteredProducts(allProducts);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return CustomScrollView(
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
                                  l10n.newSale,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  l10n.tapToAddItems,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            TouchableOpacity(
                              onTap: _scanBarcode,
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.qr_code_scanner, size: 28, color: AppTheme.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            hintText: l10n.searchProducts,
                            hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.7)),
                            prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
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
                          onChanged: (value) => setState(() {}),
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
                        final product = products[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ProductListItem(
                            product: product,
                            onTap: () => context.read<CartCubit>().addToCart(product),
                          ),
                        );
                      },
                      childCount: products.length,
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
                          final product = products[index];
                          return ProductGridItem(
                            product: product,
                            onTap: () => context.read<CartCubit>().addToCart(product),
                          );
                        },
                        childCount: products.length,
                      ),
                    ),
                  ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: cartState.items.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TouchableOpacity(
                  onTap: () => _showCartSheet(context, allProducts),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shopping_cart, color: AppTheme.surfaceColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${_totalItems(cartState.items)} items',
                              style: const TextStyle(
                                color: AppTheme.surfaceColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${NumberFormat("#,##0").format(_totalAmount(cartState.items, allProducts))} MMK',
                          style: const TextStyle(
                            color: AppTheme.surfaceColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

