import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/theme/theme_x.dart';
import 'package:todo_list/core/utils/responsive.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/features/tasks/cubit/tasks_cubit.dart';
import 'package:todo_list/features/tasks/cubit/tasks_state.dart';
import 'package:todo_list/features/tasks/sheets/quick_add_sheet.dart';
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

  Future<void> _toggleFromToday(BuildContext context, TaskModel task) async {
    final wasDone = task.status == TaskStatus.done.index;

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
    final t = AppLocalizations.of(context)!;
    final r = R(context);
    final ring = (r.shortest * 0.52).clamp(150.0, 210.0);

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
            final now = DateTime.now();

            final groups = buildTodayGroups(
              allTasks: state.tasks,
              exitingIds: _exiting,
              now: now,
            );

            final incomingTop = groups.incomingActive.take(3).toList();

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

                if (groups.totalForProgress == 0) ...[
                  _todayEmptyCard(context, onAdd: () => _openQuickAdd(context)),
                ] else ...[
                  _progressRing(
                    context,
                    ring: ring,
                    percent: groups.percent,
                    progress: groups.progress,
                    leftCount: groups.leftCount,
                  ),
                  SizedBox(height: r.sp(24)),
                  Text(
                    groups.leftCount == 0
                        ? t.allTasksDoneToday
                        : t.tasksLeft(groups.leftCount),
                    style: TextStyle(
                      color: context.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
                    initiallyExpanded: groups.leftCount == 0,
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

  // =============== UI widgets ===============

  Widget _progressRing(
    BuildContext context, {
    required double ring,
    required int percent,
    required double progress,
    required int leftCount,
  }) {
    final t = AppLocalizations.of(context)!;
    final r = R(context);

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: ring,
            height: ring,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(
                begin: 0,
                end: progress.clamp(0.0, 1.0).toDouble(),
              ),
              builder: (context, value, _) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 12,
                  backgroundColor: context.border,
                  valueColor: AlwaysStoppedAnimation(context.primary),
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$percent%",
                style: TextStyle(
                  color: context.text,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: r.sp(4)),
              Text(
                leftCount == 0 ? t.allDone : t.done,
                style: TextStyle(
                  color: context.textMuted,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
          onToggleDone: () => _toggleFromToday(context, task),
          onDelete: () => context.read<TasksCubit>().deleteTask(task.id),
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
