import 'package:hive/hive.dart';

part 'supplier.g.dart';

@HiveType(typeId: 3)
class Supplier {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? phoneNumber;
  @HiveField(3)
  final String? imagePath;

  const Supplier({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.imagePath,
  });

  Supplier copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? imagePath,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
