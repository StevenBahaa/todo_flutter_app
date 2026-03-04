import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/theme/theme_x.dart';
import 'package:todo_list/core/utils/responsive.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/features/tasks/cubit/tasks_cubit.dart';
import 'package:todo_list/features/tasks/widgets/pretty_field.dart';
import 'package:todo_list/features/tasks/widgets/section_due.dart';
import 'package:todo_list/features/tasks/widgets/section_priority.dart';
import 'package:todo_list/features/tasks/widgets/section_subtasks.dart';
import 'package:todo_list/features/tasks/widgets/section_tags.dart';
import 'package:todo_list/l10n/app_localizations.dart';
import 'task_details_controller.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskModel task;
  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late final TaskDetailsController c;

  @override
  void initState() {
    super.initState();
    c = TaskDetailsController(widget.task);

    // rebuild when user edits text
    c.title.addListener(() => setState(() {}));
    c.desc.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  void _save() {
    final title = c.title.text.trim();
    if (title.isEmpty) return;

    context.read<TasksCubit>().updateTask(c.buildUpdated());
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
      initialDate: c.dueDateTime ?? now,
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: c.dueDateTime != null
          ? TimeOfDay.fromDateTime(c.dueDateTime!)
          : TimeOfDay.fromDateTime(now),
    );

    setState(() {
      if (time == null) {
        c.dueDateTime = DateTime(date.year, date.month, date.day);
      } else {
        c.dueDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final r = R(context);
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

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
      floatingActionButton: isKeyboardOpen
          ? null
          : FloatingActionButton(
              onPressed: c.hasChanges ? _save : null,
              backgroundColor: c.hasChanges
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
              PrettyField(
                controller: c.title,
                label: t.titleLabel,
                hint: t.taskTitleHint,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: r.sp(16)),
              PrettyField(
                controller: c.desc,
                label: t.descriptionLabel,
                hint: t.descriptionHint,
                maxLines: 4,
              ),
              SizedBox(height: r.sp(18)),

              PrioritySection(
                selected: c.priority,
                onChanged: (p) => setState(() => c.priority = p),
              ),
              SizedBox(height: r.sp(18)),

              DueSection(
                due: c.dueDateTime,
                onPick: _pickDueDateTime,
                onClear: () => setState(() => c.dueDateTime = null),
              ),
              SizedBox(height: r.sp(18)),

              SubTasksSection(
                controller: c.subTaskController,
                subTasks: c.subTasks,
                onAdd: () => setState(() => c.addSubTask()),
                onToggle: (id) => setState(() => c.toggleSubTask(id)),
                onDelete: (id) => setState(() => c.deleteSubTask(id)),
                onRename: (id, title) =>
                    setState(() => c.renameSubTask(id, title)),
              ),
              SizedBox(height: r.sp(18)),

              TagsSection(
                controller: c.tagController,
                tags: c.tags,
                onAdd: () => setState(() => c.addTag()),
                onDelete: (tag) => setState(() => c.removeTag(tag)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
