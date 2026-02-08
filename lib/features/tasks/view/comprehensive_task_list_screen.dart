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

class ComprehensiveTaskListScreen extends StatelessWidget {
  const ComprehensiveTaskListScreen({super.key});

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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
          final active = state.tasks
              .where((t) => t.status != TaskStatus.done.index)
              .toList();

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

              // ---- FILTERED VIEWS (يعرض View واحد فقط) ----
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
                // ---- ALL VIEW (يعرض أقسام) ----

                // لو كله فاضي: Empty state واحدة
                if (overdue.isEmpty &&
                    todayTasks.isEmpty &&
                    upcoming.isEmpty &&
                    noDate.isEmpty)
                  _emptyState("No tasks yet. Tap + to add one."),

                // لو القسم مش فاضي: اعرضه
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
                  const SizedBox(height: 8),
                  _doneSection(context, doneTasks),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _doneSection(BuildContext context, List<TaskModel> doneTasks) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        collapsedIconColor: AppColors.textMuted,
        iconColor: AppColors.textMuted,
        title: Row(
          children: [
            const Text(
              "COMPLETED",
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha((0.14 * 255).toInt()),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: AppColors.primary.withAlpha((0.35 * 255).toInt()),
                ),
              ),
              child: Text(
                "${doneTasks.length}",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        children: doneTasks.map((t) {
          return Opacity(
            opacity: 0.65,
            child: TaskCard(
              task: t,
              // ✅ في done، خلي toggle يرجعها Todo
              onToggleDone: () => context.read<TasksCubit>().toggleDone(t),
              onDelete: () => context.read<TasksCubit>().deleteTask(t.id),
            ),
          );
        }).toList(),
      ),
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
        const Spacer(),
        TextButton(
          onPressed: () =>
              context.read<TasksCubit>().setFilter(TasksFilter.all),
          child: const Text("Clear"),
        ),
      ],
    );
  }

  // =========================
  // Filters UI
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withAlpha((0.18 * 255).toInt()),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: AppColors.danger.withAlpha((0.55 * 255).toInt()),
                    ),
                  ),
                  child: Text(
                    "$badgeCount",
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
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

  // =========================
  // Sections helpers
  // =========================

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
      return TaskCard(
        task: t,
        onToggleDone: () => context.read<TasksCubit>().toggleDone(t),
        onDelete: () => context.read<TasksCubit>().deleteTask(t.id),
      );
    }).toList();
  }

  Widget _emptyState(String text) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.textMuted)),
    );
  }

  // =========================
  // Section UI pieces
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
