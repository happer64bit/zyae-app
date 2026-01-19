import 'package:bloc/bloc.dart';
import 'package:zyae/cubits/inventory/inventory_state.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/models/supplier.dart';
import 'package:zyae/repositories/data_repository.dart';

class InventoryCubit extends Cubit<InventoryState> {
  final DataRepository _repository;

  InventoryCubit({required DataRepository repository})
      : _repository = repository,
        super(const InventoryState());

  Future<void> loadInventory() async {
    emit(state.copyWith(status: InventoryStatus.loading));
    try {
      final products = _repository.getProducts();
      final suppliers = _repository.getSuppliers();
      emit(state.copyWith(
        status: InventoryStatus.success,
        products: products,
        suppliers: suppliers,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _repository.addProduct(product);
      loadInventory();
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _repository.updateProduct(product);
      loadInventory();
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _repository.deleteProduct(productId);
      loadInventory();
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    try {
      await _repository.addSupplier(supplier);
      loadInventory();
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updateSupplier(Supplier supplier) async {
    try {
      await _repository.updateSupplier(supplier);
      loadInventory();
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> deleteSupplier(String supplierId) async {
    try {
      await _repository.deleteSupplier(supplierId);
      loadInventory();
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
