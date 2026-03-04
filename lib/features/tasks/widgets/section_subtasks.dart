import 'package:flutter/material.dart';
import 'package:todo_list/core/theme/theme_x.dart';
import 'package:todo_list/core/utils/responsive.dart';
import 'package:todo_list/data/models/sub_task_model.dart';
import 'pretty_field.dart';

class SubTasksSection extends StatelessWidget {
  final TextEditingController controller;
  final List<SubTaskModel> subTasks;
  final VoidCallback onAdd;
  final void Function(String id) onToggle;
  final void Function(String id) onDelete;
  final void Function(String id, String title) onRename;

  const SubTasksSection({
    super.key,
    required this.controller,
    required this.subTasks,
    required this.onAdd,
    required this.onToggle,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    final done = subTasks.where((s) => s.isDone).length;
    final total = subTasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Subtasks',
              style: TextStyle(
                color: context.text,
                fontWeight: FontWeight.w900,
                fontSize: r.fs(15),
              ),
            ),
            const Spacer(),
            if (total > 0)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.sp(8),
                  vertical: r.sp(4),
                ),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(r.sp(999)),
                  border: Border.all(color: context.border),
                ),
                child: Text(
                  '$done / $total',
                  style: TextStyle(
                    color: context.textMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: r.fs(11),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: r.sp(4)),
        Text(
          'Break this task into smaller steps',
          style: TextStyle(
            color: context.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: r.fs(11),
          ),
        ),
        SizedBox(height: r.sp(10)),
        Container(
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(r.sp(14)),
            border: Border.all(color: context.border),
          ),
          padding: EdgeInsets.symmetric(horizontal: r.sp(8), vertical: r.sp(6)),
          child: Row(
            children: [
              Expanded(
                child: PrettyField(
                  controller: controller,
                  hint: 'Add a subtask',
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              SizedBox(width: r.sp(8)),
              SizedBox(
                height: r.sp(40),
                width: r.sp(40),
                child: ElevatedButton(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(r.sp(12)),
                    ),
                    backgroundColor: context.primary,
                    foregroundColor: context.scheme.onPrimary,
                  ),
                  child: Icon(Icons.add, size: r.sp(20)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: r.sp(10)),
        if (subTasks.isEmpty)
          Text('No subtasks yet', style: TextStyle(color: context.textMuted))
        else
          Container(
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(r.sp(14)),
              border: Border.all(color: context.border),
            ),
            child: Column(
              children: subTasks.map((s) {
                final isLast = s.id == subTasks.last.id;

                return Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(r.sp(14)),
                      onTap: () => onToggle(s.id),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.sp(12),
                          vertical: r.sp(10),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: r.sp(22),
                              height: r.sp(22),
                              decoration: BoxDecoration(
                                color: s.isDone
                                    ? context.success.withAlpha(
                                        (0.22 * 255).toInt(),
                                      )
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(r.sp(8)),
                                border: Border.all(
                                  color: s.isDone
                                      ? context.success.withAlpha(
                                          (0.80 * 255).toInt(),
                                        )
                                      : context.border,
                                ),
                              ),
                              child: s.isDone
                                  ? Icon(
                                      Icons.check,
                                      size: r.sp(16),
                                      color: context.success,
                                    )
                                  : null,
                            ),
                            SizedBox(width: r.sp(10)),
                            Expanded(
                              child: Text(
                                s.title,
                                style: TextStyle(
                                  color: context.text,
                                  fontWeight: FontWeight.w800,
                                  decoration: s.isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showEditDialog(context, s),
                              icon: Icon(Icons.edit, color: context.textMuted),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              onPressed: () => onDelete(s.id),
                              icon: Icon(Icons.close, color: context.textMuted),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast) Divider(height: 1, color: context.border),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Future<void> _showEditDialog(BuildContext context, SubTaskModel s) async {
    final r = R(context);
    final controller = TextEditingController(text: s.title);

    final result = await showDialog<String>(
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
                  'Edit subtask',
                  style: TextStyle(
                    color: ctx.text,
                    fontWeight: FontWeight.w900,
                    fontSize: r.fs(16),
                  ),
                ),
                SizedBox(height: r.sp(12)),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(
                    color: ctx.text,
                    fontWeight: FontWeight.w700,
                    fontSize: r.fs(14),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Subtask title',
                    filled: true,
                    fillColor: ctx.surface,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: r.sp(14),
                      vertical: r.sp(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(r.sp(14)),
                      borderSide: BorderSide(color: ctx.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(r.sp(14)),
                      borderSide: BorderSide(
                        color: ctx.primary.withAlpha((0.70 * 255).toInt()),
                        width: 1.3,
                      ),
                    ),
                  ),
                  onSubmitted: (value) {
                    final v = value.trim();
                    if (v.isEmpty) return;
                    Navigator.pop(ctx, v);
                  },
                ),
                SizedBox(height: r.sp(16)),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Cancel',
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
                        onPressed: () {
                          final v = controller.text.trim();
                          if (v.isEmpty) return;
                          Navigator.pop(ctx, v);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ctx.primary,
                          foregroundColor: ctx.scheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(r.sp(12)),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Save',
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

    if (result != null) {
      final title = result.trim();
      if (title.isNotEmpty) {
        onRename(s.id, title);
      }
    }
  }
}
