// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/theme/app_colors.dart';
import 'package:todo_list/core/theme/tag_colors.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/features/tasks/cubit/tasks_cubit.dart';

class TaskDetailsScreen extends StatefulWidget {
  TaskModel task;
  TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  final TextEditingController _tagController = TextEditingController();

  late TaskPriority _priority;
  DateTime? _dueDateTime;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _priority = TaskPriority.values[widget.task.priority];
    _dueDateTime = widget.task.dueDateTime;
    _tags = List<String>.from(widget.task.tags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  // -------------------------------------
  // Actions
  // -------------------------------------

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final update = widget.task.copyWith(
      title: title,
      description: _descController.text.trim(),
      priority: _priority.index,
      dueDateTime: _dueDateTime,
      tags: List.unmodifiable(_tags),
    );

    context.read<TasksCubit>().updateTask(update);
    Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Delete task?"),
          content: const Text("This action can't be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      context.read<TasksCubit>().deleteTask(widget.task.id);
      Navigator.pop(context); // اقفل صفحة التفاصيل
    }
  }

  Future<void> _pickDueDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _dueDateTime != null
          ? TimeOfDay.fromDateTime(_dueDateTime!)
          : TimeOfDay.fromDateTime(now),
    );

    if (time == null) {
      setState(() {
        _dueDateTime = DateTime(date.year, date.month, date.day);
        return;
      });
    }
  }

  void _clearDue() => setState(() => _dueDateTime = null);

  void _addTag() {
    final raw = _tagController.text.trim();
    if (raw.isEmpty) return;

    final parts = raw
        .split(RegExp(r'[,\s]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    setState(() {
      for (final p in parts) {
        final tag = p.startsWith('#') ? p.substring(1) : p;
        if (tag.isEmpty) continue;
        if (!_tags.contains(tag)) _tags.add(tag);
      }
    });

    _tagController.clear();
  }

  void _removeTag(String tag) => setState(() => _tags.remove(tag));

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: const Icon(Icons.check),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        children: [
          _titleField(),
          const SizedBox(height: 16),
          _descriptionField(),
          const SizedBox(height: 18),
          _prioritySection(),
          const SizedBox(height: 18),
          _dueSection(),
          const SizedBox(height: 18),
          _tagsSection(),
        ],
      ),
    );
  }

  Widget _titleField() {
    return TextField(
      controller: _titleController,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(labelText: "Title", hintText: "Task title"),
      textInputAction: TextInputAction.next,
    );
  }

  Widget _descriptionField() {
    return TextField(
      controller: _descController,
      maxLines: 4,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Description",
        hintText: "Add notes...",
      ),
    );
  }

  Widget _prioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Priority",
          style: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: TaskPriority.values.map((p) {
            final selected = _priority == p;
            final c = _priorityColor(p);

            return ChoiceChip(
              label: Text(p.name.toUpperCase()),
              selected: selected,
              onSelected: (_) => setState(() => _priority = p),
              labelStyle: TextStyle(
                color: selected ? c : c.withAlpha((0.90 * 255).toInt()),
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                fontSize: 12,
              ),
              selectedColor: c.withAlpha((0.25 * 255).toInt()),
              backgroundColor: c.withAlpha((0.12 * 255).toInt()),
              side: BorderSide(
                color: selected
                    ? c.withAlpha((0.85 * 255).toInt())
                    : c.withAlpha((0.35 * 255).toInt()),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _dueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Due",
          style: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 18,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _dueDateTime == null
                      ? "No due date"
                      : _formatDue(_dueDateTime!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: _pickDueDateTime,
                child: const Text("Pick"),
              ),
              if (_dueDateTime != null)
                TextButton(onPressed: _clearDue, child: const Text("Clear")),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tags",
          style: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: "Add tags (e.g. work, urgent)",
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(onPressed: _addTag, icon: const Icon(Icons.add)),
          ],
        ),
        const SizedBox(height: 10),
        if (_tags.isEmpty)
          const Text("No tags", style: TextStyle(color: AppColors.textMuted))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              final c = TagColors.resolve(tag);
              return Chip(
                label: Text("#$tag"),
                labelStyle: TextStyle(color: c, fontWeight: FontWeight.w900),
                backgroundColor: c.withAlpha((0.16 * 255).toInt()),
                side: BorderSide(color: c.withAlpha((0.45 * 255).toInt())),
                deleteIconColor: c.withAlpha((0.85 * 255).toInt()),
                onDeleted: () => _removeTag(tag),
              );
            }).toList(),
          ),
      ],
    );
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return AppColors.danger;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.low:
        return AppColors.success;
    }
  }

  String _formatDue(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "${dt.day}/${dt.month}/${dt.year}  $h:$m";
  }
}
