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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'imagePath': imagePath,
    };
  }

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      imagePath: json['imagePath'] as String?,
    );
  }
}
