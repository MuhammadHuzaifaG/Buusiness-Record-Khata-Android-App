// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KhataTransactionAdapter extends TypeAdapter<KhataTransaction> {
  @override
  final int typeId = 2;

  @override
  KhataTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KhataTransaction(
      id: fields[0] as String,
      customerId: fields[1] as String,
      amount: fields[2] as double,
      type: fields[3] as String,
      date: fields[4] as DateTime,
      products: (fields[5] as List).cast<String>(),
      isSynced: fields[6] as bool,
      note: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, KhataTransaction obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.products)
      ..writeByte(6)
      ..write(obj.isSynced)
      ..writeByte(7)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is KhataTransactionAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}