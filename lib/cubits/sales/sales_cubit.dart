import 'package:bloc/bloc.dart';
import 'package:zyae/cubits/sales/sales_state.dart';
import 'package:zyae/models/sale.dart';
import 'package:zyae/repositories/data_repository.dart';

class SalesCubit extends Cubit<SalesState> {
  final DataRepository _repository;
  static const int _limit = 20;

  SalesCubit({required DataRepository repository})
      : _repository = repository,
        super(const SalesState());

  Future<void> loadSales() async {
    emit(state.copyWith(status: SalesStatus.loading));
    try {
      final allSales = _repository.getSales();
      final initialSales = allSales.take(_limit).toList();
      emit(state.copyWith(
        status: SalesStatus.success,
        sales: initialSales,
        allSalesForStats: allSales,
        hasReachedMax: initialSales.length >= allSales.length,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SalesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadMoreSales() async {
    if (state.hasReachedMax) return;

    final currentLength = state.sales.length;
    final allSales = state.allSalesForStats;
    final nextSales = allSales.skip(currentLength).take(_limit).toList();

    if (nextSales.isEmpty) {
      emit(state.copyWith(hasReachedMax: true));
    } else {
      emit(state.copyWith(
        sales: List.of(state.sales)..addAll(nextSales),
        hasReachedMax: (state.sales.length + nextSales.length) >= allSales.length,
      ));
    }
  }

  Future<void> addSale(Sale sale) async {
    try {
      await _repository.addSale(sale);
      loadSales();
    } catch (e) {
      emit(state.copyWith(
        status: SalesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
