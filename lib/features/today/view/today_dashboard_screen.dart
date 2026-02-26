import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_list/core/theme/theme_x.dart';
import 'package:todo_list/core/utils/responsive.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/features/tasks/cubit/tasks_cubit.dart';
import 'package:todo_list/features/tasks/cubit/tasks_state.dart';
import 'package:todo_list/features/tasks/sheets/quick_add_sheet.dart';
import 'package:todo_list/features/tasks/utils/tasks_groups.dart';
import 'package:todo_list/features/tasks/view/comprehensive_task_list_screen.dart';
import 'package:todo_list/features/tasks/widgets/task_card.dart';
import 'package:todo_list/features/today/utils/today_filters.dart';
import 'package:todo_list/features/today/widgets/today_header.dart';
import 'package:todo_list/l10n/app_localizations.dart';

class TodayDashboardScreen extends StatefulWidget {
  const TodayDashboardScreen({super.key});

  @override
  State<TodayDashboardScreen> createState() => _TodayDashboardScreenState();
}

class _TodayDashboardScreenState extends State<TodayDashboardScreen> {
  final Set<String> _exiting = {};

  bool _isTaskDoneSmart(TaskModel x) {
    final subs = x.safeSubTasks;
    if (subs.isNotEmpty) return subs.every((s) => s.isDone);
    return x.status == TaskStatus.done.index;
  }

  Future<void> _toggleFromToday(BuildContext context, TaskModel task) async {
    final wasDone = _isTaskDoneSmart(task);

    // keep your "fade out" only when moving from active -> done
    if (!wasDone) {
      setState(() => _exiting.add(task.id));
      context.read<TasksCubit>().toggleDone(task);

      await Future.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;

      setState(() => _exiting.remove(task.id));
    } else {
      context.read<TasksCubit>().toggleDone(task);
    }
  }

  void _openQuickAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => const QuickAddSheet(),
    );
  }

  void _goToAllTasks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ComprehensiveTaskListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return Scaffold(
      backgroundColor: context.bg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: context.primary,
        child: const Icon(Icons.add),
        onPressed: () => _openQuickAdd(context),
      ),
      body: SafeArea(
        child: BlocBuilder<TasksCubit, TasksState>(
          builder: (context, state) {
            final t = AppLocalizations.of(context)!;
            final now = DateTime.now();

            // ✅ build groups as you already do
            final groups = buildTodayGroups(
              allTasks: state.tasks,
              exitingIds: _exiting,
              now: now,
            );

            // ✅ CORRECT progress: always compute from the SAME list (all tasks)
            // hybrid (subtasks if exist, else task status) inside computeProgressCounts
            final counts = computeProgressCounts(state.tasks);

            final incomingTop = groups.incomingActive.take(3).toList();

            final hasOverdue = groups.todayOverdueActive.any((x) {
              final due = x.dueDateTime;
              return due != null && due.isBefore(now) && !_isTaskDoneSmart(x);
            });

            return ListView(
              padding: EdgeInsets.fromLTRB(
                r.sp(16),
                r.sp(20),
                r.sp(16),
                r.sp(120),
              ),
              children: [
                TodayHeader(now: now),
                SizedBox(height: r.sp(24)),

                // ✅ Empty vs momentum based on COUNTS (not group totals)
                if (counts.total == 0) ...[
                  _todayEmptyCard(context, onAdd: () => _openQuickAdd(context)),
                ] else ...[
                  _momentumCard(
                    context,
                    progress: counts.ratio,
                    doneCount: counts.done,
                    totalCount: counts.total,
                    leftCount: counts.left,
                    hasOverdue: hasOverdue,
                  ),
                  SizedBox(height: r.sp(24)),
                ],

                if (groups.todayOverdueActive.isNotEmpty) ...[
                  SizedBox(height: r.sp(24)),
                  _sectionTitle(
                    context,
                    t.todayTasks,
                    onSeeAll: () => _goToAllTasks(context),
                  ),
                  SizedBox(height: r.sp(8)),
                  ...groups.todayOverdueActive.map(
                    (task) => _animatedTask(context, task),
                  ),
                ],

                if (groups.completedSorted.isNotEmpty) ...[
                  SizedBox(height: r.sp(16)),
                  _completedTodaySection(
                    context,
                    groups.completedSorted,
                    initiallyExpanded: counts.left == 0,
                  ),
                ],

                if (incomingTop.isNotEmpty) ...[
                  SizedBox(height: r.sp(24)),
                  _sectionTitle(
                    context,
                    t.incoming,
                    onSeeAll: () => _goToAllTasks(context),
                  ),
                  SizedBox(height: r.sp(8)),
                  ...incomingTop.map(
                    (task) => TaskCard(
                      task: task,
                      onToggleDone: () =>
                          context.read<TasksCubit>().toggleDone(task),
                      onDelete: () =>
                          context.read<TasksCubit>().deleteTask(task.id),

                      onToggleSubTask: (subId) => context
                          .read<TasksCubit>()
                          .toggleSubTask(taskId: task.id, subTaskId: subId),

                      onAddSubTask: (title) => context
                          .read<TasksCubit>()
                          .addSubTask(taskId: task.id, title: title),

                      onDeleteSubTask: (subId) => context
                          .read<TasksCubit>()
                          .deleteSubTask(taskId: task.id, subTaskId: subId),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // ================= Momentum Card =================

  Widget _momentumCard(
    BuildContext context, {
    required double progress,
    required int doneCount,
    required int totalCount,
    required int leftCount,
    required bool hasOverdue,
  }) {
    final t = AppLocalizations.of(context)!;
    final r = R(context);

    final clamped = progress.clamp(0.0, 1.0);

    final barColor = leftCount == 0
        ? context.success
        : (hasOverdue ? context.warning : context.primary);

    final subtitle = leftCount == 0
        ? t.allTasksDoneToday
        : hasOverdue
        ? t.overdue
        : t.tasksLeft(leftCount);

    return Container(
      padding: EdgeInsets.all(r.sp(16)),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                t.todayTitle,
                style: TextStyle(
                  color: context.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: barColor.withAlpha((0.14 * 255).toInt()),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: barColor.withAlpha((0.35 * 255).toInt()),
                  ),
                ),
                child: Text(
                  "$doneCount / $totalCount",
                  style: TextStyle(
                    color: barColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: r.sp(10)),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0.0, end: clamped),
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: context.border.withAlpha(
                    (0.35 * 255).toInt(),
                  ),
                  valueColor: AlwaysStoppedAnimation(barColor),
                );
              },
            ),
          ),
          SizedBox(height: r.sp(10)),
          Text(
            subtitle,
            style: TextStyle(
              color: context.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI widgets =================

  Widget _sectionTitle(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    final t = AppLocalizations.of(context)!;

    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.text,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const Spacer(),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(t.seeAll, style: TextStyle(color: context.primary)),
          ),
      ],
    );
  }

  Widget _animatedTask(BuildContext context, TaskModel task) {
    final exiting = _exiting.contains(task.id);

    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        opacity: exiting ? 0.0 : 1.0,
        child: TaskCard(
          task: task,

          // ✅ Use the special today toggle for exit animation
          onToggleDone: () => _toggleFromToday(context, task),

          onDelete: () => context.read<TasksCubit>().deleteTask(task.id),

          onToggleSubTask: (subId) => context.read<TasksCubit>().toggleSubTask(
            taskId: task.id,
            subTaskId: subId,
          ),

          onAddSubTask: (title) => context.read<TasksCubit>().addSubTask(
            taskId: task.id,
            title: title,
          ),

          onDeleteSubTask: (subId) => context.read<TasksCubit>().deleteSubTask(
            taskId: task.id,
            subTaskId: subId,
          ),
        ),
      ),
    );
  }

  Widget _completedTodaySection(
    BuildContext context,
    List<TaskModel> done, {
    bool initiallyExpanded = false,
  }) {
    final t = AppLocalizations.of(context)!;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border),
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          collapsedIconColor: context.textMuted,
          iconColor: context.textMuted,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          title: Row(
            children: [
              Text(
                t.todayCompleted,
                style: TextStyle(
                  color: context.textMuted,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: context.primary.withAlpha((0.14 * 255).toInt()),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: context.primary.withAlpha((0.35 * 255).toInt()),
                  ),
                ),
                child: Text(
                  "${done.length}",
                  style: TextStyle(
                    color: context.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          children: done
              .map(
                (task) => Opacity(
                  opacity: 0.65,
                  child: TaskCard(
                    task: task,
                    onToggleDone: () =>
                        context.read<TasksCubit>().toggleDone(task),
                    onDelete: () =>
                        context.read<TasksCubit>().deleteTask(task.id),

                    onToggleSubTask: (subId) => context
                        .read<TasksCubit>()
                        .toggleSubTask(taskId: task.id, subTaskId: subId),

                    onAddSubTask: (title) => context
                        .read<TasksCubit>()
                        .addSubTask(taskId: task.id, title: title),

                    onDeleteSubTask: (subId) => context
                        .read<TasksCubit>()
                        .deleteSubTask(taskId: task.id, subTaskId: subId),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _todayEmptyCard(BuildContext context, {VoidCallback? onAdd}) {
    final t = AppLocalizations.of(context)!;
    final r = R(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.primary.withAlpha((0.16 * 255).toInt()),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: context.primary.withAlpha((0.35 * 255).toInt()),
              ),
            ),
            child: Icon(Icons.wb_sunny_outlined, color: context.primary),
          ),
          SizedBox(height: r.sp(12)),
          Text(
            t.nothingScheduled,
            style: TextStyle(
              color: context.text,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          SizedBox(height: r.sp(6)),
          Text(
            t.addTaskStartDay,
            style: TextStyle(
              color: context.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: r.sp(12)),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(t.addTask),
            ),
          ),
        ],
      ),
    );
  }
}
