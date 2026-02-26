import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:todo_list/core/sfx/sfx.dart';
import 'package:todo_list/core/theme/tag_colors.dart';
import 'package:todo_list/core/theme/theme_x.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/features/tasks/cubit/tasks_cubit.dart';
import 'package:todo_list/features/tasks/cubit/tasks_state.dart';
import 'package:todo_list/features/tasks/view/task_details_screen.dart';
import 'package:todo_list/features/tasks/widgets/animated_check.dart';
import 'package:todo_list/l10n/app_localizations.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onToggleDone;
  final VoidCallback onDelete;
  final void Function(String subTaskId)? onToggleSubTask;
  final void Function(String title)? onAddSubTask;
  final void Function(String subTaskId)? onDeleteSubTask;

  const TaskCard({
    super.key,
    this.onToggleDone,
    required this.task,
    required this.onDelete,
    this.onToggleSubTask,
    this.onAddSubTask,
    this.onDeleteSubTask,
  });

  bool get isDone {
    final subs = task.safeSubTasks;
    if (subs.isNotEmpty) {
      // task is done only if all subtasks are done
      return subs.every((s) => s.isDone);
    }
    return task.status == TaskStatus.done.index;
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
    return due.isAfter(now) && due.difference(now) <= const Duration(hours: 24);
  }

  Color priorityColor(BuildContext context) {
    final c = switch (TaskPriority.values[task.priority]) {
      TaskPriority.high => context.danger,
      TaskPriority.medium => context.warning,
      TaskPriority.low => context.success,
    };
    return isDone ? c.withAlpha((0.35 * 255).toInt()) : c;
  }

  Color dueColor(BuildContext context) {
    if (isOverdue) return context.danger;
    if (isDueSoon) return context.warning;
    return context.textMuted;
  }

  String _priorityLabel(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return switch (TaskPriority.values[task.priority]) {
      TaskPriority.low => t.priorityLow,
      TaskPriority.medium => t.priorityMedium,
      TaskPriority.high => t.priorityHigh,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final hasTags = task.tags.isNotEmpty;
    final hasDue = task.dueDateTime != null;
    final subs = task.safeSubTasks;
    final hasSubs = subs.isNotEmpty;
    final subsDone = hasSubs ? subs.where((s) => s.isDone).length : 0;

    final pColor = priorityColor(context);
    final dColor = dueColor(context);

    final cardBg = isDone
        ? context.surface
        : context.scheme.surfaceContainerHighest;

    final borderColor = isDone
        ? context.border
        : context.border.withAlpha((0.45 * 255).toInt());

    return Dismissible(
      key: ValueKey('task-${task.id}'),
      direction: DismissDirection.endToStart,
      background: const SizedBox.shrink(),
      secondaryBackground: _swipeDeleteBg(context),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onLongPress: () {
                HapticFeedback.mediumImpact();
                _openSubTasksSheet(context);
              },
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
                      color: pColor,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 16, 15, 16),
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
                                  color: pColor,
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
                                        ? context.textMuted
                                        : context.text,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationColor: context.textMuted,
                                  ),
                                  child: Text(
                                    task.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _priorityBadgeCompact(context, pColor),
                            ],
                          ),
                          if (hasSubs) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.subdirectory_arrow_right,
                                  size: 14,
                                  color: context.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$subsDone / ${subs.length} subtasks',
                                  style: TextStyle(
                                    color: context.textMuted,
                                    fontSize: 12.2,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                // optional: tiny progress bar (lightweight)
                                SizedBox(
                                  width: 90,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(99),
                                    child: LinearProgressIndicator(
                                      value: subs.isEmpty
                                          ? 0
                                          : (subsDone / subs.length),
                                      backgroundColor: context.border.withAlpha(
                                        (0.55 * 255).toInt(),
                                      ),
                                      valueColor: AlwaysStoppedAnimation(
                                        isDone ? context.success : pColor,
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          if (hasDue) ...[
                            const SizedBox(height: 10),

                            // ✅ nicer due row
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: dColor.withAlpha((0.10 * 255).toInt()),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: dColor.withAlpha((0.25 * 255).toInt()),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: dColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _formatDuePretty(
                                        context,
                                        task.dueDateTime!,
                                      ),
                                      style: TextStyle(
                                        color: dColor,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isOverdue) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      t.overdue,
                                      style: TextStyle(
                                        color: context.danger,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],

                          if (hasTags) ...[
                            const SizedBox(height: 10),
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
                                style: TextStyle(
                                  color: context.textMuted,
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

  Widget _swipeDeleteBg(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.only(right: 18),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: context.danger.withAlpha((0.22 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.delete, color: context.danger, size: 22),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final t = AppLocalizations.of(context)!;

    return (await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: context.surface,
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
                  style: TextStyle(
                    color: context.danger,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  Widget _priorityBadgeCompact(BuildContext context, Color pColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: pColor.withAlpha((0.18 * 255).toInt()),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: pColor.withAlpha((0.45 * 255).toInt())),
      ),
      child: Text(
        _priorityLabel(context),
        style: TextStyle(
          color: pColor,
          fontWeight: FontWeight.w800,
          fontSize: 10.5,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  // ✅ prettier, localized-ish formatting
  String _formatDuePretty(BuildContext context, DateTime dt) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final day = DateTime(dt.year, dt.month, dt.day);

    final time = DateFormat.jm(locale).format(dt); // 8:30 PM / ٨:٣٠ م
    if (day == today) return "${t.todayTitle} • $time";
    if (day == tomorrow) return "${t.tomorrow} • $time";

    final sameYear = dt.year == now.year;
    final date = sameYear
        ? DateFormat('EEE, d MMM', locale).format(dt)
        : DateFormat('EEE, d MMM y', locale).format(dt);

    return "$date • $time";
  }

  void _openSubTasksSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final textController = TextEditingController();
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            decoration: BoxDecoration(
              color: ctx.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ctx.border),
            ),
            child: SafeArea(
              top: false,
              child: BlocBuilder<TasksCubit, TasksState>(
                buildWhen: (prev, next) {
                  // rebuild only when this task changes (lightweight)
                  final prevTask = prev.tasks
                      .where((e) => e.id == task.id)
                      .toList();
                  final nextTask = next.tasks
                      .where((e) => e.id == task.id)
                      .toList();
                  return prevTask.isEmpty ||
                      nextTask.isEmpty ||
                      prevTask.first != nextTask.first;
                },
                builder: (context, state) {
                  final liveTask = state.tasks.cast<TaskModel?>().firstWhere(
                    (t) => t?.id == task.id,
                    orElse: () => null,
                  );

                  final subs = liveTask?.safeSubTasks ?? task.safeSubTasks;
                  final done = subs.where((s) => s.isDone).length;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              liveTask?.title ?? task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: ctx.text,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (subs.isNotEmpty)
                            Text(
                              '$done / ${subs.length}',
                              style: TextStyle(
                                color: ctx.textMuted,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          const SizedBox(width: 6),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: Icon(Icons.close, color: ctx.textMuted),
                            tooltip: "Close",
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Add subtask
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: textController,
                              style: TextStyle(
                                color: ctx.text,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: InputDecoration(
                                hintText: "Add a subtask",
                                hintStyle: TextStyle(color: ctx.textMuted),
                                filled: true,
                                fillColor: ctx.scheme.surfaceContainerHighest,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: ctx.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: ctx.primary.withAlpha(
                                      (0.70 * 255).toInt(),
                                    ),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                              onSubmitted: (_) {
                                final v = textController.text.trim();
                                if (v.isEmpty) return;
                                onAddSubTask?.call(v);
                                textController.clear();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              final v = textController.text.trim();
                              if (v.isEmpty) return;
                              onAddSubTask?.call(v);
                              textController.clear();
                            },
                            icon: Icon(Icons.add, color: ctx.primary),
                            tooltip: "Add",
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // List
                      if (subs.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Text(
                            "No subtasks yet",
                            style: TextStyle(
                              color: ctx.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 380),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: subs.length,
                            separatorBuilder: (_, __) =>
                                Divider(height: 1, color: ctx.border),
                            itemBuilder: (_, i) {
                              final s = subs[i];

                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                onTap: () async {
                                  onToggleSubTask?.call(s.id);
                                  if (!s.isDone) {
                                    HapticFeedback.selectionClick();
                                    await Sfx.check();
                                  }
                                },
                                leading: Icon(
                                  s.isDone
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: s.isDone ? ctx.success : ctx.textMuted,
                                  size: 20,
                                ),
                                title: Text(
                                  s.title,
                                  style: TextStyle(
                                    color: ctx.text,
                                    fontWeight: FontWeight.w800,
                                    decoration: s.isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () => onDeleteSubTask?.call(s.id),
                                  icon: Icon(
                                    Icons.delete,
                                    color: ctx.textMuted,
                                  ),
                                  tooltip: "Delete",
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
