import 'package:flutter/material.dart';
import 'package:todo_list/core/theme/app_colors.dart';
import 'package:todo_list/core/theme/tag_colors.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/features/tasks/view/task_details_screen.dart';

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
    final hasTags = task.tags.isNotEmpty;
    final hasDue = task.dueDateTime != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 31, 87, 176),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskDetailsScreen(task: task),
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(16),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row (checkbox + title + badge)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Transform.scale(
                              scale: 0.92,
                              child: Checkbox(
                                value: isDone,
                                onChanged: (_) => onToggleDone?.call(),
                                activeColor: priorityColor,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                task.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationColor: Colors.white54,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _priorityBadgeCompact(),
                          ],
                        ),

                        // Due row (only if has due)
                        if (hasDue) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: dueColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDue(task.dueDateTime!),
                                style: TextStyle(
                                  color: dueColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (isOverdue) ...[
                                const SizedBox(width: 8),
                                Text(
                                  "OVERDUE",
                                  style: TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],

                        // Tags (only if has tags)
                        if (hasTags) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: task.tags.take(3).map((tag) {
                              final c = TagColors.resolve(tag);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: c.withAlpha((0.16 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: c.withAlpha((0.40 * 255).toInt()),
                                  ),
                                ),
                                child: Text(
                                  "#$tag",
                                  style: TextStyle(
                                    color: c,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          // لو عندك tags أكتر من 3 اعرض "+N"
                          if (task.tags.length > 3) ...[
                            const SizedBox(height: 6),
                            Text(
                              "+${task.tags.length - 3} more",
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _priorityBadgeCompact() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: priorityColor.withAlpha((0.18 * 255).toInt()),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: priorityColor.withAlpha((0.45 * 255).toInt()),
        ),
      ),
      child: Text(
        priorityLable,
        style: TextStyle(
          color: priorityColor,
          fontWeight: FontWeight.w800,
          fontSize: 10.5,
          letterSpacing: 0.4,
        ),
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
