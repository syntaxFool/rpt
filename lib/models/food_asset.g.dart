// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_asset.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodAssetAdapter extends TypeAdapter<FoodAsset> {
  @override
  final int typeId = 10;

  @override
  FoodAsset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodAsset(
      name: fields[0] as String,
      caloriesPer100g: fields[1] as double,
      emoji: fields[2] as String,
      proteinPer100g: fields[3] as double,
      carbsPer100g: fields[4] as double,
      fatPer100g: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, FoodAsset obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.caloriesPer100g)
      ..writeByte(2)
      ..write(obj.emoji)
      ..writeByte(3)
      ..write(obj.proteinPer100g)
      ..writeByte(4)
      ..write(obj.carbsPer100g)
      ..writeByte(5)
      ..write(obj.fatPer100g);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodAssetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
