import 'package:bloc/bloc.dart';
import 'package:zyae/cubits/sales/sales_state.dart';
import 'package:zyae/models/sale.dart';
import 'package:zyae/repositories/data_repository.dart';

class SalesCubit extends Cubit<SalesState> {
  final DataRepository _repository;

  SalesCubit({required DataRepository repository})
      : _repository = repository,
        super(const SalesState());

  Future<void> loadSales() async {
    emit(state.copyWith(status: SalesStatus.loading));
    try {
      final sales = _repository.getSales();
      emit(state.copyWith(
        status: SalesStatus.success,
        sales: sales,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SalesStatus.failure,
        errorMessage: e.toString(),
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
