import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/models/sale.dart';
import 'package:zyae/models/supplier.dart';

class AppState extends ChangeNotifier {
  static const String _productsBoxName = 'products';
  static const String _salesBoxName = 'sales';
  static const String _suppliersBoxName = 'suppliers';
  
  static const String _settingsBoxName = 'settings';
  
  late Box<Product> _productsBox;
  late Box<Sale> _salesBox;
  late Box<Supplier> _suppliersBox;
  late Box _settingsBox;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  bool get isFirstLaunch => _settingsBox.get('isFirstLaunch', defaultValue: true);

  List<Product> get products {
    if (!_isInitialized) return [];
    return _productsBox.values.toList();
  }
  
  List<Sale> get sales {
    if (!_isInitialized) return [];
    final salesList = _salesBox.values.toList();
    salesList.sort((a, b) => b.date.compareTo(a.date));
    return salesList;
  }

  List<Supplier> get suppliers {
    if (!_isInitialized) return [];
    return _suppliersBox.values.toList();
  }

  Future<void> init() async {
    if (_isInitialized) return;
    
    _productsBox = await Hive.openBox<Product>(_productsBoxName);
    _salesBox = await Hive.openBox<Sale>(_salesBoxName);
    _suppliersBox = await Hive.openBox<Supplier>(_suppliersBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
    
    if (_productsBox.isEmpty) {
      // Keep mock products for demo if first launch
      // await _productsBox.addAll(mockProducts); 
    }

    final languageCode = _settingsBox.get('languageCode');
    if (languageCode != null) {
      _locale = Locale(languageCode);
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _settingsBox.put('languageCode', locale.languageCode);
    notifyListeners();
  }

  Future<void> completeFirstLaunch() async {
    await _settingsBox.put('isFirstLaunch', false);
    notifyListeners();
  }

  Future<void> resetData() async {
    await _productsBox.clear();
    await _salesBox.clear();
    await _suppliersBox.clear();
    notifyListeners();
  }

  Future<String> exportData() async {
    // Basic JSON export implementation placeholder
    // Real implementation requires converting objects to JSON string
    return "Data export not implemented fully yet";
  }

  Future<void> importData(String jsonString) async {
    // Basic import implementation placeholder
  }

  List<Product> get lowStockProducts {
    return products
        .where((p) => p.isLowStock || p.isOutOfStock)
        .toList(growable: false);
  }

  Future<void> addProduct(Product product) async {
    await _productsBox.put(product.id, product);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    await _productsBox.put(product.id, product);
    notifyListeners();
  }

  Future<void> deleteProduct(String productId) async {
    await _productsBox.delete(productId);
    notifyListeners();
  }

  Future<void> addSupplier(Supplier supplier) async {
    await _suppliersBox.put(supplier.id, supplier);
    notifyListeners();
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await _suppliersBox.put(supplier.id, supplier);
    notifyListeners();
  }

  Future<void> deleteSupplier(String supplierId) async {
    await _suppliersBox.delete(supplierId);
    notifyListeners();
  }

  Future<void> completeSale(Map<String, int> cartQuantities) async {
    if (cartQuantities.isEmpty) {
      return;
    }

    final items = <SaleItem>[];

    for (var entry in cartQuantities.entries) {
      final productId = entry.key;
      final quantity = entry.value;

      if (quantity <= 0) continue;

      final product = _productsBox.get(productId);
      if (product == null) continue;

      final remaining =
          (product.quantity - quantity).clamp(0, double.infinity) as double;

      final updatedProduct = product.copyWith(quantity: remaining);
      await _productsBox.put(productId, updatedProduct);
      
      items.add(SaleItem(product: product, quantity: quantity));
    }

    if (items.isEmpty) {
      return;
    }

    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      items: items,
    );

    await _salesBox.add(sale);
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in context');
    return scope!.notifier!;
  }
}

