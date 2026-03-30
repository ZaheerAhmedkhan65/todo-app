import '../models/todo.dart';
import '../models/deleted_todo.dart';
import 'api_service.dart';

class StorageService {
  // Singleton ApiService to maintain consistent guest ID
  static final ApiService _apiService = ApiService();

  // Local cache
  List<Todo> _localTodos = [];
  List<DeletedTodo> _localDeletedTodos = [];

  /// Get the singleton ApiService instance
  ApiService get apiService => _apiService;

  /// Sync todos from backend API
  Future<void> syncTodos() async {
    try {
      final apiTodos = await _apiService.getTodos();
      _localTodos = apiTodos.map((data) => _mapToTodo(data)).toList();
    } catch (e) {
      print('Error syncing todos: $e');
      // Fall back to local data if API fails
    }
  }

  /// Sync deleted todos from backend
  Future<void> syncDeletedTodos() async {
    try {
      final apiDeletedTodos = await _apiService.getDeletedTodos();
      _localDeletedTodos = apiDeletedTodos.map((data) => _mapToDeletedTodo(data)).toList();
    } catch (e) {
      print('Error syncing deleted todos: $e');
    }
  }

  /// Load all todos (from API if available, otherwise local)
  List<Todo> loadTodos() {
    return _localTodos;
  }

  /// Save a todo to backend API
  Future<void> saveTodo(Todo todo) async {
    try {
      if (todo.id != null && todo.id! > 0) {
        // Update existing
        await _apiService.updateTodo(todo.id!, todo.toJson());
      } else {
        // Create new
        final newTodoData = await _apiService.createTodo(todo.toJson());
        if (newTodoData != null) {
          final newTodo = _mapToTodo(newTodoData);
          // Update local list with the new todo that has an ID
          final index = _localTodos.indexWhere((t) => t.title == todo.title);
          if (index != -1) {
            _localTodos[index] = newTodo;
          }
        }
      }
    } catch (e) {
      print('Error saving todo: $e');
    }
  }

  /// Save all todos to backend
  Future<void> saveAllTodos(List<Todo> todos) async {
    // For simplicity, we sync each todo individually
    for (final todo in todos) {
      await saveTodo(todo);
    }
    _localTodos = todos;
  }

  /// Delete a todo and save to history
  Future<void> deleteTodoAndSaveHistory(Todo todo) async {
    try {
      // Delete from API (which also saves to history on backend)
      await _apiService.deleteTodo(todo.id ?? 0);
      
      // Remove from local list
      _localTodos.removeWhere((t) => t.id == todo.id || t.title == todo.title);
    } catch (e) {
      print('Error deleting todo: $e');
      // Still remove locally even if API fails
      _localTodos.removeWhere((t) => t.title == todo.title);
    }
  }

  /// Load deleted todos
  List<DeletedTodo> loadDeletedTodos() {
    return _localDeletedTodos;
  }

  /// Clear deleted todos
  Future<void> clearDeletedTodos() async {
    try {
      await _apiService.clearDeletedTodos();
      _localDeletedTodos.clear();
    } catch (e) {
      print('Error clearing deleted todos: $e');
      _localDeletedTodos.clear();
    }
  }

  /// Toggle todo completion via API
  Future<Todo?> toggleTodoCompletion(Todo todo) async {
    try {
      final updatedData = await _apiService.toggleTodo(todo.id ?? 0);
      if (updatedData != null) {
        final updatedTodo = _mapToTodo(updatedData);
        // Update local list
        final index = _localTodos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          _localTodos[index] = updatedTodo;
        }
        return updatedTodo;
      }
    } catch (e) {
      print('Error toggling todo: $e');
    }
    return null;
  }

  /// Map API response to Todo model
  Todo _mapToTodo(Map<String, dynamic> data) {
    // Map priority string to TaskPriority enum
    TaskPriority? priority;
    final priorityStr = data['priority'] as String?;
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
      title: data['title'] ?? '',
      description: data['description'],
      priority: priority,
      scheduledTime: data['scheduledTime'] != null 
          ? DateTime.parse(data['scheduledTime']) 
          : null,
      isCompleted: data['isCompleted'] ?? false,
      id: data['id'],
    );
  }

  /// Map API response to DeletedTodo model
  DeletedTodo _mapToDeletedTodo(Map<String, dynamic> data) {
    // Map priority string to DeletedTaskPriority enum
    DeletedTaskPriority? priority;
    final priorityStr = data['priority'] as String?;
    if (priorityStr != null) {
      switch (priorityStr.toLowerCase()) {
        case 'low':
          priority = DeletedTaskPriority.low;
          break;
        case 'medium':
          priority = DeletedTaskPriority.medium;
          break;
        case 'high':
          priority = DeletedTaskPriority.high;
          break;
      }
    }

    return DeletedTodo(
      title: data['title'] ?? '',
      wasCompleted: data['wasCompleted'] ?? false,
      description: data['description'],
      priority: priority,
      scheduledTime: data['scheduledTime'] != null 
          ? DateTime.parse(data['scheduledTime']) 
          : null,
      deletedAt: data['deletedAt'] != null 
          ? DateTime.parse(data['deletedAt']) 
          : DateTime.now(),
    );
  }

  /// Check if backend is available
  Future<bool> isBackendAvailable() async {
    try {
      final result = await _apiService.healthCheck();
      return result['success'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Close storage (no-op for API-based storage)
  Future<void> close() async {
    // Nothing to close for API-based storage
  }
}