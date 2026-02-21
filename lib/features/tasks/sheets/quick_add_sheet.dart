import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:todo_list/core/theme/tag_colors.dart';
import 'package:todo_list/core/theme/theme_x.dart';
import 'package:todo_list/core/utils/responsive.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/features/tasks/cubit/tasks_cubit.dart';
import 'package:todo_list/l10n/app_localizations.dart';

class QuickAddSheet extends StatefulWidget {
  const QuickAddSheet({super.key});

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  final _titleController = TextEditingController();
  final _tagController = TextEditingController();
  final _uuid = const Uuid();

  final List<String> _tags = [];
  DateTime? _dueDateTime;
  TaskPriority _priority = TaskPriority.medium;

  bool get _canSubmit => _titleController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  String _priorityLabel(BuildContext context, TaskPriority p) {
    final t = AppLocalizations.of(context)!;
    return switch (p) {
      TaskPriority.low => t.priorityLow,
      TaskPriority.medium => t.priorityMedium,
      TaskPriority.high => t.priorityHigh,
    };
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

  void _clearTags() => setState(() => _tags.clear());

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
    final r = R(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: r.sp(16),
          right: r.sp(16),
          top: r.sp(12),
          bottom: r.sp(16) + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          // يمنع overflow لما الكيبورد يطلع على شاشات صغيرة
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: r.sp(44),
                height: r.sp(5),
                decoration: BoxDecoration(
                  color: context.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),

              SizedBox(height: r.sp(12)),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.quickAddTaskTitle,
                      style: TextStyle(
                        color: context.text,
                        fontSize: r.fs(18),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _GlassButton(
                    enabled: _canSubmit,
                    onPressed: _submit,
                    child: Text(
                      t.add,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),

              SizedBox(height: r.sp(12)),

              TextField(
                controller: _titleController,
                autofocus: true,
                style: TextStyle(color: context.text),
                decoration: InputDecoration(
                  hintText: t.taskTitleHint,
                  hintStyle: TextStyle(color: context.textMuted),
                ),
                onSubmitted: (_) => _submit(),
              ),

              SizedBox(height: r.sp(12)),

              // Due row
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
                  if (_dueDateTime != null) ...[
                    SizedBox(width: r.sp(8)),
                    IconButton(
                      tooltip: t.clear,
                      onPressed: _clearDue,
                      icon: Icon(Icons.close, color: context.textMuted),
                    ),
                  ],
                  const Spacer(),
                ],
              ),

              SizedBox(height: r.sp(12)),

              // Priority
              Wrap(
                spacing: r.sp(8),
                runSpacing: r.sp(8),
                children: [
                  _PriorityChip(
                    label: _priorityLabel(context, TaskPriority.low),
                    selected: _priority == TaskPriority.low,
                    color: context.success,
                    onTap: () => setState(() => _priority = TaskPriority.low),
                  ),
                  _PriorityChip(
                    label: _priorityLabel(context, TaskPriority.medium),
                    selected: _priority == TaskPriority.medium,
                    color: context.warning,
                    onTap: () =>
                        setState(() => _priority = TaskPriority.medium),
                  ),
                  _PriorityChip(
                    label: _priorityLabel(context, TaskPriority.high),
                    selected: _priority == TaskPriority.high,
                    color: context.danger,
                    onTap: () => setState(() => _priority = TaskPriority.high),
                  ),
                ],
              ),

              SizedBox(height: r.sp(12)),

              // Tags input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      style: TextStyle(color: context.text),
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

              if (_tags.isNotEmpty) ...[
                SizedBox(height: r.sp(10)),
                Row(
                  children: [
                    Text(
                      t.tags,
                      style: TextStyle(
                        color: context.textMuted,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearTags,
                      child: Text(
                        t.clear,
                        style: TextStyle(color: context.textMuted),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: r.sp(8),
                    runSpacing: r.sp(8),
                    children: _tags.map((tag) {
                      final c = TagColors.resolve(tag);
                      return Chip(
                        backgroundColor: c.withAlpha((0.22 * 255).toInt()),
                        labelStyle: TextStyle(
                          color: c,
                          fontWeight: FontWeight.w700,
                        ),
                        label: Text("#$tag"),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        deleteIconColor: c.withAlpha((0.70 * 255).toInt()),
                        side: BorderSide(
                          color: c.withAlpha((0.50 * 255).toInt()),
                        ),
                        onDeleted: () => _removeTag(tag),
                      );
                    }).toList(),
                  ),
                ),
              ],

              SizedBox(height: r.sp(8)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDue(BuildContext context, DateTime dt) {
    final locale = Localizations.localeOf(context).languageCode;
    final date = DateFormat('d/M', locale).format(dt);
    final time = DateFormat('HH:mm', locale).format(dt);
    return '$date  $time';
  }
}

class _GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool enabled;

  const _GlassButton({
    required this.onPressed,
    required this.child,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(16),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: r.sp(18),
            vertical: r.sp(12),
          ),
          decoration: BoxDecoration(
            color: context.primary.withAlpha((0.18 * 255).toInt()),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.primary.withAlpha((0.45 * 255).toInt()),
              width: 1.2,
            ),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: context.primary),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _PriorityChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: r.sp(14), vertical: r.sp(9)),
        decoration: BoxDecoration(
          color: selected
              ? color.withAlpha((0.38 * 255).toInt())
              : color.withAlpha((0.14 * 255).toInt()),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? color.withAlpha((0.90 * 255).toInt())
                : color.withAlpha((0.40 * 255).toInt()),
            width: selected ? 1.6 : 1.1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : color.withAlpha((0.85 * 255).toInt()),
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
