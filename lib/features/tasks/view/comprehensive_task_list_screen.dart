import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/task_card.dart';
import '../../../data/models/task_enums.dart';
import '../../../data/models/task_model.dart';
import '../cubit/tasks_cubit.dart';
import '../cubit/tasks_filter.dart';
import '../cubit/tasks_state.dart';
import '../sheets/quick_add_sheet.dart';

class ComprehensiveTaskListScreen extends StatefulWidget {
  const ComprehensiveTaskListScreen({super.key});

  @override
  State<ComprehensiveTaskListScreen> createState() =>
      _ComprehensiveTaskListScreenState();
}

class _ComprehensiveTaskListScreenState
    extends State<ComprehensiveTaskListScreen> {
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  final Set<String> _exiting = {};

  Future<void> _toggleWithExit(BuildContext context, TaskModel t) async {
    final wasDone = t.status == TaskStatus.done.index;

    // لو كانت Todo -> Done: اعمل خروج animation
    if (!wasDone) {
      setState(() => _exiting.add(t.id));

      context.read<TasksCubit>().toggleDone(t);

      await Future.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;

      setState(() => _exiting.remove(t.id));
    } else {
      // Done -> Todo
      context.read<TasksCubit>().toggleDone(t);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("All Tasks"),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {}, // later
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const QuickAddSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, state) {
          final now = DateTime.now();
          final today = _dateOnly(now);

          // 1) Active tasks only (مش done)
          final active = state.tasks.where((t) {
            final isDone = t.status == TaskStatus.done.index;
            return !isDone || _exiting.contains(t.id);
          }).toList();

          final doneTasks = state.tasks
              .where((t) => t.status == TaskStatus.done.index)
              .toList();

          // 2) Build lists (كل القوايم اللي هنحتاجها)
          final overdue = active
              .where(
                (t) => t.dueDateTime != null && t.dueDateTime!.isBefore(now),
              )
              .toList();

          final todayTasks = active
              .where(
                (t) =>
                    t.dueDateTime != null &&
                    _isSameDay(_dateOnly(t.dueDateTime!), today) &&
                    !t.dueDateTime!.isBefore(now),
              )
              .toList();

          final upcoming = active
              .where(
                (t) =>
                    t.dueDateTime != null &&
                    _dateOnly(t.dueDateTime!).isAfter(today),
              )
              .toList();

          final noDate = active.where((t) => t.dueDateTime == null).toList();

          final highPriority = active
              .where(
                (t) => TaskPriority.values[t.priority] == TaskPriority.high,
              )
              .toList();

          // 3) UI
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 110),
            children: [
              _filtersRow(context, state.filter, overdue.length),
              const SizedBox(height: 12),

              if (state.filter == TasksFilter.overdue) ...[
                _filterHeader(context, "Overdue", overdue.length),
                const SizedBox(height: 10),
                if (overdue.isEmpty)
                  _emptyState("No overdue tasks 🎉")
                else
                  ..._tasksList(context, overdue),
              ] else if (state.filter == TasksFilter.today) ...[
                _filterHeader(context, "Today", todayTasks.length),
                const SizedBox(height: 10),
                if (todayTasks.isEmpty)
                  _emptyState("No tasks for today")
                else
                  ..._tasksList(context, todayTasks),
              ] else if (state.filter == TasksFilter.highPriority) ...[
                _filterHeader(context, "High Priority", highPriority.length),
                const SizedBox(height: 10),
                if (highPriority.isEmpty)
                  _emptyState("No high priority tasks")
                else
                  ..._tasksList(context, highPriority),
              ] else ...[
                if (overdue.isEmpty &&
                    todayTasks.isEmpty &&
                    upcoming.isEmpty &&
                    noDate.isEmpty)
                  _emptyState(
                    "No tasks yet. Tap + to add one.",
                    onAdd: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const QuickAddSheet(),
                      );
                    },
                  ),
                ..._sectionIfNotEmpty(
                  context: context,
                  title: "OVERDUE",
                  tasks: overdue,
                  headerWithCount: true,
                ),
                ..._sectionIfNotEmpty(
                  context: context,
                  title: "TODAY",
                  tasks: todayTasks,
                ),
                ..._sectionIfNotEmpty(
                  context: context,
                  title: "UPCOMING",
                  tasks: upcoming,
                ),
                ..._sectionIfNotEmpty(
                  context: context,
                  title: "NO DATE",
                  tasks: noDate,
                ),
                if (state.filter == TasksFilter.all &&
                    doneTasks.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _doneSummaryRow(context, doneTasks),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _doneSummaryRow(BuildContext context, List<TaskModel> doneTasks) {
    final hasDone = doneTasks.isNotEmpty;

    final countChipBg = hasDone
        ? AppColors.primary.withAlpha((0.14 * 255).toInt())
        : AppColors.textMuted.withAlpha((0.10 * 255).toInt());

    final countChipBorder = hasDone
        ? AppColors.primary.withAlpha((0.35 * 255).toInt())
        : AppColors.border;

    final countChipText = hasDone ? AppColors.primary : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: hasDone ? AppColors.success : AppColors.textMuted,
            size: 18,
          ),
          const SizedBox(width: 10),

          const Text(
            "Completed",
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(width: 10),

          // Count chip (animated)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: countChipBg,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: countChipBorder),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Text(
                "${doneTasks.length}",
                key: ValueKey(doneTasks.length),
                style: TextStyle(
                  color: countChipText,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          const Spacer(),

          // View button (disabled when empty)
          TextButton.icon(
            onPressed: hasDone
                ? () => _showDoneSheet(context, doneTasks)
                : null,
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text("View"),
            style: TextButton.styleFrom(
              foregroundColor: hasDone
                  ? AppColors.primary
                  : AppColors.textMuted,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: hasDone
                      ? AppColors.primary.withAlpha((0.35 * 255).toInt())
                      : AppColors.border,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDoneSheet(BuildContext context, List<TaskModel> doneTasks) {
    final sheetTasks = List<TaskModel>.of(doneTasks);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text(
                          "Completed Today",
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${sheetTasks.length}",
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: sheetTasks.length,
                      itemBuilder: (context, i) {
                        final task = sheetTasks[i];

                        return TaskCard(
                          task: task,

                          // ✅ Toggle to UNDONE inside sheet:
                          // remove immediately from sheet + update cubit
                          onToggleDone: () {
                            setState(() {
                              sheetTasks.removeWhere((t) => t.id == task.id);
                            });

                            // This will make the task appear again in main screen lists
                            context.read<TasksCubit>().toggleDone(task);
                          },

                          // ✅ Delete inside sheet:
                          // remove immediately from sheet + delete in cubit
                          onDelete: () {
                            setState(() {
                              sheetTasks.removeWhere((t) => t.id == task.id);
                            });

                            context.read<TasksCubit>().deleteTask(task.id);
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _filterHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          '$title${count > 0 ? " ($count)" : ""}',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  // =========================
  Widget _filtersRow(
    BuildContext context,
    TasksFilter active,
    int overdueCount,
  ) {
    Widget chip(String text, TasksFilter f, {int? badgeCount}) {
      final selected = active == f;

      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: ChoiceChip(
          selected: selected,
          onSelected: (_) => context.read<TasksCubit>().setFilter(f),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text),
              if (badgeCount != null && badgeCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip("All", TasksFilter.all),
          chip("Overdue", TasksFilter.overdue, badgeCount: overdueCount),
          chip("Today", TasksFilter.today),
          chip("High Priority", TasksFilter.highPriority),
        ],
      ),
    );
  }

  /// تستخدم في وضع All: تخفي الـ section بالكامل لو فاضي
  List<Widget> _sectionIfNotEmpty({
    required BuildContext context,
    required String title,
    required List<TaskModel> tasks,
    bool headerWithCount = false,
  }) {
    if (tasks.isEmpty) return [];

    return [
      if (headerWithCount)
        _sectionHeader(title, tasks.length)
      else
        _sectionLabel(title),
      const SizedBox(height: 8),
      ..._tasksList(context, tasks),
      const SizedBox(height: 16),
    ];
  }

  /// تستخدم في وضع فلتر واحد: لو فاضي تظهر Empty state بدل section
  List<Widget> _singleView({
    required BuildContext context,
    required String title,
    required List<TaskModel> tasks,
    required String emptyText,
    bool showCountBadge = false,
  }) {
    if (tasks.isEmpty) {
      return [_emptyState(emptyText)];
    }

    return [
      if (showCountBadge)
        _sectionHeader(title, tasks.length)
      else
        _sectionLabel(title),
      const SizedBox(height: 8),
      ..._tasksList(context, tasks),
    ];
  }

  List<Widget> _tasksList(BuildContext context, List<TaskModel> tasks) {
    return tasks.map((t) {
      final exiting = _exiting.contains(t.id);

      return AnimatedSize(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          opacity: exiting ? 0.0 : 1.0,
          child: TaskCard(
            task: t,
            onToggleDone: () => _toggleWithExit(context, t),
            onDelete: () => context.read<TasksCubit>().deleteTask(t.id),
          ),
        ),
      );
    }).toList();
  }

  Widget _emptyState(String text, {VoidCallback? onAdd}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha((0.18 * 255).toInt()),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withAlpha((0.35 * 255).toInt()),
              ),
            ),
            child: const Icon(Icons.inbox_outlined, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (onAdd != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text("Add task"),
            ),
          ],
        ],
      ),
    );
  }

  // =========================
  Widget _sectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        fontSize: 12,
      ),
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Row(
      children: [
        _sectionLabel(title),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.danger.withAlpha((0.20 * 255).toInt()),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: AppColors.danger.withAlpha((0.55 * 255).toInt()),
            ),
          ),
          child: Text(
            "$count",
            style: const TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
