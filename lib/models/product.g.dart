// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String,
      name: fields[1] as String,
      unit: fields[2] as String,
      price: fields[3] as double,
      quantity: fields[4] as double,
      lowStockThreshold: fields[5] as int,
      expiryDate: fields[6] as DateTime?,
      barcode: fields[7] as String?,
      supplierContact: fields[8] as String?,
      imagePath: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.lowStockThreshold)
      ..writeByte(6)
      ..write(obj.expiryDate)
      ..writeByte(7)
      ..write(obj.barcode)
      ..writeByte(8)
      ..write(obj.supplierContact)
      ..writeByte(9)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
