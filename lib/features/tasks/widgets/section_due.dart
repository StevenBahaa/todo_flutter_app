import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/core/theme/theme_x.dart';
import 'package:todo_list/core/utils/responsive.dart';
import 'package:todo_list/l10n/app_localizations.dart';

class DueSection extends StatelessWidget {
  final DateTime? due;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const DueSection({
    super.key,
    required this.due,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final r = R(context);

    String format(DateTime dt) {
      final locale = Localizations.localeOf(context).languageCode;
      final date = DateFormat('d/M/y', locale).format(dt);
      final time = DateFormat('HH:mm', locale).format(dt);
      return '$date  $time';
    }

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
                  due == null ? t.noDueDate : format(due!),
                  style: TextStyle(
                    color: context.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(onPressed: onPick, child: Text(t.pick)),
              if (due != null)
                TextButton(onPressed: onClear, child: Text(t.clear)),
            ],
          ),
        ),
      ],
    );
  }
}