// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyNoteAdapter extends TypeAdapter<DailyNote> {
  @override
  final int typeId = 15;

  @override
  DailyNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyNote(
      date: fields[0] as String,
      note: fields[1] as String,
      lastModified: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyNote obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.note)
      ..writeByte(2)
      ..write(obj.lastModified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
