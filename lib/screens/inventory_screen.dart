import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zyae/cubits/inventory/inventory_cubit.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/theme/app_theme.dart';
import 'package:zyae/widgets/product_grid_item.dart';
import 'package:zyae/widgets/product_list_item.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filteredProducts(List<Product> allProducts) {
    var products = allProducts;

    if (_searchController.text.isNotEmpty) {
      products = products
          .where(
            (p) => p.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()),
          )
          .toList();
    }

    switch (_selectedFilter) {
      case 'Low Stock':
        return products.where((p) => p.isLowStock).toList();
      case 'Out of Stock':
        return products.where((p) => p.isOutOfStock).toList();
      case 'In Stock':
        return products.where((p) => p.isInStock).toList();
      case 'All':
      default:
        return products;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = context.watch<InventoryCubit>().state;
    final l10n = AppLocalizations.of(context)!;
    final products = inventoryState.products;
    final filtered = _filteredProducts(products);

    return Scaffold(
      body: SafeArea(
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
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${products.length} ${l10n.items}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor, size: 32),
                    onPressed: () {
                      context.push('/edit-product');
                    },
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('All', l10n.all),
                  const SizedBox(width: 8),
                  _buildFilterChip('Low Stock', l10n.lowStock),
                  const SizedBox(width: 8),
                  _buildFilterChip('Out of Stock', l10n.outOfStock),
                  const SizedBox(width: 8),
                  _buildFilterChip('In Stock', l10n.inStock),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return ProductListItem(
                          product: product,
                          onTap: () {
                            context.push('/edit-product', extra: product);
                          },
                        );
                      },
                    );
                  } else {
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return ProductGridItem(
                          product: product,
                          onTap: () {
                            context.push('/edit-product', extra: product);
                          },
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
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = key;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight:
            isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? AppTheme.primaryColor
              : Colors.transparent,
        ),
      ),
      showCheckmark: false,
    );
  }
}
