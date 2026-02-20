// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:todo_list/core/theme/app_colors.dart';
import 'package:todo_list/core/theme/tag_colors.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/features/tasks/cubit/tasks_cubit.dart';

// ✅ localization import (your project path)
import 'package:todo_list/l10n/app_localizations.dart';

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

  bool get _hasChanges {
    return _titleController.text.trim() != widget.task.title ||
        _descController.text.trim() != (widget.task.description ?? "") ||
        _priority.index != widget.task.priority ||
        _dueDateTime != widget.task.dueDateTime ||
        !_listEquals(_tags, widget.task.tags);
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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
    final t = AppLocalizations.of(context)!;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.deleteTaskTitle,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.deleteTaskCannotUndo,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          t.cancel,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(
                          t.delete,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (ok == true) {
      context.read<TasksCubit>().deleteTask(widget.task.id);
      Navigator.pop(context);
    }
  }

  Future<void> _pickDueDateTime() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: _dueDateTime ?? now,
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
      });
      return;
    }

    setState(() {
      _dueDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
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

  String _priorityLabel(BuildContext context, TaskPriority p) {
    final t = AppLocalizations.of(context)!;
    switch (p) {
      case TaskPriority.low:
        return t.priorityLow;
      case TaskPriority.medium:
        return t.priorityMedium;
      case TaskPriority.high:
        return t.priorityHigh;
    }
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(t.taskDetailsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: _confirmDelete,
            tooltip: t.delete,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _hasChanges ? _save : null,
        backgroundColor: _hasChanges
            ? AppColors.primary
            : AppColors.primary.withAlpha((0.35 * 255).toInt()),
        child: const Icon(Icons.check),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        children: [
          _titleField(context),
          const SizedBox(height: 16),
          _descriptionField(context),
          const SizedBox(height: 18),
          _prioritySection(context),
          const SizedBox(height: 18),
          _dueSection(context),
          const SizedBox(height: 18),
          _tagsSection(context),
        ],
      ),
    );
  }

  Widget _titleField(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return TextField(
      controller: _titleController,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        labelText: t.titleLabel,
        hintText: t.taskTitleHint,
      ),
      textInputAction: TextInputAction.next,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _descriptionField(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return TextField(
      controller: _descController,
      maxLines: 4,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: t.descriptionLabel,
        hintText: t.descriptionHint,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _prioritySection(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.priorityLabel,
          style: const TextStyle(
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
              label: Text(_priorityLabel(context, p)),
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

  Widget _dueSection(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.due,
          style: const TextStyle(
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
                      ? t.noDueDate
                      : _formatDue(context, _dueDateTime!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(onPressed: _pickDueDateTime, child: Text(t.pick)),
              if (_dueDateTime != null)
                TextButton(onPressed: _clearDue, child: Text(t.clear)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tagsSection(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.tagsLabel,
          style: const TextStyle(
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
                decoration: InputDecoration(hintText: t.addTagsHint),
                onSubmitted: (_) => _addTag(),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(onPressed: _addTag, icon: const Icon(Icons.add)),
          ],
        ),
        const SizedBox(height: 10),
        if (_tags.isEmpty)
          Text(t.noTags, style: const TextStyle(color: AppColors.textMuted))
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

  String _formatDue(BuildContext context, DateTime dt) {
    final locale = Localizations.localeOf(context).languageCode;
    final date = DateFormat('d/M/y', locale).format(dt);
    final time = DateFormat('HH:mm', locale).format(dt);
    return '$date  $time';
  }
}
