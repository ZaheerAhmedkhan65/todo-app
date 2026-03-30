import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ListTile(
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: todo.isCompleted ? Colors.grey : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: todo.scheduledTime != null
                ? Text(
                    _formatScheduledTime(todo.scheduledTime!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  )
                : null,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Priority indicator
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
                Checkbox(
                  value: todo.isCompleted,
                  onChanged: (_) => onToggle(),
                  activeColor: Colors.blueAccent,
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatScheduledTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    String timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (dateTime.isBefore(now)) {
      return '⏰ Scheduled time passed';
    } else if (difference.inDays == 0) {
      return '⏰ Today, $timeStr';
    } else if (difference.inDays == 1) {
      return '⏰ Tomorrow, $timeStr';
    } else {
      return '⏰ ${dateTime.day}/${dateTime.month} $timeStr';
    }
  }
}