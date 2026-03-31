import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
enum TaskPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

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

  @HiveField(5)
  int? id;

  @HiveField(6)
  DateTime? completedAt;

  Todo({
    required this.title,
    this.isCompleted = false,
    this.description,
    TaskPriority? priority,
    this.scheduledTime,
    this.id,
    this.completedAt,
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
        return 0xFFE53935;
      case TaskPriority.medium:
        return 0xFFFB8C00;
      case TaskPriority.low:
        return 0xFF43A047;
      default:
        return 0xFF757575;
    }
  }

  /// Create a copy of this todo with updated fields
  Todo copyWith({
    String? title,
    bool? isCompleted,
    String? description,
    TaskPriority? priority,
    DateTime? scheduledTime,
    int? id,
    DateTime? completedAt,
  }) {
    return Todo(
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      id: id ?? this.id,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'priority': priority?.name.toLowerCase() ?? 'medium',
      'isCompleted': isCompleted,
      if (scheduledTime != null)
        'scheduledTime': scheduledTime!.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Todo.fromJson(Map<String, dynamic> json) {
    TaskPriority? priority;
    final priorityStr = json['priority'] as String?;
    if (priorityStr != null) {
      switch (priorityStr.toLowerCase()) {
        case 'low':
          priority = TaskPriority.low;
          break;
        case 'medium':
          priority = TaskPriority.medium;
          break;
        case 'high':
          priority = TaskPriority.high;
          break;
      }
    }

    return Todo(
      title: json['title'] ?? '',
      description: json['description'],
      priority: priority,
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'])
          : null,
      isCompleted: json['isCompleted'] is bool 
          ? json['isCompleted'] 
          : (json['isCompleted'] == 1 || json['isCompleted'] == true),
      id: json['id'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}