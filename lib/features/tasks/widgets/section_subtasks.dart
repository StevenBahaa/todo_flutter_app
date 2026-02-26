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

  const SubTasksSection({
    super.key,
    required this.controller,
    required this.subTasks,
    required this.onAdd,
    required this.onToggle,
    required this.onDelete,
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
                color: context.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            if (total > 0)
              Text(
                '$done / $total',
                style: TextStyle(
                  color: context.textMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
        SizedBox(height: r.sp(10)),
        Row(
          children: [
            Expanded(
              child: PrettyField(
                controller: controller,
                hint: 'Add a subtask',
                onSubmitted: (_) => onAdd(),
              ),
            ),
            SizedBox(width: r.sp(8)),
            IconButton(
              onPressed: onAdd,
              icon: Icon(Icons.add, color: context.primary),
            ),
          ],
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
                                    ? context.success
                                        .withAlpha((0.22 * 255).toInt())
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(r.sp(8)),
                                border: Border.all(
                                  color: s.isDone
                                      ? context.success
                                          .withAlpha((0.80 * 255).toInt())
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
                              onPressed: () => onDelete(s.id),
                              icon:
                                  Icon(Icons.close, color: context.textMuted),
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
}