import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/theme/app_colors.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/features/tasks/cubit/tasks_cubit.dart';
import 'package:uuid/uuid.dart';

class QuickAddSheet extends StatefulWidget {
  const QuickAddSheet({super.key});

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  final _titleController = TextEditingController();
  final _uuid = const Uuid();

  TaskPriority _priority = TaskPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();

    if (title.isEmpty) return;

    final task = TaskModel.newTask(
      id: _uuid.v4(),
      title: title,
      priority: _priority,
      tags: [],
    );

    context.read<TasksCubit>().createTask(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        right: 16,
        left: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  'Quick Add Task',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                glassButton(
                  onPressed: _submit,
                  child: const Text(
                    "Add",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Task title...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF1E2935),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) => _submit(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _priorityChip(TaskPriority.low, "LOW"),
              const SizedBox(width: 8),
              _priorityChip(TaskPriority.medium, "MED"),
              const SizedBox(width: 8),
              _priorityChip(TaskPriority.high, "HIGH"),
            ],
          ),
        ],
      ),
    );
  }

  Widget glassButton({required VoidCallback onPressed, required Widget child}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha((0.18 * 255).toInt()),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withAlpha((0.45 * 255).toInt()),
            width: 1.2,
          ),
        ),
        child: child,
      ),
    );
  }

  Color _pColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return AppColors.danger;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.low:
        return AppColors.success;
    }
  }

  Widget _priorityChip(TaskPriority p, String label) {
    final selected = _priority == p;
    final c = _pColor(p);

    return InkWell(
      onTap: () => setState(() => _priority = p),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? c.withAlpha((0.38 * 255).toInt())
              : c.withAlpha((0.14 * 255).toInt()),
          borderRadius: BorderRadius.circular(14),

          border: Border.all(
            color: selected
                ? c.withAlpha((0.9 * 255).toInt())
                : c.withAlpha((0.4 * 255).toInt()),
            width: selected ? 1.6 : 1.1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? c : c.withAlpha((0.85 * 255).toInt()),
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
