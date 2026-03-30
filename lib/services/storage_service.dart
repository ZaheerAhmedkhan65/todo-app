import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo.dart';
import '../models/deleted_todo.dart';

class StorageService {
  static const String _todoBoxName = 'todosBox';
  static const String _deletedBoxName = 'deletedTodosBox';

  /// Get the todos box (assumes box is already opened in main.dart)
  Box<Todo> get todoBox => Hive.box<Todo>(_todoBoxName);

  /// Get the deleted todos box
  Box<DeletedTodo> get deletedTodoBox => Hive.box<DeletedTodo>(_deletedBoxName);

  // ========== Todo Operations ==========

  /// Load all todos from Hive
  List<Todo> loadTodos() {
    return todoBox.values.toList();
  }

  /// Save a todo to Hive
  Future<void> saveTodo(Todo todo) async {
    await todoBox.put(todo.title, todo);
  }

  /// Save all todos to Hive (replaces existing data)
  Future<void> saveAllTodos(List<Todo> todos) async {
    await todoBox.clear();
    for (final todo in todos) {
      await todoBox.put(todo.title, todo);
    }
  }

  /// Delete a todo from Hive and save to history
  Future<void> deleteTodoAndSaveHistory(Todo todo) async {
    final deletedTodo = DeletedTodo.fromTodo(
      todo,
      deletedAt: DateTime.now(),
    );
    await deletedTodoBox.put(todo.title, deletedTodo);
    await todoBox.delete(todo.title);
  }

  /// Clear all todos
  Future<void> clearAllTodos() async {
    await todoBox.clear();
  }

  // ========== Deleted Todo Operations ==========

  /// Load all deleted todos from Hive
  List<DeletedTodo> loadDeletedTodos() {
    return deletedTodoBox.values.toList();
  }

  /// Clear all deleted todos
  Future<void> clearDeletedTodos() async {
    await deletedTodoBox.clear();
  }

  // ========== Close Operations ==========

  /// Close all boxes
  Future<void> close() async {
    await todoBox.close();
    await deletedTodoBox.close();
  }
}