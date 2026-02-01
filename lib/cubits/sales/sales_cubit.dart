import 'package:bloc/bloc.dart';
import 'package:zyae/cubits/sales/sales_state.dart';
import 'package:zyae/models/sale.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/repositories/data_repository.dart';

class SalesCubit extends Cubit<SalesState> {
  final DataRepository _repository;

  SalesCubit({required DataRepository repository})
      : _repository = repository,
        super(const SalesState());

  Future<void> loadSales() async {
    emit(state.copyWith(status: SalesStatus.loading));
    try {
      // Load stats first for quick dashboard update
      final stats = _repository.getSalesStats();
      
      // Calculate top selling
      final productSales = stats.productSales;
      final sortedIds = productSales.keys.toList()
        ..sort((a, b) => productSales[b]!.compareTo(productSales[a]!));
      
      final topSellingProducts = <Product>[];
      for (final id in sortedIds.take(5)) {
        final product = _repository.getProduct(id);
        if (product != null) {
          topSellingProducts.add(product);
        }
      }

      // Load first page of sales
      final sales = _repository.getSalesPaged(offset: 0, limit: 20);
      
      emit(state.copyWith(
        status: SalesStatus.success,
        sales: sales,
        stats: stats,
        topSellingProducts: topSellingProducts,
        hasReachedMax: sales.length < 20,
        page: 0,
      ));
      
      // Background check: Recalculate stats if needed (optional, maybe on startup)
    } catch (e) {
      emit(state.copyWith(
        status: SalesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadMoreSales() async {
    if (state.hasReachedMax || state.status == SalesStatus.loading) return;

    try {
      final nextPage = state.page + 1;
      final newSales = _repository.getSalesPaged(
        offset: nextPage * 20,
        limit: 20,
      );

      emit(state.copyWith(
        sales: [...state.sales, ...newSales],
        hasReachedMax: newSales.length < 20,
        page: nextPage,
      ));
    } catch (e) {
      // Keep existing sales but show error? Or just ignore?
      // For now, just log or ignore to prevent UI disruption
    }
  }

  Future<void> addSale(Sale sale) async {
    try {
      await _repository.addSale(sale);
      
      // Refresh stats
      final stats = _repository.getSalesStats();
      
      // Update top selling (simple re-fetch logic)
      final productSales = stats.productSales;
      final sortedIds = productSales.keys.toList()
        ..sort((a, b) => productSales[b]!.compareTo(productSales[a]!));
      
      final topSellingProducts = <Product>[];
      for (final id in sortedIds.take(5)) {
        final product = _repository.getProduct(id);
        if (product != null) {
          topSellingProducts.add(product);
        }
      }
      
      // Prepend new sale to list (optimistic update)
      final updatedSales = [sale, ...state.sales];
      
      emit(state.copyWith(
        sales: updatedSales,
        stats: stats,
        topSellingProducts: topSellingProducts,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SalesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
