import 'package:flutter/material.dart';
import 'package:todo_list/core/theme/theme_x.dart';
import 'package:todo_list/core/utils/responsive.dart';

class TasksSectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final Color? countColor;

  const TasksSectionHeader({
    super.key,
    required this.title,
    this.count,
    this.countColor,
  });

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    final showCount = count != null && count! > 0;
    final c = countColor ?? context.danger;

    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.textMuted,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: r.fs(12),
          ),
        ),
        const Spacer(),
        if (showCount)
          Container(
            padding: EdgeInsets.symmetric(horizontal: r.sp(10), vertical: r.sp(6)),
            decoration: BoxDecoration(
              color: c.withAlpha((0.20 * 255).toInt()),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: c.withAlpha((0.55 * 255).toInt())),
            ),
            child: Text(
              "$count",
              style: TextStyle(
                color: c,
                fontWeight: FontWeight.w800,
                fontSize: r.fs(12),
              ),
            ),
          ),
      ],
    );
  }
}