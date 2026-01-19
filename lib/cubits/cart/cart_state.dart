import 'package:equatable/equatable.dart';

enum CartStatus { initial, processing, success, failure }

class CartState extends Equatable {
  final Map<String, int> items;
  final CartStatus status;
  final String? errorMessage;

  const CartState({
    this.items = const {},
    this.status = CartStatus.initial,
    this.errorMessage,
  });

  CartState copyWith({
    Map<String, int>? items,
    CartStatus? status,
    String? errorMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [items, status, errorMessage];

  int get totalItems {
    var total = 0;
    items.forEach((_, quantity) {
      total += quantity;
    });
    return total;
  }
}
