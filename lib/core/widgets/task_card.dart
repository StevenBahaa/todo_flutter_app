import 'package:flutter/material.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';
import '../../data/models/task_enums.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onToggleDone;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    this.onToggleDone,
    required this.task,
    required this.onDelete,
  });

  Color get priorityColor {
    final p = TaskPriority.values[task.priority];
    switch (p) {
      case TaskPriority.high:
        return Colors.red;

      case TaskPriority.medium:
        return Colors.orange;

      case TaskPriority.low:
        return Colors.green;
    }
  }

  String get PriorityLable {
    return TaskPriority.values[task.priority].name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 75,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: task.status == TaskStatus.done.index,
                        onChanged: (_) => onToggleDone?.call(),
                        activeColor: priorityColor,
                      ),
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: task.status == TaskStatus.done.index
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: Colors.white54,
                          ),
                        ),
                      ),
                      _priorityBadge(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (task.dueDateTime != null)
                    Text(
                      _formatTime(task.dueDateTime!),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),

                  const SizedBox(height: 6),

                  Wrap(
                    spacing: 6,
                    children: task.tags.map((tag) => _tagChip(tag)).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priorityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        PriorityLable,
        style: TextStyle(
          color: priorityColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _tagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "#$tag",
        style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 12),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
