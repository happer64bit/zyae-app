import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zyae/main.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/models/sale.dart';
import 'package:zyae/models/supplier.dart';
import 'package:zyae/repositories/data_repository.dart';

class MockDataRepository implements DataRepository {
  @override
  Future<void> init() async {}

  @override
  List<Product> getProducts() => [];

  @override
  Future<void> addProduct(Product product) async {}

  @override
  Future<void> updateProduct(Product product) async {}

  @override
  Future<void> deleteProduct(String productId) async {}

  @override
  List<Supplier> getSuppliers() => [];

  @override
  Future<void> addSupplier(Supplier supplier) async {}

  @override
  Future<void> updateSupplier(Supplier supplier) async {}

  @override
  Future<void> deleteSupplier(String supplierId) async {}

  @override
  List<Sale> getSales() => [];

  @override
  Future<void> addSale(Sale sale) async {}

  @override
  String? getLanguageCode() => 'en';

  @override
  Future<void> setLanguageCode(String code) async {}

  @override
  bool get isFirstLaunch => true;

  @override
  Future<void> completeFirstLaunch() async {}

  @override
  Future<void> resetData() async {}
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final mockRepo = MockDataRepository();
    
    await tester.pumpWidget(MyApp(dataRepository: mockRepo));
    
    // Verify that the app starts (finds the AppView or some basic widget)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
