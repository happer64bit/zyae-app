import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zyae/cubits/cart/cart_cubit.dart';
import 'package:zyae/cubits/inventory/inventory_cubit.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/screens/barcode_scanner_screen.dart';
import 'package:zyae/widgets/cart_bottom_sheet.dart';
import 'package:zyae/widgets/product_grid_item.dart';
import 'package:zyae/widgets/product_list_item.dart';

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
          SnackBar(content: Text('${product.name} ${l10n.addedToCart}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.productNotFound)),
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
    final inventoryState = context.watch<InventoryCubit>().state;
    final cartState = context.watch<CartCubit>().state;
    final allProducts = inventoryState.products;
    final products = _filteredProducts(allProducts);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Sale',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tap to add items',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _scanBarcode,
                    icon: const Icon(Icons.qr_code_scanner, size: 28),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductListItem(
                          product: product,
                          onTap: () => context.read<CartCubit>().addToCart(product),
                        );
                      },
                    );
                  } else {
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductGridItem(
                          product: product,
                          onTap: () => context.read<CartCubit>().addToCart(product),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: cartState.items.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showCartSheet(context, allProducts),
              label: Text(
                  '${_totalItems(cartState.items)} items = ${_totalAmount(cartState.items, allProducts).toStringAsFixed(0)} MMK'),
              icon: const Icon(Icons.shopping_cart),
            )
          : null,
    );
  }
}
