import 'package:equatable/equatable.dart';
import 'package:zyae/models/sale.dart';

enum SalesStatus { initial, loading, success, failure }

class SalesState extends Equatable {
  final SalesStatus status;
  final List<Sale> sales;
  final String? errorMessage;

  const SalesState({
    this.status = SalesStatus.initial,
    this.sales = const [],
    this.errorMessage,
  });

  SalesState copyWith({
    SalesStatus? status,
    List<Sale>? sales,
    String? errorMessage,
  }) {
    return SalesState(
      status: status ?? this.status,
      sales: sales ?? this.sales,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, sales, errorMessage];
}
