import 'package:hive_flutter/hive_flutter.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/models/sale.dart';
import 'package:zyae/models/sales_stats.dart';
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

  Product? getProduct(String id) {
    if (!_isInitialized) return null;
    return _productsBox.get(id);
  }

  List<Product> getProductsPaged({
    int offset = 0,
    int limit = 20,
    String searchQuery = '',
    String filterType = 'All',
  }) {
    if (!_isInitialized) return [];
    
    var products = _productsBox.values;

    if (searchQuery.isNotEmpty) {
      products = products.where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()));
    }

    switch (filterType) {
      case 'Low Stock':
        products = products.where((p) => p.isLowStock);
        break;
      case 'Out of Stock':
        products = products.where((p) => p.isOutOfStock);
        break;
      case 'In Stock':
        products = products.where((p) => p.isInStock);
        break;
      case 'All':
      default:
        break;
    }

    return products.skip(offset).take(limit).toList();
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

  SalesStats getSalesStats() {
    if (!_isInitialized) return const SalesStats();
    
    final statsMap = _settingsBox.get('salesStats');
    if (statsMap != null) {
      // Cast to Map<String, dynamic> safely
      try {
        // Hive might return Map<dynamic, dynamic>, need to cast
        final json = Map<String, dynamic>.from(statsMap);
        return SalesStats.fromJson(json);
      } catch (e) {
        // If schema changed or error, return default and trigger recalc?
        return const SalesStats();
      }
    }
    
    // Fallback for legacy data: try to migrate or just return empty
    // Better to return empty and let the app trigger recalculateStats() if needed
    return const SalesStats();
  }

  Future<void> recalculateStats() async {
    if (!_isInitialized) return;
    
    double totalSales = 0.0;
    int totalTransactions = 0;
    double todaysSales = 0.0;
    int todaysTransactions = 0;
    final Map<String, int> productSales = {};
    
    final today = DateTime.now();

    for (final sale in _salesBox.values) {
      totalSales += sale.total;
      totalTransactions++;

      final sameDay =
          sale.date.year == today.year &&
          sale.date.month == today.month &&
          sale.date.day == today.day;
      
      if (sameDay) {
        todaysSales += sale.total;
        todaysTransactions++;
      }

      for (final item in sale.items) {
        productSales[item.product.id] = (productSales[item.product.id] ?? 0) + item.quantity;
      }
    }

    final double averageOrderValue = totalTransactions > 0 ? totalSales / totalTransactions : 0.0;

    final stats = SalesStats(
      totalSales: totalSales,
      totalTransactions: totalTransactions,
      averageOrderValue: averageOrderValue,
      todaysSales: todaysSales,
      todaysTransactions: todaysTransactions,
      lastUpdated: DateTime.now(),
      productSales: productSales,
    );

    await _settingsBox.put('salesStats', stats.toJson());
  }

  List<Sale> getSalesPaged({int offset = 0, int limit = 20}) {
    if (!_isInitialized) return [];
    final salesList = _salesBox.values.toList();
    salesList.sort((a, b) => b.date.compareTo(a.date));
    return salesList.skip(offset).take(limit).toList();
  }

  Future<void> addSale(Sale sale) async {
    await _salesBox.add(sale);
    
    // Update cached stats
    var stats = getSalesStats();
    
    final today = DateTime.now();
    final lastUpdated = stats.lastUpdated ?? today;
    
    // Check if day changed
    final isNewDay = lastUpdated.year != today.year || 
                     lastUpdated.month != today.month || 
                     lastUpdated.day != today.day;
    
    final currentTodaysSales = isNewDay ? 0.0 : stats.todaysSales;
    final currentTodaysTransactions = isNewDay ? 0 : stats.todaysTransactions;
    
    final newProductSales = Map<String, int>.from(stats.productSales);
    for (final item in sale.items) {
      newProductSales[item.product.id] = (newProductSales[item.product.id] ?? 0) + item.quantity;
    }

    final newTotalSales = stats.totalSales + sale.total;
    final newTotalTransactions = stats.totalTransactions + 1;
    final newAverage = newTotalTransactions > 0 ? newTotalSales / newTotalTransactions : 0.0;

    stats = stats.copyWith(
      totalSales: newTotalSales,
      totalTransactions: newTotalTransactions,
      averageOrderValue: newAverage,
      todaysSales: currentTodaysSales + sale.total,
      todaysTransactions: currentTodaysTransactions + 1,
      lastUpdated: today,
      productSales: newProductSales,
    );
    
    await _settingsBox.put('salesStats', stats.toJson());
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
