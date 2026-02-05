import 'package:hive_flutter/adapters.dart';
import 'package:todo_list/data/local/hive_boxes.dart';
import 'package:todo_list/data/models/task_model.dart';

class HiveInit {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Adapters will be registered here later (Task, Category, Prefs)
    if (!Hive.isAdapterRegistered(TaskModelAdapter().typeId)) {
      Hive.registerAdapter(TaskModelAdapter());
    }

    await Hive.openBox(HiveBoxs.tasks);
    await Hive.openBox(HiveBoxs.categories);
    await Hive.openBox(HiveBoxs.prefs);
  }
}
