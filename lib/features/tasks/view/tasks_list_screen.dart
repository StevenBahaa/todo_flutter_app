import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/widgets/task_card.dart';
import 'package:todo_list/features/tasks/cubit/tasks_cubit.dart';
import 'package:todo_list/features/tasks/cubit/tasks_state.dart';
import 'package:todo_list/features/tasks/sheets/quick_add_sheet.dart';

class TasksListScreen extends StatelessWidget {
  const TasksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text("All Tasks", style: TextStyle(color: Colors.white)),
        actions: [IconButton(icon: const Icon(Icons.tune), onPressed: () {})],
      ),
      body: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, state) {
          final tasks = state.tasks;
          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                "No tasks yet",
                style: TextStyle(color: Colors.white54),
              ),
            );
          }
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                onDelete: () => context.read<TasksCubit>().deleteTask(task.id),
                onToggleDone: () => context.read<TasksCubit>().toggleDone(task),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: const Color(0xFF6366F1),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            builder: (_) => const QuickAddSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
