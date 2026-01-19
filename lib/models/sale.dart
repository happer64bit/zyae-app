import 'package:hive/hive.dart';
import 'package:zyae/models/product.dart';

part 'sale.g.dart';

@HiveType(typeId: 1)
class SaleItem {
  @HiveField(0)
  final Product product;
  @HiveField(1)
  final int quantity;

  const SaleItem({
    required this.product,
    required this.quantity,
  });

  double get total => product.price * quantity;
}

@HiveType(typeId: 2)
class Sale {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime date;
  @HiveField(2)
  final List<SaleItem> items;

  const Sale({
    required this.id,
    required this.date,
    required this.items,
  });

  double get total {
    var sum = 0.0;
    for (final item in items) {
      sum += item.total;
    }
    return sum;
  }

  int get totalItems {
    var sum = 0;
    for (final item in items) {
      sum += item.quantity;
    }
    return sum;
  }
}

