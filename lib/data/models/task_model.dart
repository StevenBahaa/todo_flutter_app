import 'package:hive_flutter/adapters.dart';

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
}
