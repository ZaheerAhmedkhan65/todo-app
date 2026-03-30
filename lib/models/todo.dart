import 'package:hive/hive.dart';

part 'todo.g.dart';

/// Priority levels for todo tasks
enum TaskPriority {
  low,
  medium,
  high,
}

/// Extension to get display color for priority
extension TaskPriorityExtension on TaskPriority {
  String get name {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }
}

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  String? description;

  @HiveField(3)
  int? priorityIndex;

  @HiveField(4)
  DateTime? scheduledTime;

  Todo({
    required this.title,
    this.isCompleted = false,
    this.description,
    TaskPriority? priority,
    this.scheduledTime,
  }) : priorityIndex = priority?.index;

  /// Get the priority as TaskPriority enum
  TaskPriority? get priority {
    if (priorityIndex == null) return null;
    return TaskPriority.values[priorityIndex!];
  }

  /// Set the priority
  set priority(TaskPriority? value) {
    priorityIndex = value?.index;
  }

  /// Get priority color for UI
  int get priorityColor {
    switch (priority) {
      case TaskPriority.high:
        return 0xFFE53935; // Red
      case TaskPriority.medium:
        return 0xFFFB8C00; // Orange
      case TaskPriority.low:
        return 0xFF43A047; // Green
      default:
        return 0xFF757575; // Grey
    }
  }
}