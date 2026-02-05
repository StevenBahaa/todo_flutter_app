import 'package:hive_flutter/adapters.dart';
import 'package:todo_list/data/models/task_enums.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final int status;

  @HiveField(4)
  final int priority;

  @HiveField(5)
  final DateTime? dueDateTime;

  @HiveField(6)
  final String? categoryId;

  @HiveField(7)
  final List<String> tags;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDateTime,
    this.categoryId,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.newTask({
    required String id,
    required String title,
    String? categoryId,
    DateTime? dueDateTime,
    TaskPriority priority = TaskPriority.medium,
    List<String> tags = const [],
  }) {
    final now = DateTime.now();
    return TaskModel(
      id: id,
      title: title,
      description: null,
      status: TasksStatus.todo.index,
      priority: priority.index,
      dueDateTime: dueDateTime,
      categoryId: categoryId,
      tags: tags,
      createdAt: now,
      updatedAt: now,
    );
  }
  TaskModel copyWith({
    String? title,
    String? description,
    int? status,
    int? priority,
    DateTime? dueDateTime,
    String? categoryId,
    List<String>? tags,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
