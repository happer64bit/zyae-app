import 'package:bloc/bloc.dart';
import 'package:zyae/cubits/inventory/inventory_state.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/models/supplier.dart';
import 'package:zyae/repositories/data_repository.dart';

class InventoryCubit extends Cubit<InventoryState> {
  final DataRepository _repository;
  static const int _limit = 20;

  InventoryCubit({required DataRepository repository})
      : _repository = repository,
        super(const InventoryState());

  Future<void> loadInventory({String? searchQuery, String? filterType}) async {
    final query = searchQuery ?? state.searchQuery;
    final filter = filterType ?? state.filterType;

    emit(state.copyWith(
      status: InventoryStatus.loading,
      searchQuery: query,
      filterType: filter,
      products: [],
      hasReachedMax: false,
    ));
    try {
      final products = _repository.getProductsPaged(
        offset: 0,
        limit: _limit,
        searchQuery: query,
        filterType: filter,
      );
      final suppliers = _repository.getSuppliers();
      emit(state.copyWith(
        status: InventoryStatus.success,
        products: products,
        suppliers: suppliers,
        hasReachedMax: products.length < _limit,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadMoreProducts() async {
    if (state.hasReachedMax) return;

    try {
      final currentProducts = state.products;
      final newProducts = _repository.getProductsPaged(
        offset: currentProducts.length,
        limit: _limit,
        searchQuery: state.searchQuery,
        filterType: state.filterType,
      );

      if (newProducts.isEmpty) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        emit(state.copyWith(
          products: List.of(currentProducts)..addAll(newProducts),
          hasReachedMax: newProducts.length < _limit,
        ));
      }
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
