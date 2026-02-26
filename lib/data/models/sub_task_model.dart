import 'package:hive/hive.dart';

part 'sub_task_model.g.dart';

@HiveType(typeId: 2) // new unique typeId
class SubTaskModel extends HiveObject {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool isDone;

  SubTaskModel({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  SubTaskModel copyWith({
    String? id,
    String? title,
    bool? isDone,
  }) {
    return SubTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}