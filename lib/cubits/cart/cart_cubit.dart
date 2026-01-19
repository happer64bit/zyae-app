import 'package:bloc/bloc.dart';
import 'package:zyae/cubits/cart/cart_state.dart';
import 'package:zyae/cubits/inventory/inventory_cubit.dart';
import 'package:zyae/cubits/sales/sales_cubit.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/models/sale.dart';
import 'package:zyae/repositories/data_repository.dart';

class CartCubit extends Cubit<CartState> {
  final DataRepository _repository;
  final InventoryCubit _inventoryCubit;
  final SalesCubit _salesCubit;

  CartCubit({
    required DataRepository repository,
    required InventoryCubit inventoryCubit,
    required SalesCubit salesCubit,
  })  : _repository = repository,
        _inventoryCubit = inventoryCubit,
        _salesCubit = salesCubit,
        super(const CartState());

  void addToCart(Product product) {
    final newItems = Map<String, int>.from(state.items);
    newItems[product.id] = (newItems[product.id] ?? 0) + 1;
    emit(state.copyWith(items: newItems));
  }

  void removeFromCart(String productId) {
    final newItems = Map<String, int>.from(state.items);
    if (newItems.containsKey(productId)) {
      if (newItems[productId]! > 1) {
        newItems[productId] = newItems[productId]! - 1;
      } else {
        newItems.remove(productId);
      }
      emit(state.copyWith(items: newItems));
    }
  }

  void clearCart() {
    emit(state.copyWith(items: {}));
  }

  Future<void> completeSale() async {
    if (state.items.isEmpty) return;

    emit(state.copyWith(status: CartStatus.processing));

    try {
      final cartItems = Map<String, int>.from(state.items);
      final saleItems = <SaleItem>[];
      final products = _inventoryCubit.state.products;

      for (var entry in cartItems.entries) {
        final productId = entry.key;
        final quantity = entry.value;

        if (quantity <= 0) continue;

        final product = products.firstWhere(
          (p) => p.id == productId,
          orElse: () => throw Exception('Product not found: $productId'),
        );

        final remaining =
            (product.quantity - quantity).clamp(0, double.infinity) as double;

        final updatedProduct = product.copyWith(quantity: remaining);
        await _repository.updateProduct(updatedProduct);

        saleItems.add(SaleItem(product: product, quantity: quantity));
      }

      if (saleItems.isNotEmpty) {
        final sale = Sale(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          items: saleItems,
        );

        await _repository.addSale(sale);
        
        // Refresh other cubits
        await _inventoryCubit.loadInventory();
        await _salesCubit.loadSales();
        
        emit(state.copyWith(status: CartStatus.success, items: {}));
        // Reset status after success
        emit(state.copyWith(status: CartStatus.initial));
      } else {
         emit(state.copyWith(status: CartStatus.initial));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
