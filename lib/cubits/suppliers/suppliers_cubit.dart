import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zyae/models/supplier.dart';
import 'package:zyae/repositories/data_repository.dart';

part 'suppliers_state.dart';

class SuppliersCubit extends Cubit<SuppliersState> {
  final DataRepository _repository;

  SuppliersCubit({required DataRepository repository})
      : _repository = repository,
        super(SuppliersInitial());

  Future<void> loadSuppliers() async {
    emit(SuppliersLoading());
    try {
      final suppliers = _repository.getSuppliers();
      emit(SuppliersLoaded(suppliers));
    } catch (e) {
      emit(SuppliersError(e.toString()));
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    try {
      await _repository.addSupplier(supplier);
      await loadSuppliers();
    } catch (e) {
      emit(SuppliersError(e.toString()));
    }
  }

  Future<void> updateSupplier(Supplier supplier) async {
    try {
      await _repository.updateSupplier(supplier);
      await loadSuppliers();
    } catch (e) {
      emit(SuppliersError(e.toString()));
    }
  }

  Future<void> deleteSupplier(String supplierId) async {
    try {
      await _repository.deleteSupplier(supplierId);
      await loadSuppliers();
    } catch (e) {
      emit(SuppliersError(e.toString()));
    }
  }
}
