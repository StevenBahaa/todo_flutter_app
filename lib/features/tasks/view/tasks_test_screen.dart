import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/widgets/task_card.dart';
import 'package:todo_list/data/models/task_enums.dart' as e;
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/features/tasks/cubit/tasks_cubit.dart';
import 'package:todo_list/features/tasks/cubit/tasks_state.dart';
import 'package:uuid/uuid.dart';

class TasksTestScreen extends StatefulWidget {
  const TasksTestScreen({super.key});

  @override
  State<TasksTestScreen> createState() => _TasksTestScreenState();
}

class _TasksTestScreenState extends State<TasksTestScreen> {
  final _controller = TextEditingController();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    context.read<TasksCubit>().loadTasks();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTask() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    final task = TaskModel.newTask(
      id: _uuid.v4(),
      title: title,
      priority: e.TaskPriority.medium,
    );
    context.read<TasksCubit>().createTask(task);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks (Test UI)'), centerTitle: true),
      body: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, state) {
          if (state.status == TasksStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == TasksStatus.failure) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          final tasks = state.tasks;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Enter task title...',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _addTask(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addTask,
                      child: const Text('Add'),
                    ),
                    const Divider(height: 1),
                  ],
                ),
              ),
              Expanded(
                child: tasks.isEmpty
                    ? const Center(child: Text('No tasks yet'))
                    : ListView.separated(
                        itemCount: tasks.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final t = tasks[index];
                          final status = e.TaskStatus.values[t.status];
                          final priority = e.TaskPriority.values[t.priority];
                          return TaskCard(
                            onToggleDone: () =>
                                context.read<TasksCubit>().toggleDone(t),
                            task: t,
                            onDelete: () =>
                                context.read<TasksCubit>().deleteTask(t.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
