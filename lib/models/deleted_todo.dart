import 'package:hive/hive.dart';

part 'deleted_todo.g.dart';

/// Priority levels for todo tasks (mirrored for deleted todos)
enum DeletedTaskPriority {
  low,
  medium,
  high,
}

extension DeletedTaskPriorityExtension on DeletedTaskPriority {
  String get name {
    switch (this) {
      case DeletedTaskPriority.low:
        return 'Low';
      case DeletedTaskPriority.medium:
        return 'Medium';
      case DeletedTaskPriority.high:
        return 'High';
    }
  }
}

@HiveType(typeId: 1)
class DeletedTodo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool wasCompleted;

  @HiveField(2)
  String? description;

  @HiveField(3)
  int? priorityIndex;

  @HiveField(4)
  DateTime? scheduledTime;

  @HiveField(5)
  DateTime deletedAt;

  DeletedTodo({
    required this.title,
    this.wasCompleted = false,
    this.description,
    DeletedTaskPriority? priority,
    this.scheduledTime,
    required this.deletedAt,
  }) : priorityIndex = priority?.index;

  /// Get the priority as DeletedTaskPriority enum
  DeletedTaskPriority? get priority {
    if (priorityIndex == null) return null;
    return DeletedTaskPriority.values[priorityIndex!];
  }

  /// Set the priority
  set priority(DeletedTaskPriority? value) {
    priorityIndex = value?.index;
  }

  /// Create from Todo
  factory DeletedTodo.fromTodo(dynamic todo, {required DateTime deletedAt}) {
    return DeletedTodo(
      title: todo.title,
      wasCompleted: todo.isCompleted,
      description: todo.description,
      priority: todo.priority != null 
          ? DeletedTaskPriority.values[todo.priority.index] 
          : null,
      scheduledTime: todo.scheduledTime,
      deletedAt: deletedAt,
    );
  }

  /// Get priority color for UI
  int get priorityColor {
    switch (priority) {
      case DeletedTaskPriority.high:
        return 0xFFE53935;
      case DeletedTaskPriority.medium:
        return 0xFFFB8C00;
      case DeletedTaskPriority.low:
        return 0xFF43A047;
      default:
        return 0xFF757575;
    }
  }
}