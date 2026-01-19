import 'package:flutter/material.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:zyae/models/app_state.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/screens/edit_product_screen.dart';
import 'package:zyae/theme/app_theme.dart';
import 'package:zyae/widgets/product_grid_item.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final Map<String, int> _cart = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode(AppState appState) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    if (!mounted) return;
    
    final l10n = AppLocalizations.of(context)!;

    if (result is String) {
      final product = appState.products.cast<Product?>().firstWhere(
        (p) => p?.barcode == result,
        orElse: () => null,
      );
      
      if (product != null) {
        _addToCart(product);
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

  void _addToCart(Product product) {
    setState(() {
      _cart[product.id] = (_cart[product.id] ?? 0) + 1;
    });
  }

  double _totalAmount(List<Product> allProducts) {
    var total = 0.0;
    _cart.forEach((productId, quantity) {
      final product =
          allProducts.firstWhere((p) => p.id == productId, orElse: () => allProducts.first);
      total += product.price * quantity;
    });
    return total;
  }

  int get _totalItems {
    var total = 0;
    _cart.forEach((_, quantity) {
      total += quantity;
    });
    return total;
  }

  void _showCartSheet(AppState appState, List<Product> allProducts) {
    if (_cart.isEmpty) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final entries = _cart.entries.toList();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.cart,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final product = allProducts.firstWhere(
                      (p) => p.id == entry.key,
                    );
                    final lineTotal = product.price * entry.value;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(product.name),
                      subtitle: Text(
                        '${entry.value} x ₹${product.price.toStringAsFixed(0)}',
                      ),
                      trailing: Text(
                        '₹${lineTotal.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total ($_totalItems items)',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '₹${_totalAmount(allProducts).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    appState.completeSale(_cart);
                    setState(() {
                      _cart.clear();
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.saleCompleted),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Complete Sale',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final products = appState.products;
    final filtered = _filteredProducts(products);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Sale'),
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
        actions: [
          IconButton(
            onPressed: () => _scanBarcode(appState),
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
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
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    return ProductGridItem(
                      product: product,
                      onTap: () => _addToCart(product),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_cart.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: GestureDetector(
                onTap: () => _showCartSheet(appState, products),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            const Icon(Icons.shopping_cart, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_totalItems items',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '₹${_totalAmount(products).toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Text(
                        'View Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white),
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
