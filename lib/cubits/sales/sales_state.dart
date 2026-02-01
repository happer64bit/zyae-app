import 'package:equatable/equatable.dart';
import 'package:zyae/models/sale.dart';

enum SalesStatus { initial, loading, success, failure }

class SalesState extends Equatable {
  final SalesStatus status;
  final List<Sale> sales;
  final String? errorMessage;
  final bool hasReachedMax;
  final List<Sale> allSalesForStats;

  const SalesState({
    this.status = SalesStatus.initial,
    this.sales = const [],
    this.errorMessage,
    this.hasReachedMax = false,
    this.allSalesForStats = const [],
  });

  SalesState copyWith({
    SalesStatus? status,
    List<Sale>? sales,
    String? errorMessage,
    bool? hasReachedMax,
    List<Sale>? allSalesForStats,
  }) {
    return SalesState(
      status: status ?? this.status,
      sales: sales ?? this.sales,
      errorMessage: errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      allSalesForStats: allSalesForStats ?? this.allSalesForStats,
    );
  }

  @override
  List<Object?> get props => [status, sales, errorMessage, hasReachedMax, allSalesForStats];
}
