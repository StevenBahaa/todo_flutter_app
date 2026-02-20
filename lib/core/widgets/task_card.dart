import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:todo_list/core/sfx/sfx.dart';
import 'package:todo_list/core/theme/app_colors.dart';
import 'package:todo_list/core/theme/tag_colors.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/features/tasks/view/task_details_screen.dart';
import 'package:todo_list/features/tasks/widgets/animated_check.dart';

// ✅ Your generated localization import (as you confirmed)
import 'package:todo_list/l10n/app_localizations.dart';

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

  bool get isDone => task.status == TaskStatus.done.index;

  Color get priorityColor {
    final p = TaskPriority.values[task.priority];
    Color c = switch (p) {
      TaskPriority.high => AppColors.danger,
      TaskPriority.medium => AppColors.warning,
      TaskPriority.low => AppColors.success,
    };
    if (isDone) return c.withAlpha((0.35 * 255).toInt());
    return c;
  }

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

  String _priorityLabel(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final p = TaskPriority.values[task.priority];

    switch (p) {
      case TaskPriority.low:
        return t.priorityLow;
      case TaskPriority.medium:
        return t.priorityMedium;
      case TaskPriority.high:
        return t.priorityHigh;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    debugPrint('TaskCard locale: $locale');
    final t = AppLocalizations.of(context)!;

    final hasTags = task.tags.isNotEmpty;
    final hasDue = task.dueDateTime != null;

    return Dismissible(
      key: ValueKey('task-${task.id}'),
      direction: DismissDirection.endToStart,
      background: const SizedBox.shrink(),
      secondaryBackground: _swipeDeleteBg(),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDone ? AppColors.surface : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone ? AppColors.border : Colors.transparent,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: isDone ? AppColors.surface : const Color(0xFF1E293B),
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
                      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Transform.scale(
                                scale: 0.92,
                                child: AnimatedCheck(
                                  checked: isDone,
                                  color: priorityColor,
                                  onTap: () async {
                                    HapticFeedback.selectionClick();
                                    final wasDone = isDone;
                                    onToggleDone?.call();
                                    if (!wasDone) await Sfx.check();
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeOut,
                                  style: TextStyle(
                                    color: isDone
                                        ? AppColors.textMuted
                                        : AppColors.text,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationColor: AppColors.textMuted,
                                  ),
                                  child: Text(
                                    task.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // ✅ pass context here
                              _priorityBadgeCompact(context),
                            ],
                          ),

                          const SizedBox(height: 8),

                          if (hasDue) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: dueColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatDue(context, task.dueDateTime!),
                                  style: TextStyle(
                                    color: dueColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (isOverdue) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    t.overdue,
                                    style: const TextStyle(
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

                          if (hasTags) ...[
                            const SizedBox(height: 8),
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
                            if (task.tags.length > 3) ...[
                              const SizedBox(height: 6),
                              Text(
                                t.moreCount(task.tags.length - 3),
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
      ),
    );
  }

  Widget _swipeDeleteBg() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.only(right: 18),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: AppColors.danger.withAlpha((0.22 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete, color: AppColors.danger, size: 22),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final t = AppLocalizations.of(context)!;

    return (await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(t.deleteTaskTitle),
            content: Text(t.deleteTaskBody(task.title)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(t.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  t.delete,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  Widget _priorityBadgeCompact(BuildContext context) {
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
        _priorityLabel(context),
        style: TextStyle(
          color: priorityColor,
          fontWeight: FontWeight.w800,
          fontSize: 10.5,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  String _formatDue(BuildContext context, DateTime dt) {
    final locale = Localizations.localeOf(context).languageCode;
    final date = DateFormat('d/M', locale).format(dt);
    final time = DateFormat('HH:mm', locale).format(dt);
    return '$date  $time';
  }
}
