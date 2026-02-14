import 'package:hive/hive.dart';
import 'package:todo_list/data/local/hive_boxes.dart';
import 'package:todo_list/data/models/task_model.dart';

class TasksRepository {
  Box<TaskModel> get _box => Hive.box<TaskModel>(HiveBoxs.tasks);

  List<TaskModel> getAll() {
    return _box.values.toList();
  }

  Future<void> add(TaskModel task) async {
    await _box.put(task.id, task);
    
  }

  Future<void> update(TaskModel task) async {
    await _box.put(task.id, task);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  TaskModel? getById(String id) {
    return _box.get(id);
  }
}
