import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/task_card.dart';
import '../../../data/models/task_enums.dart';
import '../cubit/tasks_cubit.dart';
import '../cubit/tasks_state.dart';
import '../sheets/quick_add_sheet.dart';
import 'comprehensive_task_list_screen.dart';

class TodayDashboardScreen extends StatelessWidget {
  const TodayDashboardScreen({super.key});

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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

            /// ✅ كل tasks بتاعة النهارده
            final todayTasks = state.tasks.where((t) {
              if (t.dueDateTime == null) return false;
              return _isSameDay(_dateOnly(t.dueDateTime!), today);
            }).toList();

            /// ✅ done today
            final doneToday = todayTasks
                .where((t) => t.status == TaskStatus.done.index)
                .length;

            /// ✅ urgent today (مش done)
            final urgent =
                todayTasks
                    .where((t) => t.status != TaskStatus.done.index)
                    .toList()
                  ..sort((a, b) => b.priority.compareTo(a.priority));

            final leftToday = urgent.length;

            final double progress = todayTasks.isEmpty
                ? 0.0
                : (doneToday / todayTasks.length);
            final int percent = (progress * 100).round();
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              children: [
                /// HEADER
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

                const SizedBox(height: 30),

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
                            return SizedBox(
                              width: 180,
                              height: 180,
                              child: CircularProgressIndicator(
                                value: value,
                                strokeWidth: 12,
                                backgroundColor: AppColors.border,
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.primary,
                                ),
                                strokeCap: StrokeCap.round,
                              ),
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
                          const Text(
                            "DONE",
                            style: TextStyle(
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

                const SizedBox(height: 30),

                Text(
                  todayTasks.isEmpty
                      ? "No tasks for today"
                      : leftToday == 0
                      ? "All tasks done 🎉"
                      : "$leftToday task(s) left",
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                /// TITLE ROW
                Row(
                  children: [
                    const Text(
                      "Urgent for Today",
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ComprehensiveTaskListScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "See all",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                /// TASKS LIST
                if (urgent.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      "No tasks for today ✨",
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),

                ...urgent.map(
                  (t) => TaskCard(
                    task: t,
                    onToggleDone: () =>
                        context.read<TasksCubit>().toggleDone(t),
                    onDelete: () => context.read<TasksCubit>().deleteTask(t.id),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
