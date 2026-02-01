import 'package:equatable/equatable.dart';
import 'package:zyae/models/sale.dart';
import 'package:zyae/models/sales_stats.dart';
import 'package:zyae/models/product.dart';

enum SalesStatus { initial, loading, success, failure }

class SalesState extends Equatable {
  final SalesStatus status;
  final List<Sale> sales;
  final SalesStats stats;
  final List<Product> topSellingProducts;
  final bool hasReachedMax;
  final int page;
  final String? errorMessage;

  const SalesState({
    this.status = SalesStatus.initial,
    this.sales = const [],
    this.stats = const SalesStats(),
    this.topSellingProducts = const [],
    this.hasReachedMax = false,
    this.page = 0,
    this.errorMessage,
  });

  SalesState copyWith({
    SalesStatus? status,
    List<Sale>? sales,
    SalesStats? stats,
    List<Product>? topSellingProducts,
    bool? hasReachedMax,
    int? page,
    String? errorMessage,
  }) {
    return SalesState(
      status: status ?? this.status,
      sales: sales ?? this.sales,
      stats: stats ?? this.stats,
      topSellingProducts: topSellingProducts ?? this.topSellingProducts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, sales, stats, topSellingProducts, hasReachedMax, page, errorMessage];
}
