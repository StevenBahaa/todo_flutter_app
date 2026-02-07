import 'package:flutter/material.dart';
import 'package:todo_list/core/theme/app_colors.dart';
import 'package:todo_list/core/theme/tag_colors.dart';
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

  bool get isDone => task.status == TaskStatus.done.index;

  bool get isOverdue {
    final due = task.dueDateTime;

    if (due == null) return false;
    if (isDone) return false;
    return due.isBefore(DateTime.now());
  }

  bool get isDueSoon {
    final due = task.dueDateTime;
    if (due == null) return false;
    if (isDone) return false;
    final now = DateTime.now();
    return due.isAfter(now) && due.difference(now).inHours <= 24;
  }

  Color get dueColor {
    if (isOverdue) return AppColors.danger;
    if (isDueSoon) return AppColors.warning;
    return AppColors.textMuted;
  }

  String get priorityLable {
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
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: dueColor),
                        const SizedBox(width: 6),
                        Text(
                          _formatDue(task.dueDateTime!),
                          style: TextStyle(
                            color: dueColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isOverdue) ...[
                          const SizedBox(width: 8),
                          Text(
                            "OVERDUE",
                            style: TextStyle(
                              color: AppColors.danger,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ],
                    ),

                  const SizedBox(height: 6),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: task.tags.map((tag) {
                      final c = TagColors.resolve(tag);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: c.withAlpha((0.18 * 255).toInt()),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: c.withAlpha((0.45 * 255).toInt()),
                          ),
                        ),
                        child: Text(
                          "#$tag",
                          style: TextStyle(
                            color: c,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDue(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "${dt.day}/${dt.month} $h:$m";
  }

  Widget _priorityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priorityLable,
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
