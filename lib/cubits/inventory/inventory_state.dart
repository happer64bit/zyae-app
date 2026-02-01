import 'package:equatable/equatable.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/models/supplier.dart';

enum InventoryStatus { initial, loading, success, failure }

class InventoryState extends Equatable {
  final InventoryStatus status;
  final List<Product> products;
  final List<Supplier> suppliers;
  final String? errorMessage;
  final bool hasReachedMax;
  final String searchQuery;
  final String filterType;

  const InventoryState({
    this.status = InventoryStatus.initial,
    this.products = const [],
    this.suppliers = const [],
    this.errorMessage,
    this.hasReachedMax = false,
    this.searchQuery = '',
    this.filterType = 'All',
  });

  InventoryState copyWith({
    InventoryStatus? status,
    List<Product>? products,
    List<Supplier>? suppliers,
    String? errorMessage,
    bool? hasReachedMax,
    String? searchQuery,
    String? filterType,
  }) {
    return InventoryState(
      status: status ?? this.status,
      products: products ?? this.products,
      suppliers: suppliers ?? this.suppliers,
      errorMessage: errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: filterType ?? this.filterType,
    );
  }

  @override
  List<Object?> get props => [status, products, suppliers, errorMessage, hasReachedMax, searchQuery, filterType];

  List<Product> get lowStockProducts {
    return products
        .where((p) => p.isLowStock || p.isOutOfStock)
        .toList(growable: false);
  }
}
