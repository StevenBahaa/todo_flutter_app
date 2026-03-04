import 'package:flutter/material.dart';
import 'package:todo_list/data/models/sub_task_model.dart';
import 'package:todo_list/data/models/task_enums.dart';
import 'package:todo_list/data/models/task_model.dart';

class TaskDetailsController {
  final TaskModel original;

  late final TextEditingController title;
  late final TextEditingController desc;
  final TextEditingController tagController = TextEditingController();
  final TextEditingController subTaskController = TextEditingController();

  late TaskPriority priority;
  DateTime? dueDateTime;
  late List<String> tags;
  late List<SubTaskModel> subTasks;

  TaskDetailsController(this.original) {
    title = TextEditingController(text: original.title);
    desc = TextEditingController(text: original.description);
    priority = TaskPriority.values[original.priority];
    dueDateTime = original.dueDateTime;
    tags = List<String>.from(original.tags);
    subTasks = List<SubTaskModel>.from(original.safeSubTasks);
  }

  void dispose() {
    title.dispose();
    desc.dispose();
    tagController.dispose();
    subTaskController.dispose();
  }

  bool get hasChanges {
    return title.text.trim() != original.title ||
        desc.text.trim() != (original.description ?? "") ||
        priority.index != original.priority ||
        dueDateTime != original.dueDateTime ||
        !_listEquals(tags, original.tags) ||
        !_subTasksEquals(subTasks, original.safeSubTasks);
  }

  TaskModel buildUpdated() {
    return original.copyWith(
      title: title.text.trim(),
      description: desc.text.trim(),
      priority: priority.index,
      dueDateTime: dueDateTime,
      tags: List.unmodifiable(tags),
      subtasks: List.unmodifiable(subTasks),
    );
  }

  // ---- Tags ----
  void addTag() {
    final raw = tagController.text.trim();
    if (raw.isEmpty) return;

    final parts = raw
        .split(RegExp(r'[,\s]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    for (final p in parts) {
      final tag = p.startsWith('#') ? p.substring(1) : p;
      if (tag.isEmpty) continue;
      if (!tags.contains(tag)) tags.add(tag);
    }
    tagController.clear();
  }

  void removeTag(String tag) => tags.remove(tag);

  // ---- Subtasks ----
  void addSubTask() {
    final raw = subTaskController.text.trim();
    if (raw.isEmpty) return;

    subTasks = [
      ...subTasks,
      SubTaskModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: raw,
        isDone: false,
      ),
    ];

    subTaskController.clear();
  }

  void toggleSubTask(String id) {
    final idx = subTasks.indexWhere((s) => s.id == id);
    if (idx == -1) return;

    final s = subTasks[idx];
    subTasks = [...subTasks]..[idx] = s.copyWith(isDone: !s.isDone);
  }

  void deleteSubTask(String id) {
    subTasks = subTasks.where((s) => s.id != id).toList();
  }

  void renameSubTask(String id, String title) {
    final idx = subTasks.indexWhere((s) => s.id == id);
    if (idx == -1) return;

    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    final s = subTasks[idx];
    subTasks = [...subTasks]..[idx] = s.copyWith(title: trimmed);
  }

  // ---- helpers ----
  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _subTasksEquals(List<SubTaskModel> a, List<SubTaskModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
      if (a[i].title != b[i].title) return false;
      if (a[i].isDone != b[i].isDone) return false;
    }
    return true;
  }
}