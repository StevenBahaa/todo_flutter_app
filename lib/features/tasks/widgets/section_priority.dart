import 'package:flutter/material.dart';
import 'package:todo_list/core/theme/theme_x.dart';
import 'package:todo_list/core/utils/responsive.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/l10n/app_localizations.dart';

class PrioritySection extends StatelessWidget {
  final TaskPriority selected;
  final void Function(TaskPriority) onChanged;

  const PrioritySection({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final r = R(context);

    Color color(TaskPriority p) {
      switch (p) {
        case TaskPriority.high:
          return context.danger;
        case TaskPriority.medium:
          return context.warning;
        case TaskPriority.low:
          return context.success;
      }
    }

    String label(TaskPriority p) {
      return switch (p) {
        TaskPriority.low => t.priorityLow,
        TaskPriority.medium => t.priorityMedium,
        TaskPriority.high => t.priorityHigh,
      };
    }

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
            final c = color(p);
            final isSelected = selected == p;

            return ChoiceChip(
              label: Text(label(p)),
              selected: isSelected,
              onSelected: (_) => onChanged(p),
              labelStyle: TextStyle(
                color: isSelected ? c : c.withAlpha((0.90 * 255).toInt()),
                fontWeight: isSelected
                    ? FontWeight.w900
                    : FontWeight.w700,
                fontSize: r.fs(12),
              ),
              selectedColor:
                  c.withAlpha((0.25 * 255).toInt()),
              backgroundColor:
                  c.withAlpha((0.12 * 255).toInt()),
              side: BorderSide(
                color: isSelected
                    ? c.withAlpha((0.85 * 255).toInt())
                    : c.withAlpha((0.35 * 255).toInt()),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}