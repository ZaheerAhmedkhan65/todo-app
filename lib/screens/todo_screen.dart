import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../widgets/todo_tile.dart';
import 'task_detail_screen.dart';
import 'history_screen.dart';

enum TaskFilter { all, pending, completed }

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Todo> _allTodos = [];
  List<Todo> _filteredTodos = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  TaskPriority? _selectedPriority;
  DateTime? _selectedDateTime;
  TaskFilter _currentFilter = TaskFilter.all;

  @override
  void initState() {
    super.initState();
    _loadTodos();
    _scheduleAllNotifications();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Load todos from storage and apply current filter
  void _loadTodos() {
    setState(() {
      _allTodos.clear();
      _allTodos.addAll(_storageService.loadTodos());
      _applyFilter();
    });
  }

  /// Apply the current filter to the todos
  void _applyFilter() {
    setState(() {
      switch (_currentFilter) {
        case TaskFilter.all:
          _filteredTodos = List.from(_allTodos);
          break;
        case TaskFilter.pending:
          _filteredTodos = _allTodos.where((todo) => !todo.isCompleted).toList();
          break;
        case TaskFilter.completed:
          _filteredTodos = _allTodos.where((todo) => todo.isCompleted).toList();
          break;
      }
    });
  }

  /// Save all todos to storage
  Future<void> _saveTodos() async {
    await _storageService.saveAllTodos(_allTodos);
  }

  /// Schedule notifications for all todos with scheduled times
  Future<void> _scheduleAllNotifications() async {
    await _notificationService.init();
    for (final todo in _allTodos) {
      if (todo.scheduledTime != null && !todo.isCompleted) {
        await _scheduleNotificationForTodo(todo);
      }
    }
  }

  /// Schedule notification for a specific todo
  Future<void> _scheduleNotificationForTodo(Todo todo) async {
    if (todo.scheduledTime != null) {
      await _notificationService.scheduleNotification(
        id: todo.title.hashCode,
        title: 'Task Reminder: ${todo.title}',
        body: todo.description != null && todo.description!.isNotEmpty
            ? todo.description!
            : 'Time to complete your task!',
        scheduledDate: todo.scheduledTime!,
        payload: todo.title,
      );
    }
  }

  /// Show add/edit todo dialog
  void _showTodoDialog({Todo? editingTodo, int? editIndex}) {
    if (editingTodo != null) {
      _titleController.text = editingTodo.title;
      _descriptionController.text = editingTodo.description ?? '';
      _selectedPriority = editingTodo.priority;
      _selectedDateTime = editingTodo.scheduledTime;
    } else {
      _titleController.clear();
      _descriptionController.clear();
      _selectedPriority = null;
      _selectedDateTime = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(editingTodo == null ? 'Add Task' : 'Edit Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        hintText: 'Enter task title',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'Enter task description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // Priority dropdown
                    DropdownButtonFormField<TaskPriority>(
                      initialValue: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority (optional)',
                      ),
                      items: TaskPriority.values
                          .map((priority) => DropdownMenuItem(
                                value: priority,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Color(priority == TaskPriority.high
                                            ? 0xFFE53935
                                            : priority == TaskPriority.medium
                                                ? 0xFFFB8C00
                                                : 0xFF43A047),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(priority.name),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          _selectedPriority = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Date/time picker
                    InkWell(
                      onTap: () async {
                        final picked = await showDateTimePicker(context);
                        if (picked != null) {
                          setDialogState(() {
                            _selectedDateTime = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Schedule Time (optional)',
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _selectedDateTime != null
                              ? _formatDateTime(_selectedDateTime!)
                              : 'Select date and time',
                          style: TextStyle(
                            color: _selectedDateTime != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isEmpty) return;

                    if (editingTodo != null && editIndex != null) {
                      // Edit existing todo
                      setState(() {
                        _allTodos[editIndex].title = _titleController.text;
                        _allTodos[editIndex].description =
                            _descriptionController.text.isEmpty
                                ? null
                                : _descriptionController.text;
                        _allTodos[editIndex].priority = _selectedPriority;
                        _allTodos[editIndex].scheduledTime = _selectedDateTime;
                      });

                      // Update notification
                      if (_selectedDateTime != null) {
                        _scheduleNotificationForTodo(_allTodos[editIndex]);
                      } else {
                        _notificationService.cancelNotification(
                            editingTodo.title.hashCode);
                      }
                    } else {
                      // Add new todo
                      final newTodo = Todo(
                        title: _titleController.text,
                        description: _descriptionController.text.isEmpty
                            ? null
                            : _descriptionController.text,
                        priority: _selectedPriority,
                        scheduledTime: _selectedDateTime,
                      );
                      setState(() {
                        _allTodos.add(newTodo);
                      });

                      // Schedule notification if time is set
                      if (_selectedDateTime != null) {
                        _scheduleNotificationForTodo(newTodo);
                      }
                    }

                    _applyFilter();
                    _saveTodos();
                    _titleController.clear();
                    _descriptionController.clear();
                    Navigator.pop(context);
                  },
                  child: Text(editingTodo == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Show date time picker
  Future<DateTime?> showDateTimePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1),
      );

      if (time != null) {
        return DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      }
    }
    return null;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    String dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    String timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (dateTime.isBefore(now)) {
      return '$dateStr $timeStr (passed)';
    } else if (difference.inDays == 0) {
      return 'Today, $timeStr';
    } else if (difference.inDays == 1) {
      return 'Tomorrow, $timeStr';
    } else {
      return '$dateStr, $timeStr';
    }
  }

  /// Toggle todo completion status
  void _toggleTodo(int index) {
    final todo = _filteredTodos[index];
    todo.isCompleted = !todo.isCompleted;
    _applyFilter();
    _saveTodos();

    // Cancel notification if task is completed
    if (todo.isCompleted) {
      _notificationService.cancelNotification(todo.title.hashCode);
    } else if (todo.scheduledTime != null) {
      // Re-schedule if task is uncompleted
      _scheduleNotificationForTodo(todo);
    }
  }

  /// Delete a todo
  void _deleteTodo(int index) {
    final todo = _filteredTodos[index];
    
    // Save to history before deleting
    _storageService.deleteTodoAndSaveHistory(todo);
    
    // Cancel notification
    _notificationService.cancelNotification(todo.title.hashCode);

    setState(() {
      _allTodos.removeWhere((t) => t.title == todo.title);
      _applyFilter();
    });
    _saveTodos();
  }

  /// Edit a todo
  void _editTodo(int index) {
    final todo = _filteredTodos[index];
    final originalIndex = _allTodos.indexOf(todo);
    _showTodoDialog(editingTodo: todo, editIndex: originalIndex);
  }

  /// Show add todo dialog
  void _showAddTodoDialog() {
    _showTodoDialog();
  }

  /// Navigate to history screen
  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  /// Set filter
  void _setFilter(TaskFilter filter) {
    setState(() {
      _currentFilter = filter;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _navigateToHistory,
            tooltip: 'Deleted Tasks',
          ),
          PopupMenuButton<TaskFilter>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            initialValue: _currentFilter,
            onSelected: _setFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TaskFilter.all,
                child: Row(
                  children: [
                    Icon(Icons.all_inbox, size: 20),
                    SizedBox(width: 8),
                    Text('All Tasks'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: TaskFilter.pending,
                child: Row(
                  children: [
                    Icon(Icons.radio_button_unchecked, size: 20, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Pending'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: TaskFilter.completed,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 20, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Completed'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _filteredTodos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _currentFilter == TaskFilter.all
                        ? Icons.inbox
                        : _currentFilter == TaskFilter.pending
                            ? Icons.radio_button_unchecked
                            : Icons.check_circle,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentFilter == TaskFilter.all
                        ? "No tasks yet. Add your first task!"
                        : _currentFilter == TaskFilter.pending
                            ? "No pending tasks!"
                            : "No completed tasks yet!",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _filteredTodos.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final todo = _filteredTodos[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: TodoTile(
                    todo: todo,
                    onToggle: () => _toggleTodo(index),
                    onEdit: () => _editTodo(index),
                    onDelete: () => _deleteTodo(index),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailScreen(
                            todo: todo,
                            onEdit: () {
                              Navigator.pop(context);
                              _editTodo(index);
                            },
                            onDelete: () {
                              Navigator.pop(context);
                              _deleteTodo(index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}