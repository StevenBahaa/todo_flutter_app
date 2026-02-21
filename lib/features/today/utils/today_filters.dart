import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';

class TodayGroups {
  TodayGroups({
    required this.todayOverdueActive,
    required this.incomingActive,
    required this.doneForProgress,
    required this.completedSorted,
    required this.totalForProgress,
    required this.progress,
    required this.percent,
    required this.leftCount,
  });

  final List<TaskModel> todayOverdueActive; // today + overdue (active)
  final List<TaskModel> incomingActive; // future + no-date (active)
  final List<TaskModel> doneForProgress; // done tasks that are today/overdue
  final List<TaskModel> completedSorted;

  final int totalForProgress;
  final double progress;
  final int percent;
  final int leftCount;
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

TodayGroups buildTodayGroups({
  required List<TaskModel> allTasks,
  required Set<String> exitingIds,
  required DateTime now,
}) {
  final today = dateOnly(now);

  // active = not done OR exiting animation
  final active = allTasks.where((task) {
    final isDone = task.status == TaskStatus.done.index;
    return !isDone || exitingIds.contains(task.id);
  }).toList();

  final todayActive = active.where((task) {
    final due = task.dueDateTime;
    if (due == null) return false;
    return isSameDay(dateOnly(due), today);
  }).toList();

  final overdueActive = active.where((task) {
    final due = task.dueDateTime;
    if (due == null) return false;
    final isToday = isSameDay(dateOnly(due), today);
    return !isToday && due.isBefore(now);
  }).toList();

  // Today section: overdue first, then today, higher priority first
  final todayOverdueActive = <TaskModel>[...overdueActive, ...todayActive]
    ..sort((a, b) {
      final aOver = a.dueDateTime != null && a.dueDateTime!.isBefore(now);
      final bOver = b.dueDateTime != null && b.dueDateTime!.isBefore(now);
      if (aOver && !bOver) return -1;
      if (!aOver && bOver) return 1;
      return b.priority.compareTo(a.priority);
    });

  // Incoming: future + no-date
  final incomingActive = active.where((task) {
    final due = task.dueDateTime;
    if (due == null) return true;
    final day = dateOnly(due);
    return day.isAfter(today) && due.isAfter(now);
  }).toList()
    ..sort((a, b) {
      final ad = a.dueDateTime;
      final bd = b.dueDateTime;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return ad.compareTo(bd);
    });

  // done tasks for progress: due today or overdue (based on dueDate)
  final doneForProgress = allTasks.where((task) {
    if (task.status != TaskStatus.done.index) return false;
    final due = task.dueDateTime;
    if (due == null) return false;
    final day = dateOnly(due);
    final isToday = isSameDay(day, today);
    final isOverdue = due.isBefore(now) && !isToday;
    return isToday || isOverdue;
  }).toList();

  final totalForProgress = todayOverdueActive.length + doneForProgress.length;
  final progress =
      totalForProgress == 0 ? 0.0 : (doneForProgress.length / totalForProgress);
  final percent = (progress * 100).round();
  final leftCount = todayOverdueActive.length;

  final completedSorted = List<TaskModel>.of(doneForProgress)
    ..sort((a, b) => (b.dueDateTime ?? now).compareTo(a.dueDateTime ?? now));

  return TodayGroups(
    todayOverdueActive: todayOverdueActive,
    incomingActive: incomingActive,
    doneForProgress: doneForProgress,
    completedSorted: completedSorted,
    totalForProgress: totalForProgress,
    progress: progress,
    percent: percent,
    leftCount: leftCount,
  );
}