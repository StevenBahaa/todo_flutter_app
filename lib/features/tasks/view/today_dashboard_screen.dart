import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:todo_list/core/theme/app_colors.dart';
import 'package:todo_list/core/widgets/task_card.dart';
import 'package:todo_list/data/local/hive_boxes.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';
import 'package:todo_list/features/settings/view/settings_screen.dart';
import 'package:todo_list/features/tasks/cubit/tasks_cubit.dart';
import 'package:todo_list/features/tasks/cubit/tasks_state.dart';
import 'package:todo_list/features/tasks/sheets/quick_add_sheet.dart';
import 'package:todo_list/features/tasks/view/comprehensive_task_list_screen.dart';
import 'package:todo_list/l10n/app_localizations.dart';

class TodayDashboardScreen extends StatefulWidget {
  const TodayDashboardScreen({super.key});

  @override
  State<TodayDashboardScreen> createState() => _TodayDashboardScreenState();
}

class _TodayDashboardScreenState extends State<TodayDashboardScreen> {
  final Set<String> _exiting = {};

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _toggleFromToday(BuildContext context, TaskModel task) async {
    final wasDone = task.status == TaskStatus.done.index;

    // Todo -> Done => play exit animation
    if (!wasDone) {
      setState(() => _exiting.add(task.id));

      context.read<TasksCubit>().toggleDone(task);

      await Future.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;

      setState(() => _exiting.remove(task.id));
    } else {
      // Done -> Todo
      context.read<TasksCubit>().toggleDone(task);
    }
  }

  void _openQuickAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const QuickAddSheet(),
    );
  }

  void _goToAllTasks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ComprehensiveTaskListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        onPressed: () => _openQuickAdd(context),
      ),
      body: SafeArea(
        child: BlocBuilder<TasksCubit, TasksState>(
          builder: (context, state) {
            final now = DateTime.now();
            final today = _dateOnly(now);

            // =========================
            // Base lists (not done)
            // =========================
            final active = state.tasks.where((task) {
              final isDone = task.status == TaskStatus.done.index;
              return !isDone || _exiting.contains(task.id);
            }).toList();

            // Today (dated today)
            final todayActive = active.where((task) {
              if (task.dueDateTime == null) return false;
              return _isSameDay(_dateOnly(task.dueDateTime!), today);
            }).toList();

            // Overdue (dated before now)
            final overdueActive = active.where((task) {
              final due = task.dueDateTime;
              if (due == null) return false;
              return !_isSameDay(_dateOnly(due), today) && due.isBefore(now);
            }).toList();

            // Today section tasks = today + overdue (active)
            final todaySectionActive =
                <TaskModel>[...overdueActive, ...todayActive]..sort((a, b) {
                  // overdue first
                  final aOver =
                      a.dueDateTime != null && a.dueDateTime!.isBefore(now);
                  final bOver =
                      b.dueDateTime != null && b.dueDateTime!.isBefore(now);
                  if (aOver && !bOver) return -1;
                  if (!aOver && bOver) return 1;

                  // higher priority first
                  return b.priority.compareTo(a.priority);
                });

            // Incoming = future + no-date (active)
            final incomingActive =
                active.where((task) {
                  final due = task.dueDateTime;
                  if (due == null) return true; // no-date goes to incoming
                  final day = _dateOnly(due);

                  // future only (after today) and not overdue
                  return day.isAfter(today) && due.isAfter(now);
                }).toList()..sort((a, b) {
                  final ad = a.dueDateTime;
                  final bd = b.dueDateTime;

                  // dated first
                  if (ad == null && bd == null) return 0;
                  if (ad == null) return 1;
                  if (bd == null) return -1;

                  return ad.compareTo(bd); // earlier first
                });

            final incomingTop = incomingActive.take(3).toList();

            // =========================
            // Progress (Today + Overdue)
            // =========================
            // done from same group: (today or overdue)
            final doneForProgress = state.tasks.where((task) {
              if (task.status != TaskStatus.done.index) return false;
              final due = task.dueDateTime;
              if (due == null) return false;

              final day = _dateOnly(due);
              final isToday = _isSameDay(day, today);
              final isOverdue = due.isBefore(now) && !isToday;
              return isToday || isOverdue;
            }).toList();

            final totalForProgress =
                todaySectionActive.length + doneForProgress.length;

            final double progress = totalForProgress == 0
                ? 0.0
                : (doneForProgress.length / totalForProgress);

            final int percent = (progress * 100).round();

            // Completed list for expansion = doneForProgress
            final completedList = List<TaskModel>.of(doneForProgress)
              ..sort(
                (a, b) =>
                    (b.dueDateTime ?? now).compareTo(a.dueDateTime ?? now),
              );

            // tasks left (today+overdue active)
            final leftCount = todaySectionActive.length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              children: [
                _ValueListenableHeader(now: now),

                const SizedBox(height: 24),

                // =========================
                // Progress ring (based on today+overdue)
                // =========================
                if (totalForProgress == 0) ...[
                  _todayEmptyCard(context, onAdd: () => _openQuickAdd(context)),
                ] else ...[
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeOutCubic,
                            tween: Tween<double>(
                              begin: 0,
                              end: progress.clamp(0.0, 1.0).toDouble(),
                            ),
                            builder: (context, value, _) {
                              return CircularProgressIndicator(
                                value: value,
                                strokeWidth: 12,
                                backgroundColor: AppColors.border,
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.primary,
                                ),
                                strokeCap: StrokeCap.round,
                              );
                            },
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$percent%",
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              leftCount == 0 ? t.allDone : t.done,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    leftCount == 0
                        ? t.allTasksDoneToday
                        : t.tasksLeft(leftCount),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                // =========================
                // TODAY TASKS section (today + overdue)
                // =========================
                if (todaySectionActive.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionTitle(
                    context,
                    t.todayTasks,
                    onSeeAll: () => _goToAllTasks(context),
                  ),
                  const SizedBox(height: 8),
                  ...todaySectionActive.map(
                    (task) => _animatedTask(context, task),
                  ),
                ],

                // =========================
                // Completed (today + overdue)
                // =========================
                if (completedList.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _completedTodaySection(
                    context,
                    completedList,
                    initiallyExpanded: leftCount == 0,
                  ),
                ],

                // =========================
                // INCOMING (future + no-date)
                // =========================
                if (incomingTop.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionTitle(
                    context,
                    t.incoming,
                    onSeeAll: () => _goToAllTasks(context),
                  ),
                  const SizedBox(height: 8),
                  ...incomingTop.map(
                    (task) => TaskCard(
                      task: task,
                      onToggleDone: () =>
                          context.read<TasksCubit>().toggleDone(task),
                      onDelete: () =>
                          context.read<TasksCubit>().deleteTask(task.id),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // ========================= UI HELPERS =========================

  Widget _sectionTitle(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    final t = AppLocalizations.of(context)!;

    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const Spacer(),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              t.seeAll,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
      ],
    );
  }

  Widget _animatedTask(BuildContext context, TaskModel task) {
    final exiting = _exiting.contains(task.id);

    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        opacity: exiting ? 0.0 : 1.0,
        child: TaskCard(
          task: task,
          onToggleDone: () => _toggleFromToday(context, task),
          onDelete: () => context.read<TasksCubit>().deleteTask(task.id),
        ),
      ),
    );
  }

  Widget _completedTodaySection(
    BuildContext context,
    List<TaskModel> done, {
    bool initiallyExpanded = false,
  }) {
    final t = AppLocalizations.of(context)!;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          collapsedIconColor: AppColors.textMuted,
          iconColor: AppColors.textMuted,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          title: Row(
            children: [
              Text(
                t.todayCompleted,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha((0.14 * 255).toInt()),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: AppColors.primary.withAlpha((0.35 * 255).toInt()),
                  ),
                ),
                child: Text(
                  "${done.length}",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          children: done
              .map(
                (task) => Opacity(
                  opacity: 0.65,
                  child: TaskCard(
                    task: task,
                    onToggleDone: () =>
                        context.read<TasksCubit>().toggleDone(task),
                    onDelete: () =>
                        context.read<TasksCubit>().deleteTask(task.id),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _todayEmptyCard(BuildContext context, {VoidCallback? onAdd}) {
    final t = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha((0.16 * 255).toInt()),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withAlpha((0.35 * 255).toInt()),
              ),
            ),
            child: const Icon(
              Icons.wb_sunny_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.nothingScheduled,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.addTaskStartDay,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(t.addTask),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueListenableHeader extends StatelessWidget {
  final DateTime now;
  const _ValueListenableHeader({required this.now});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final prefs = Hive.box(HiveBoxs.prefs);

    final locale = Localizations.localeOf(context).languageCode;
    final dateText = DateFormat('EEE, d MMM', locale).format(now);

    return ValueListenableBuilder(
      valueListenable: prefs.listenable(
        keys: const ['user_name', 'user_photo_path'],
      ),
      builder: (context, Box box, _) {
        final rawName = (box.get('user_name') as String?)?.trim();
        final name = (rawName != null && rawName.isNotEmpty) ? rawName : t.user;

        final rawPath = (box.get('user_photo_path') as String?)?.trim();
        final File? photoFile =
            (rawPath != null &&
                rawPath.isNotEmpty &&
                File(rawPath).existsSync())
            ? File(rawPath)
            : null;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Avatar(photoFile: photoFile),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.welcomeBack,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateText,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              icon: const Icon(
                Icons.settings_rounded,
                color: AppColors.textMuted,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  final File? photoFile;
  const _Avatar({required this.photoFile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ClipOval(
        child: photoFile != null
            ? Image.file(photoFile!, fit: BoxFit.cover)
            : Container(
                color: AppColors.surface,
                child: const Icon(Icons.person, color: AppColors.textMuted),
              ),
      ),
    );
  }
}
