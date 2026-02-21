import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

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
    final isDone = x.status == TaskStatus.done.index;
    return !isDone || exitingIds.contains(x.id);
  }).toList();

  final done = all.where((x) => x.status == TaskStatus.done.index).toList();

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

  // Sorting (اختياري لكن مفيد)
  overdue.sort((a, b) => (a.dueDateTime ?? now).compareTo(b.dueDateTime ?? now)); // الأقدم أولاً
  today.sort((a, b) => b.priority.compareTo(a.priority)); // high first
  upcoming.sort((a, b) => (a.dueDateTime ?? now).compareTo(b.dueDateTime ?? now));
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