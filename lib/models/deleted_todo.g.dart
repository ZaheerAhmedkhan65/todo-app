// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_todo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedTodoAdapter extends TypeAdapter<DeletedTodo> {
  @override
  final int typeId = 1;

  @override
  DeletedTodo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedTodo(
      title: fields[0] as String,
      wasCompleted: fields[1] as bool,
      description: fields[2] as String?,
      scheduledTime: fields[4] as DateTime?,
      deletedAt: fields[5] as DateTime,
    )..priorityIndex = fields[3] as int?;
  }

  @override
  void write(BinaryWriter writer, DeletedTodo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.wasCompleted)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.priorityIndex)
      ..writeByte(4)
      ..write(obj.scheduledTime)
      ..writeByte(5)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedTodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
