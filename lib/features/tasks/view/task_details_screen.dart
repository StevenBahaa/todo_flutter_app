// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:todo_list/core/theme/tag_colors.dart';
import 'package:todo_list/core/theme/theme_x.dart';
import 'package:todo_list/core/utils/responsive.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/features/tasks/cubit/tasks_cubit.dart';
import 'package:todo_list/l10n/app_localizations.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskModel task;
  const TaskDetailsScreen({super.key, required this.task});

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

  // ---------------- Actions ----------------

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
    final r = R(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: ctx.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(r.sp(18)),
            side: BorderSide(color: ctx.border),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              r.sp(18),
              r.sp(18),
              r.sp(18),
              r.sp(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.deleteTaskTitle,
                  style: TextStyle(
                    color: ctx.text,
                    fontWeight: FontWeight.w900,
                    fontSize: r.fs(18),
                  ),
                ),
                SizedBox(height: r.sp(8)),
                Text(
                  t.deleteTaskCannotUndo,
                  style: TextStyle(
                    color: ctx.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: r.sp(18)),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          t.cancel,
                          style: TextStyle(
                            color: ctx.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: r.sp(10)),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ctx.danger,
                          foregroundColor: ctx.scheme.onError,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(r.sp(12)),
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

    setState(() {
      if (time == null) {
        _dueDateTime = DateTime(date.year, date.month, date.day);
      } else {
        _dueDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      }
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
    return switch (p) {
      TaskPriority.low => t.priorityLow,
      TaskPriority.medium => t.priorityMedium,
      TaskPriority.high => t.priorityHigh,
    };
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final r = R(context);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: Text(t.taskDetailsTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: context.danger),
            onPressed: _confirmDelete,
            tooltip: t.delete,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _hasChanges ? _save : null,
        backgroundColor: _hasChanges
            ? context.primary
            : context.primary.withAlpha((0.35 * 255).toInt()),
        child: const Icon(Icons.check),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              r.sp(16),
              r.sp(12),
              r.sp(16),
              r.sp(110),
            ),
            children: [
              _titleField(context),
              SizedBox(height: r.sp(16)),
              _descriptionField(context),
              SizedBox(height: r.sp(18)),
              _prioritySection(context),
              SizedBox(height: r.sp(18)),
              _dueSection(context),
              SizedBox(height: r.sp(18)),
              _tagsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleField(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final r = R(context);

    return TextField(
      controller: _titleController,
      style: TextStyle(
        color: context.text,
        fontSize: r.fs(18),
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        labelText: t.titleLabel,
        hintText: t.taskTitleHint,
        hintStyle: TextStyle(color: context.textMuted),
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
      style: TextStyle(color: context.text),
      decoration: InputDecoration(
        labelText: t.descriptionLabel,
        hintText: t.descriptionHint,
        hintStyle: TextStyle(color: context.textMuted),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _prioritySection(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final r = R(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.priorityLabel,
          style: TextStyle(
            color: context.textMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: r.sp(10)),
        Wrap(
          spacing: r.sp(10),
          runSpacing: r.sp(10),
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
                fontSize: r.fs(12),
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
    final r = R(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.due,
          style: TextStyle(
            color: context.textMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: r.sp(10)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: r.sp(12),
            vertical: r.sp(12),
          ),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(r.sp(14)),
            border: Border.all(color: context.border),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: r.sp(18),
                color: context.textMuted,
              ),
              SizedBox(width: r.sp(10)),
              Expanded(
                child: Text(
                  _dueDateTime == null
                      ? t.noDueDate
                      : _formatDue(context, _dueDateTime!),
                  style: TextStyle(
                    color: context.text,
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
    final r = R(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.tagsLabel,
          style: TextStyle(
            color: context.textMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: r.sp(10)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: t.addTagsHint,
                  hintStyle: TextStyle(color: context.textMuted),
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            SizedBox(width: r.sp(8)),
            IconButton(
              onPressed: _addTag,
              icon: Icon(Icons.add, color: context.primary),
            ),
          ],
        ),
        SizedBox(height: r.sp(10)),
        if (_tags.isEmpty)
          Text(t.noTags, style: TextStyle(color: context.textMuted))
        else
          Wrap(
            spacing: r.sp(8),
            runSpacing: r.sp(8),
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
        return context.danger;
      case TaskPriority.medium:
        return context.warning;
      case TaskPriority.low:
        return context.success;
    }
  }

  String _formatDue(BuildContext context, DateTime dt) {
    final locale = Localizations.localeOf(context).languageCode;
    final date = DateFormat('d/M/y', locale).format(dt);
    final time = DateFormat('HH:mm', locale).format(dt);
    return '$date  $time';
  }
}