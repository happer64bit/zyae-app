import 'package:equatable/equatable.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/models/supplier.dart';

enum InventoryStatus { initial, loading, success, failure }

class InventoryState extends Equatable {
  final InventoryStatus status;
  final List<Product> products;
  final List<Supplier> suppliers;
  final String? errorMessage;

  const InventoryState({
    this.status = InventoryStatus.initial,
    this.products = const [],
    this.suppliers = const [],
    this.errorMessage,
  });

  InventoryState copyWith({
    InventoryStatus? status,
    List<Product>? products,
    List<Supplier>? suppliers,
    String? errorMessage,
  }) {
    return InventoryState(
      status: status ?? this.status,
      products: products ?? this.products,
      suppliers: suppliers ?? this.suppliers,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, products, suppliers, errorMessage];

  List<Product> get lowStockProducts {
    return products
        .where((p) => p.isLowStock || p.isOutOfStock)
        .toList(growable: false);
  }
}
