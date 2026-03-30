import 'package:flutter/material.dart';
import '../models/deleted_todo.dart';
import '../services/storage_service.dart';

enum HistoryFilter { all, pending, completed }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final StorageService _storageService = StorageService();
  List<DeletedTodo> _deletedTodos = [];
  List<DeletedTodo> _filteredTodos = [];
  HistoryFilter _currentFilter = HistoryFilter.all;

  @override
  void initState() {
    super.initState();
    _syncAndLoadDeletedTodos();
  }

  Future<void> _syncAndLoadDeletedTodos() async {
    // Sync with backend API first
    await _storageService.syncDeletedTodos();
    
    setState(() {
      _deletedTodos = _storageService.loadDeletedTodos();
      // Sort by deletion date (newest first)
      _deletedTodos.sort((a, b) => b.deletedAt.compareTo(a.deletedAt));
      _applyFilter();
    });
  }

  void _applyFilter() {
    setState(() {
      switch (_currentFilter) {
        case HistoryFilter.all:
          _filteredTodos = List.from(_deletedTodos);
          break;
        case HistoryFilter.completed:
          _filteredTodos = _deletedTodos.where((t) => t.wasCompleted).toList();
          break;
        case HistoryFilter.pending:
          _filteredTodos = _deletedTodos.where((t) => !t.wasCompleted).toList();
          break;
      }
    });
  }

  void _setFilter(HistoryFilter filter) {
    setState(() {
      _currentFilter = filter;
      _applyFilter();
    });
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all deleted tasks?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _storageService.clearDeletedTodos();
      _syncAndLoadDeletedTodos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('History cleared'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deleted Tasks'),
        actions: [
          if (_deletedTodos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearHistory,
              tooltip: 'Clear History',
            ),
          // Filter button
          PopupMenuButton<HistoryFilter>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            initialValue: _currentFilter,
            onSelected: _setFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: HistoryFilter.all,
                child: Row(
                  children: [
                    Icon(Icons.all_inbox, size: 20),
                    SizedBox(width: 8),
                    Text('All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: HistoryFilter.completed,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 20, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Completed'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: HistoryFilter.pending,
                child: Row(
                  children: [
                    Icon(
                      Icons.radio_button_unchecked,
                      size: 20,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 8),
                    Text('Pending'),
                  ],
                ),
              ),
            ],
          ),
          // Clear history button - only show when there are deleted todos
        ],
      ),
      body: _filteredTodos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_sweep, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _getEmptyMessage(),
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
                  child: _buildDeletedTodoTile(todo),
                );
              },
            ),
    );
  }

  String _getEmptyMessage() {
    if (_deletedTodos.isEmpty) {
      return "No deleted tasks yet.";
    }
    switch (_currentFilter) {
      case HistoryFilter.all:
        return "No deleted tasks.";
      case HistoryFilter.completed:
        return "No completed deleted tasks.";
      case HistoryFilter.pending:
        return "No pending deleted tasks.";
    }
  }

  Widget _buildDeletedTodoTile(DeletedTodo todo) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          todo.title,
          style: const TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.delete, size: 14, color: Colors.red),
                const SizedBox(width: 4),
                Text(
                  'Deleted: ${_formatDateTime(todo.deletedAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ],
            ),
            if (todo.wasCompleted)
              const Text(
                'Status: Completed',
                style: TextStyle(fontSize: 12, color: Colors.green),
              ),
          ],
        ),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (todo.priority != null)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Color(todo.priorityColor),
                  shape: BoxShape.circle,
                ),
              ),
            const Icon(Icons.delete, color: Colors.grey),
          ],
        ),
        trailing: const Icon(Icons.info_outline, color: Colors.grey),
        onTap: () {
          _showDeletedTodoDetails(todo);
        },
      ),
    );
  }

  void _showDeletedTodoDetails(DeletedTodo todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                todo.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(height: 16),
              if (todo.priority != null)
                _buildInfoRow(
                  'Priority',
                  todo.priority!.name,
                  icon: Icons.flag,
                  valueColor: Color(todo.priorityColor),
                ),
              if (todo.description != null && todo.description!.isNotEmpty)
                _buildInfoRow(
                  'Description',
                  todo.description!,
                  icon: Icons.description,
                  isMultiline: true,
                ),
              if (todo.scheduledTime != null)
                _buildInfoRow(
                  'Scheduled Time',
                  _formatDateTime(todo.scheduledTime!),
                  icon: Icons.access_time,
                ),
              _buildInfoRow(
                'Status',
                todo.wasCompleted ? 'Completed' : 'Pending',
                icon: Icons.info,
                valueColor: todo.wasCompleted ? Colors.green : Colors.orange,
              ),
              _buildInfoRow(
                'Deleted At',
                _formatDateTime(todo.deletedAt),
                icon: Icons.delete,
                valueColor: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    Color? valueColor,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: valueColor ?? Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    String dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    String timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (difference.inDays == 0) {
      return 'Today, $timeStr';
    } else if (difference.inDays == 1) {
      return 'Yesterday, $timeStr';
    } else {
      return '$dateStr, $timeStr';
    }
  }
}
