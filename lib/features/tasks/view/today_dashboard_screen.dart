import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/data/models/task_model.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/task_card.dart';
import '../../../data/models/task_enums.dart';
import '../cubit/tasks_cubit.dart';
import '../cubit/tasks_state.dart';
import '../sheets/quick_add_sheet.dart';
import 'comprehensive_task_list_screen.dart';

class TodayDashboardScreen extends StatefulWidget {
  const TodayDashboardScreen({super.key});

  @override
  State<TodayDashboardScreen> createState() => _TodayDashboardScreenState();
}

class _TodayDashboardScreenState extends State<TodayDashboardScreen> {
  final Set<String> _exiting = {};

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _toggleFromToday(BuildContext context, TaskModel t) async {
    final wasDone = t.status == TaskStatus.done.index;

    // Play exit animation only when going Todo -> Done
    if (!wasDone) {
      setState(() => _exiting.add(t.id));

      context.read<TasksCubit>().toggleDone(t);

      await Future.delayed(const Duration(milliseconds: 320));

      if (!mounted) return;
      setState(() => _exiting.remove(t.id));
    } else {
      // Done -> Todo (no exit animation)
      context.read<TasksCubit>().toggleDone(t);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const QuickAddSheet(),
          );
        },
      ),
      body: SafeArea(
        child: BlocBuilder<TasksCubit, TasksState>(
          builder: (context, state) {
            final now = DateTime.now();
            final today = _dateOnly(now);

            // ----------------------------
            // TODAY tasks (all: done + todo)
            // ----------------------------
            final todayTasks = state.tasks.where((t) {
              if (t.dueDateTime == null) return false;
              return _isSameDay(_dateOnly(t.dueDateTime!), today);
            }).toList();

            final todayDone = todayTasks
                .where((t) => t.status == TaskStatus.done.index)
                .toList();

            final todayTodo =
                todayTasks
                    .where((t) => t.status != TaskStatus.done.index)
                    .toList()
                  ..sort((a, b) => b.priority.compareTo(a.priority));

            // ----------------------------
            // URGENT list: (todo + exiting)
            // so item stays during fade-out
            // ----------------------------
            final urgentForToday = todayTasks.where((t) {
              final isDone = t.status == TaskStatus.done.index;
              return !isDone || _exiting.contains(t.id);
            }).toList()..sort((a, b) => b.priority.compareTo(a.priority));

            final leftToday = todayTodo.length;

            final double progress = todayTasks.isEmpty
                ? 0.0
                : (todayDone.length / todayTasks.length);
            final int percent = (progress * 100).round();

            // ----------------------------
            // UPCOMING preview (always show if exists)
            // next days only + not done
            // ----------------------------
            final upcomingAll =
                state.tasks
                    .where((t) => t.status != TaskStatus.done.index)
                    .where((t) {
                      // include tasks with no date
                      if (t.dueDateTime == null) return true;

                      // keep only future-dated tasks (after today)
                      return _dateOnly(t.dueDateTime!).isAfter(today);
                    })
                    .toList()
                  ..sort((a, b) {
                    final ad = a.dueDateTime;
                    final bd = b.dueDateTime;

                    // Dated tasks first
                    if (ad == null && bd == null) return 0;
                    if (ad == null) return 1;
                    if (bd == null) return -1;

                    // Both dated: earlier first
                    return ad.compareTo(bd);
                  });
            final upcomingTop = upcomingAll.take(3).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              children: [
                // ----------------------------
                // HEADER
                // ----------------------------
                const Text(
                  "Good Morning, Steven",
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${now.day}/${now.month}/${now.year}",
                  style: const TextStyle(color: AppColors.textMuted),
                ),

                const SizedBox(height: 24),

                // ----------------------------
                // TOP CARD (today empty OR progress ring)
                // ----------------------------
                if (todayTasks.isEmpty) ...[
                  _todayEmptyCard(context),
                ] else ...[
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
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
                                backgroundColor: AppColors.border,
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.primary,
                                ),
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
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              leftToday == 0 ? "ALL DONE" : "DONE",
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    leftToday == 0
                        ? "All tasks done for today 🎉"
                        : "$leftToday task(s) left",
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                // ----------------------------
                // URGENT FOR TODAY (only if todo exists)
                // ----------------------------
                if (todayTasks.isNotEmpty && leftToday > 0) ...[
                  const SizedBox(height: 24),
                  _sectionTitle(
                    context,
                    "Urgent for Today",
                    onSeeAll: () => _goToAllTasks(context),
                  ),
                  const SizedBox(height: 8),

                  ...urgentForToday
                      .map((t) => _animatedTask(context, t))
                      .toList(),
                ],

                // ----------------------------
                // TODAY COMPLETED (if all done OR if user wants to review)
                // show when there are done tasks, and either:
                // - all done, or
                // - no urgent shown (leftToday==0)
                // ----------------------------
                if (todayDone.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _completedTodaySection(
                    context,
                    todayDone,
                    initiallyExpanded:
                        leftToday == 0, // لو كله خلص افتحها تلقائي
                  ),
                ],

                // ----------------------------
                // UPCOMING (always if exists)
                // ----------------------------
                if (upcomingTop.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _upcomingSection(context, upcomingTop),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // ========================= UI HELPERS =========================

  void _goToAllTasks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ComprehensiveTaskListScreen()),
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const Spacer(),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              "See all",
              style: TextStyle(color: AppColors.primary),
            ),
          ),
      ],
    );
  }

  Widget _animatedTask(BuildContext context, TaskModel t) {
    final exiting = _exiting.contains(t.id);

    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        opacity: exiting ? 0.0 : 1.0,
        child: TaskCard(
          task: t,
          onToggleDone: () => _toggleFromToday(context, t),
          onDelete: () => context.read<TasksCubit>().deleteTask(t.id),
        ),
      ),
    );
  }

  Widget _completedTodaySection(
    BuildContext context,
    List<TaskModel> done, {
    bool initiallyExpanded = false,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          collapsedIconColor: AppColors.textMuted,
          iconColor: AppColors.textMuted,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          title: Row(
            children: [
              const Text(
                "Today (Completed)",
                style: TextStyle(
                  color: AppColors.textMuted,
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
                  color: AppColors.primary.withAlpha((0.14 * 255).toInt()),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: AppColors.primary.withAlpha((0.35 * 255).toInt()),
                  ),
                ),
                child: Text(
                  "${done.length}",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          children: done
              .map(
                (t) => Opacity(
                  opacity: 0.65,
                  child: TaskCard(
                    task: t,
                    onToggleDone: () =>
                        context.read<TasksCubit>().toggleDone(t),
                    onDelete: () => context.read<TasksCubit>().deleteTask(t.id),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _upcomingSection(BuildContext context, List<TaskModel> upcomingTop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          context,
          "Upcoming",
          onSeeAll: () => _goToAllTasks(context),
        ),
        const SizedBox(height: 8),
        ...upcomingTop.map(
          (t) => TaskCard(
            task: t,
            onToggleDone: () => context.read<TasksCubit>().toggleDone(t),
            onDelete: () => context.read<TasksCubit>().deleteTask(t.id),
          ),
        ),
      ],
    );
  }

  Widget _todayEmptyCard(BuildContext context) {
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha((0.16 * 255).toInt()),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withAlpha((0.35 * 255).toInt()),
              ),
            ),
            child: const Icon(
              Icons.wb_sunny_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Nothing scheduled for today ✨",
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Add a task and start your day.",
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const QuickAddSheet(),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Add task"),
            ),
          ),
        ],
      ),
    );
  }
}
