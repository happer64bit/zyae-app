import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String unit;
  @HiveField(3)
  final double price;
  @HiveField(4)
  final double quantity;
  @HiveField(5)
  final int lowStockThreshold;
  @HiveField(6)
  final DateTime? expiryDate;
  @HiveField(7)
  final String? barcode;
  @HiveField(8)
  final String? supplierContact;
  @HiveField(9)
  final String? imagePath;

  const Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    required this.quantity,
    required this.lowStockThreshold,
    this.expiryDate,
    this.barcode,
    this.supplierContact,
    this.imagePath,
  });

  bool get isLowStock => quantity <= lowStockThreshold && quantity > 0;
  bool get isOutOfStock => quantity == 0;
  bool get isInStock => quantity > lowStockThreshold;

  Product copyWith({
    String? id,
    String? name,
    String? unit,
    double? price,
    double? quantity,
    int? lowStockThreshold,
    DateTime? expiryDate,
    String? barcode,
    String? supplierContact,
    String? imagePath,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      expiryDate: expiryDate ?? this.expiryDate,
      barcode: barcode ?? this.barcode,
      supplierContact: supplierContact ?? this.supplierContact,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'price': price,
      'quantity': quantity,
      'lowStockThreshold': lowStockThreshold,
      'expiryDate': expiryDate?.toIso8601String(),
      'barcode': barcode,
      'supplierContact': supplierContact,
      'imagePath': imagePath,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      lowStockThreshold: json['lowStockThreshold'] as int,
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate'] as String) : null,
      barcode: json['barcode'] as String?,
      supplierContact: json['supplierContact'] as String?,
      imagePath: json['imagePath'] as String?,
    );
  }
}

final List<Product> mockProducts = [
  const Product(
    id: '1',
    name: 'Sugar',
    unit: 'kg',
    price: 45,
    quantity: 3,
    lowStockThreshold: 10,
  ),
  const Product(
    id: '2',
    name: 'Wheat Flour (Atta)',
    unit: 'kg',
    price: 55,
    quantity: 0,
    lowStockThreshold: 5,
  ),
  const Product(
    id: '3',
    name: 'Toor Dal',
    unit: 'kg',
    price: 140,
    quantity: 4,
    lowStockThreshold: 5,
  ),
  const Product(
    id: '4',
    name: 'Rice (Basmati)',
    unit: 'kg',
    price: 80,
    quantity: 25,
    lowStockThreshold: 10,
  ),
  const Product(
    id: '5',
    name: 'Cooking Oil',
    unit: 'L',
    price: 180,
    quantity: 8,
    lowStockThreshold: 5,
  ),
  const Product(
    id: '6',
    name: 'Tea (Loose)',
    unit: 'kg',
    price: 350,
    quantity: 12,
    lowStockThreshold: 5,
  ),
];
