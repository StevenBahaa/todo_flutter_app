import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_list/core/theme/theme_x.dart';
import 'package:todo_list/core/utils/responsive.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/features/tasks/cubit/tasks_cubit.dart';
import 'package:todo_list/features/tasks/cubit/tasks_filter.dart';
import 'package:todo_list/features/tasks/cubit/tasks_state.dart';
import 'package:todo_list/features/tasks/sheets/quick_add_sheet.dart';
import 'package:todo_list/features/tasks/utils/tasks_groups.dart';
import 'package:todo_list/features/tasks/widgets/task_card.dart';
import 'package:todo_list/features/tasks/widgets/tasks_filters_bar.dart';
import 'package:todo_list/features/tasks/widgets/tasks_section_header.dart';
import 'package:todo_list/l10n/app_localizations.dart';

class ComprehensiveTaskListScreen extends StatefulWidget {
  const ComprehensiveTaskListScreen({super.key});

  @override
  State<ComprehensiveTaskListScreen> createState() =>
      _ComprehensiveTaskListScreenState();
}

class _ComprehensiveTaskListScreenState
    extends State<ComprehensiveTaskListScreen> {
  final Set<String> _exiting = {};

  Future<void> _toggleWithExit(BuildContext context, TaskModel t) async {
    final wasDone = t.status == TaskStatus.done.index;

    if (!wasDone) {
      setState(() => _exiting.add(t.id));
      context.read<TasksCubit>().toggleDone(t);

      await Future.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;

      setState(() => _exiting.remove(t.id));
    } else {
      context.read<TasksCubit>().toggleDone(t);
    }
  }

  void _openQuickAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const QuickAddSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final r = R(context);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: Text(t.allTasksTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {}, // later
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openQuickAdd(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, state) {
          final now = DateTime.now();
          final g = buildTaskGroups(
            all: state.tasks,
            exitingIds: _exiting,
            now: now,
          );

          final padding = EdgeInsets.fromLTRB(
            r.sp(12),
            r.sp(8),
            r.sp(12),
            r.sp(110),
          );

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                padding: padding,
                children: [
                  TasksFiltersBar(
                    active: state.filter,
                    overdueCount: g.overdue.length,
                  ),
                  SizedBox(height: r.sp(12)),

                  // ===== Filter mode =====
                  if (state.filter == TasksFilter.overdue) ...[
                    _filterHeader(context, t.overdueTitle, g.overdue.length),
                    SizedBox(height: r.sp(10)),
                    if (g.overdue.isEmpty)
                      _emptyState(context, t.noOverdueTasks)
                    else
                      ..._tasksList(context, g.overdue),
                  ] else if (state.filter == TasksFilter.today) ...[
                    _filterHeader(context, t.todayTitle, g.today.length),
                    SizedBox(height: r.sp(10)),
                    if (g.today.isEmpty)
                      _emptyState(context, t.noTasksForToday)
                    else
                      ..._tasksList(context, g.today),
                  ] else if (state.filter == TasksFilter.highPriority) ...[
                    _filterHeader(
                      context,
                      t.highPriorityTitle,
                      g.highPriority.length,
                    ),
                    SizedBox(height: r.sp(10)),
                    if (g.highPriority.isEmpty)
                      _emptyState(context, t.noHighPriorityTasks)
                    else
                      ..._tasksList(context, g.highPriority),
                  ] else ...[
                    // ===== All sections =====
                    if (g.overdue.isEmpty &&
                        g.today.isEmpty &&
                        g.upcoming.isEmpty &&
                        g.noDate.isEmpty)
                      _emptyState(
                        context,
                        t.noTasksYet,
                        onAdd: () => _openQuickAdd(context),
                      ),

                    ..._section(
                      context,
                      title: t.sectionOverdueUpper,
                      tasks: g.overdue,
                      count: g.overdue.length,
                      countColor: context.danger,
                    ),
                    ..._section(
                      context,
                      title: t.sectionTodayUpper,
                      tasks: g.today,
                    ),
                    ..._section(
                      context,
                      title: t.sectionUpcomingUpper,
                      tasks: g.upcoming,
                    ),
                    ..._section(
                      context,
                      title: t.sectionNoDateUpper,
                      tasks: g.noDate,
                    ),

                    if (g.done.isNotEmpty) ...[
                      SizedBox(height: r.sp(6)),
                      _doneSummaryRow(context, g.done),
                    ],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filterHeader(BuildContext context, String title, int count) {
    final r = R(context);
    return Row(
      children: [
        Text(
          '$title${count > 0 ? " ($count)" : ""}',
          style: TextStyle(
            color: context.text,
            fontWeight: FontWeight.w800,
            fontSize: r.fs(18),
          ),
        ),
      ],
    );
  }

  List<Widget> _section(
    BuildContext context, {
    required String title,
    required List<TaskModel> tasks,
    int? count,
    Color? countColor,
  }) {
    final r = R(context);
    if (tasks.isEmpty) return [];

    return [
      TasksSectionHeader(title: title, count: count, countColor: countColor),
      SizedBox(height: r.sp(8)),
      ..._tasksList(context, tasks),
      SizedBox(height: r.sp(16)),
    ];
  }

  List<Widget> _tasksList(BuildContext context, List<TaskModel> tasks) {
    return tasks.map((x) {
      final exiting = _exiting.contains(x.id);

      return AnimatedSize(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          opacity: exiting ? 0.0 : 1.0,
          child: TaskCard(
            task: x,
            onToggleDone: () => _toggleWithExit(context, x),
            onDelete: () => context.read<TasksCubit>().deleteTask(x.id),
          ),
        ),
      );
    }).toList();
  }

  Widget _emptyState(BuildContext context, String text, {VoidCallback? onAdd}) {
    final t = AppLocalizations.of(context)!;
    final r = R(context);

    return Container(
      padding: EdgeInsets.all(r.sp(18)),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: r.sp(40),
            height: r.sp(40),
            decoration: BoxDecoration(
              color: context.primary.withAlpha((0.18 * 255).toInt()),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.primary.withAlpha((0.35 * 255).toInt()),
              ),
            ),
            child: Icon(Icons.inbox_outlined, color: context.primary),
          ),
          SizedBox(height: r.sp(12)),
          Text(
            text,
            style: TextStyle(
              color: context.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (onAdd != null) ...[
            SizedBox(height: r.sp(12)),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(t.addTask),
            ),
          ],
        ],
      ),
    );
  }

  // ===== Done summary + sheet (زي ما هو عندك، لكن responsive بسيط) =====

  Widget _doneSummaryRow(BuildContext context, List<TaskModel> doneTasks) {
    final t = AppLocalizations.of(context)!;
    final r = R(context);
    final hasDone = doneTasks.isNotEmpty;

    final countChipBg = hasDone
        ? context.primary.withAlpha((0.14 * 255).toInt())
        : context.textMuted.withAlpha((0.10 * 255).toInt());

    final countChipBorder = hasDone
        ? context.primary.withAlpha((0.35 * 255).toInt())
        : context.border;

    final countChipText = hasDone ? context.primary : context.textMuted;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: r.sp(12), vertical: r.sp(6)),
      padding: EdgeInsets.symmetric(horizontal: r.sp(14), vertical: r.sp(12)),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: hasDone ? context.success : context.textMuted,
            size: r.sp(18),
          ),
          SizedBox(width: r.sp(10)),
          Text(
            t.completedLabel,
            style: TextStyle(color: context.text, fontWeight: FontWeight.w800),
          ),
          SizedBox(width: r.sp(10)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.sp(10),
              vertical: r.sp(5),
            ),
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
                  fontSize: r.fs(12),
                ),
              ),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: hasDone
                ? () => _showDoneSheet(context, doneTasks)
                : null,
            icon: const Icon(Icons.visibility, size: 16),
            label: Text(t.view),
            style: TextButton.styleFrom(
              foregroundColor: hasDone ? context.primary : context.textMuted,
              padding: EdgeInsets.symmetric(
                horizontal: r.sp(12),
                vertical: r.sp(10),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: hasDone
                      ? context.primary.withAlpha((0.35 * 255).toInt())
                      : context.border,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDoneSheet(BuildContext context, List<TaskModel> doneTasks) {
    final t = AppLocalizations.of(context)!;
    final r = R(context);
    final sheetTasks = List<TaskModel>.of(doneTasks);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: r.sp(10)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: r.sp(10)),
                    Container(
                      width: r.sp(44),
                      height: r.sp(5),
                      decoration: BoxDecoration(
                        color: context.border,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    SizedBox(height: r.sp(14)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: r.sp(16)),
                      child: Row(
                        children: [
                          Text(
                            t.completedTodayTitle,
                            style: TextStyle(
                              color: context.text,
                              fontWeight: FontWeight.w900,
                              fontSize: r.fs(16),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${sheetTasks.length}",
                            style: TextStyle(color: context.textMuted),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: r.sp(12)),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: sheetTasks.length,
                        itemBuilder: (context, i) {
                          final task = sheetTasks[i];
                          return TaskCard(
                            task: task,
                            onToggleDone: () {
                              setState(
                                () => sheetTasks.removeWhere(
                                  (x) => x.id == task.id,
                                ),
                              );
                              context.read<TasksCubit>().toggleDone(task);
                            },
                            onDelete: () {
                              setState(
                                () => sheetTasks.removeWhere(
                                  (x) => x.id == task.id,
                                ),
                              );
                              context.read<TasksCubit>().deleteTask(task.id);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
