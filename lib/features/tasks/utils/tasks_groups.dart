import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// ✅ Smart done:
/// - If task has subtasks -> done when ALL subtasks are done
/// - Else -> done by task.status
bool isTaskDoneSmart(TaskModel x) {
  final subs = x.safeSubTasks;
  if (subs.isNotEmpty) return subs.every((s) => s.isDone);
  return x.status == TaskStatus.done.index;
}

class TaskGroups {
  TaskGroups({
    required this.active,
    required this.done,
    required this.overdue,
    required this.today,
    required this.upcoming,
    required this.noDate,
    required this.highPriority,
  });

  final List<TaskModel> active;
  final List<TaskModel> done;
  final List<TaskModel> overdue;
  final List<TaskModel> today;
  final List<TaskModel> upcoming;
  final List<TaskModel> noDate;
  final List<TaskModel> highPriority;
}

TaskGroups buildTaskGroups({
  required List<TaskModel> all,
  required Set<String> exitingIds,
  required DateTime now,
}) {
  final todayDate = _dateOnly(now);

  final active = all.where((x) {
    final doneSmart = isTaskDoneSmart(x);
    return !doneSmart || exitingIds.contains(x.id);
  }).toList();

  final done = all.where((x) => isTaskDoneSmart(x)).toList();

  final overdue = active.where((x) {
    final due = x.dueDateTime;
    if (due == null) return false;
    return due.isBefore(now);
  }).toList();

  final today = active.where((x) {
    final due = x.dueDateTime;
    if (due == null) return false;
    return _sameDay(_dateOnly(due), todayDate) && !due.isBefore(now);
  }).toList();

  final upcoming = active.where((x) {
    final due = x.dueDateTime;
    if (due == null) return false;
    return _dateOnly(due).isAfter(todayDate);
  }).toList();

  final noDate = active.where((x) => x.dueDateTime == null).toList();

  final highPriority = active.where((x) {
    return TaskPriority.values[x.priority] == TaskPriority.high;
  }).toList();

  // Sorting
  overdue.sort(
    (a, b) => (a.dueDateTime ?? now).compareTo(b.dueDateTime ?? now),
  );
  today.sort((a, b) => b.priority.compareTo(a.priority)); // high first
  upcoming.sort(
    (a, b) => (a.dueDateTime ?? now).compareTo(b.dueDateTime ?? now),
  );
  noDate.sort((a, b) => b.priority.compareTo(a.priority));

  return TaskGroups(
    active: active,
    done: done,
    overdue: overdue,
    today: today,
    upcoming: upcoming,
    noDate: noDate,
    highPriority: highPriority,
  );
}

class ProgressCounts {
  final int done;
  final int total;
  const ProgressCounts({required this.done, required this.total});

  int get left => (total - done).clamp(0, total);
  double get ratio => total == 0 ? 0.0 : done / total;
}

/// ✅ Hybrid progress:
/// - If task has subtasks -> count by subtasks
/// - Else -> count by task itself
ProgressCounts computeProgressCounts(List<TaskModel> tasks) {
  int done = 0;
  int total = 0;

  for (final task in tasks) {
    final subs = task.safeSubTasks;

    if (subs.isNotEmpty) {
      total += subs.length;
      done += subs.where((s) => s.isDone).length;
    } else {
      total += 1;
      if (task.status == TaskStatus.done.index) done += 1;
    }
  }

  return ProgressCounts(done: done, total: total);
}
