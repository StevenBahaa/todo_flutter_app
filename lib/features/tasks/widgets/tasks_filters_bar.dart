import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/theme/theme_x.dart';
import 'package:todo_list/core/utils/responsive.dart';
import 'package:todo_list/features/tasks/cubit/tasks_cubit.dart';
import 'package:todo_list/features/tasks/cubit/tasks_filter.dart';
import 'package:todo_list/l10n/app_localizations.dart';

class TasksFiltersBar extends StatelessWidget {
  final TasksFilter active;
  final int overdueCount;

  const TasksFiltersBar({
    super.key,
    required this.active,
    required this.overdueCount,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final r = R(context);

    Widget chip(String text, TasksFilter f, {bool showDot = false}) {
      final selected = active == f;

      return Padding(
        padding: EdgeInsets.only(right: r.sp(10)),
        child: ChoiceChip(
          selected: selected,
          onSelected: (_) => context.read<TasksCubit>().setFilter(f),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text),
              if (showDot) ...[
                SizedBox(width: r.sp(8)),
                Container(
                  width: r.sp(10),
                  height: r.sp(10),
                  decoration: BoxDecoration(
                    color: context.danger,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.surface,
                      width: r.sp(1.5),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip(t.filterAll, TasksFilter.all),
          chip(t.filterOverdue, TasksFilter.overdue, showDot: overdueCount > 0),
          chip(t.filterToday, TasksFilter.today),
          chip(t.filterHighPriority, TasksFilter.highPriority),
        ],
      ),
    );
  }
}
