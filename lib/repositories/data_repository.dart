import 'package:hive_flutter/hive_flutter.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/models/sale.dart';
import 'package:zyae/models/supplier.dart';

class DataRepository {
  static const String _productsBoxName = 'products';
  static const String _salesBoxName = 'sales';
  static const String _suppliersBoxName = 'suppliers';
  static const String _settingsBoxName = 'settings';

  late Box<Product> _productsBox;
  late Box<Sale> _salesBox;
  late Box<Supplier> _suppliersBox;
  late Box _settingsBox;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    _productsBox = await Hive.openBox<Product>(_productsBoxName);
    _salesBox = await Hive.openBox<Sale>(_salesBoxName);
    _suppliersBox = await Hive.openBox<Supplier>(_suppliersBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);

    _isInitialized = true;
  }

  // Products
  List<Product> getProducts() {
    if (!_isInitialized) return [];
    return _productsBox.values.toList();
  }

  Future<void> addProduct(Product product) async {
    await _productsBox.put(product.id, product);
  }

  Future<void> updateProduct(Product product) async {
    await _productsBox.put(product.id, product);
  }

  Future<void> deleteProduct(String productId) async {
    await _productsBox.delete(productId);
  }

  // Suppliers
  List<Supplier> getSuppliers() {
    if (!_isInitialized) return [];
    return _suppliersBox.values.toList();
  }

  Future<void> addSupplier(Supplier supplier) async {
    await _suppliersBox.put(supplier.id, supplier);
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await _suppliersBox.put(supplier.id, supplier);
  }

  Future<void> deleteSupplier(String supplierId) async {
    await _suppliersBox.delete(supplierId);
  }

  // Sales
  List<Sale> getSales() {
    if (!_isInitialized) return [];
    final salesList = _salesBox.values.toList();
    salesList.sort((a, b) => b.date.compareTo(a.date));
    return salesList;
  }

  Future<void> addSale(Sale sale) async {
    await _salesBox.add(sale);
  }

  // Settings
  String? getLanguageCode() {
    if (!_isInitialized) return null;
    return _settingsBox.get('languageCode');
  }

  Future<void> setLanguageCode(String code) async {
    await _settingsBox.put('languageCode', code);
  }

  bool get isFirstLaunch {
    if (!_isInitialized) return true;
    return _settingsBox.get('isFirstLaunch', defaultValue: true);
  }

  Future<void> completeFirstLaunch() async {
    await _settingsBox.put('isFirstLaunch', false);
  }

  Future<void> resetData() async {
    await _productsBox.clear();
    await _salesBox.clear();
    await _suppliersBox.clear();
  }
}
