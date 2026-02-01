import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zyae/cubits/cart/cart_cubit.dart';
import 'package:zyae/cubits/cart/cart_state.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/theme/app_theme.dart';
import 'package:zyae/widgets/touchable_opacity.dart';

class CartBottomSheet extends StatelessWidget {
  final List<Product> allProducts;

  const CartBottomSheet({super.key, required this.allProducts});

  double _totalAmount(Map<String, int> cartItems) {
    var total = 0.0;
    cartItems.forEach((productId, quantity) {
      final product =
          allProducts.firstWhere((p) => p.id == productId, orElse: () => allProducts.first);
      total += product.price * quantity;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final entries = state.items.entries.toList();
        
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
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
                        '${entry.value} x ${product.price.toStringAsFixed(0)} MMK',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${lineTotal.toStringAsFixed(0)} MMK',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TouchableOpacity(
                            onTap: () {
                              context.read<CartCubit>().removeFromCart(product.id);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.remove_circle_outline, color: AppTheme.errorColor),
                            ),
                          ),
                        ],
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
                    '${l10n.total} (${state.totalItems} items)',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${_totalAmount(state.items).toStringAsFixed(0)} MMK',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TouchableOpacity(
                onTap: () {
                  context.read<CartCubit>().completeSale();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.saleCompleted),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    l10n.completeSale,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
}
