import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/core/theme/tag_colors.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/features/tasks/cubit/tasks_cubit.dart';
import 'package:uuid/uuid.dart';

// ✅ your generated localizations path
import 'package:todo_list/l10n/app_localizations.dart';
import 'package:todo_list/core/theme/theme_x.dart';

class QuickAddSheet extends StatefulWidget {
  const QuickAddSheet({super.key});

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  final _titleController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  final _uuid = const Uuid();
  DateTime? _dueDateTime;

  TaskPriority _priority = TaskPriority.medium;

  @override
  void dispose() {
    _tagController.dispose();
    _titleController.dispose();
    super.dispose();
  }

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
      setState(() => _dueDateTime = DateTime(date.year, date.month, date.day));
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

  void _addTag() {
    final raw = _tagController.text.trim();
    if (raw.isEmpty) return;

    final parts = raw
        .split(RegExp(r'[,\s]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    setState(() {
      for (final t in parts) {
        final tag = t.startsWith('#') ? t.substring(1) : t;
        if (tag.isEmpty) continue;
        if (!_tags.contains(tag)) _tags.add(tag);
      }
    });
    _tagController.clear();
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final task = TaskModel.newTask(
      id: _uuid.v4(),
      title: title,
      priority: _priority,
      tags: List.unmodifiable(_tags),
      dueDateTime: _dueDateTime,
    );

    context.read<TasksCubit>().createTask(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

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
              color: context.text,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  t.quickAddTaskTitle,
                  style: TextStyle(
                    color: context.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                glassButton(
                  onPressed: _submit,
                  child: Text(
                    t.add,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            autofocus: true,
            style: TextStyle(color: context.text),
            decoration: InputDecoration(
              hintText: t.taskTitleHint,
              hintStyle: TextStyle(color: context.text),
              filled: true,
              fillColor: context.scheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pickDueDateTime,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  _dueDateTime == null
                      ? t.due
                      : _formatDue(context, _dueDateTime!),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _priorityChip(
                context,
                TaskPriority.low,
                _priorityLabel(context, TaskPriority.low),
              ),
              const SizedBox(width: 8),
              _priorityChip(
                context,
                TaskPriority.medium,
                _priorityLabel(context, TaskPriority.medium),
              ),
              const SizedBox(width: 8),
              _priorityChip(
                context,
                TaskPriority.high,
                _priorityLabel(context, TaskPriority.high),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagController,
                  style: TextStyle(color: context.text),
                  decoration: InputDecoration(hintText: t.addTagsHint),
                  onSubmitted: (_) => _addTag(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: _addTag, icon: const Icon(Icons.add)),
            ],
          ),
          const SizedBox(height: 10),
          if (_tags.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    backgroundColor: TagColors.resolve(
                      tag,
                    ).withAlpha((0.22 * 255).toInt()),
                    labelStyle: TextStyle(
                      color: TagColors.resolve(tag),
                      fontWeight: FontWeight.w700,
                    ),
                    label: Text("#$tag"),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    deleteIconColor: TagColors.resolve(
                      tag,
                    ).withAlpha((0.7 * 255).toInt()),
                    side: BorderSide(
                      color: TagColors.resolve(
                        tag,
                      ).withAlpha((0.5 * 255).toInt()),
                    ),
                    onDeleted: () => _removeTag(tag),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDue(BuildContext context, DateTime dt) {
    final locale = Localizations.localeOf(context).languageCode;
    final date = DateFormat('d/M', locale).format(dt);
    final time = DateFormat('HH:mm', locale).format(dt);
    return '$date  $time';
  }

  Widget glassButton({required VoidCallback onPressed, required Widget child}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: context.primary.withAlpha((0.18 * 255).toInt()),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.primary.withAlpha((0.45 * 255).toInt()),
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
        return context.danger;
      case TaskPriority.medium:
        return context.warning;
      case TaskPriority.low:
        return context.success;
    }
  }

  Widget _priorityChip(BuildContext context, TaskPriority p, String label) {
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
