import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/theme/app_colors.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/features/tasks/cubit/tasks_cubit.dart';
import 'package:todo_list/features/tasks/cubit/tasks_state.dart';
import 'package:todo_list/features/tasks/sheets/quick_add_sheet.dart';

class ComprehensiveTaskListScreen extends StatelessWidget {
  const ComprehensiveTaskListScreen({super.key});

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = _dateOnly(now);
    final tomorrow = today.add(const Duration(days: 1));
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("All Tasks"),
        actions: [IconButton(icon: const Icon(Icons.tune), onPressed: () {})],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            builder: (_) => const QuickAddSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, state) {
          final tasks = state.tasks;
          final activeTasks = tasks.where(
            (t) => t.status != TaskStatus.done.index,
          );
          final overdueTasks = activeTasks.where(
            (t) => t.dueDateTime != null && t.dueDateTime!.isBefore(now),
          );

          final todayTasks = activeTasks
              .where(
                (t) =>
                    t.dueDateTime != null &&
                    _isSameDay(_dateOnly(t.dueDateTime!), today) &&
                    !t.dueDateTime!.isBefore(now),
              )
              .toList();

          final tomorrowTasks = activeTasks
              .where(
                (t) =>
                    t.dueDateTime != null &&
                    _isSameDay(_dateOnly(t.dueDateTime!), tomorrow),
              )
              .toList();
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return const Row(
      
    );
  }
}
